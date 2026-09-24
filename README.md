# QuietTube 0.12 — native no-op coordinator / insertion-boundary tests

**Source + build workflow, NOT a compiled IPA or a proven ad-blocking fix.** Two independent off-by-default experiments. Same pinned YouTube 21.38.2 base. Built from the 0.10 working baseline, not by stacking changes onto the failed 0.11 experiments.

## What the 0.11 results established

- Player test 1: four coordinator creations suppressed, playback failed, YouTube error code 0. Returning nil is retired. This does not prove server-side detection or identify a specific underlying cause.
- Post-play experiment: loadWithModel ran 33 times, changed five models, retained 20 unsupported inputs, yet cards persisted. No new template match was reported. That experiment and its extra template set are retired, not broadened indiscriminately.
- Neither `id.sponsor_button`, video metadata nor generic injection keys is an ad-removal rule. These can occur in legitimate content.

The old keys `playerExperiment1` and `companionAds` are no longer registered/read by 0.12. Even if saved ON, they cannot activate old code here. No global preference reset. Returning to 0.11 could reactivate old saved settings, so prefer 0.10 for rollback.

## Player test 2: native no-op coordinator

**Quiet controls → Playback → Player test 2: native no-op coordinator**

The supplied executable was re-downloaded and its pinned SHA-256 verified. Its native `YTRealAdsPlayerServices` factory reads `playerData.playerConfig.iosPlayerConfig.useNoOpAdsCoordinator` and can create `YTNoOpAdsPlaybackCoordinator` using its own service scope/delegate. Native no-op preroll/postroll methods contain the delegate break-finished callback. The parameterless no-op initializer returns nil, so we do NOT manually instantiate it. Evidence and method encodings are in BASE-PLAYER-ABI.json and BINARY-RESEARCH.md.

Test 2 leaves `createAdsPlaybackCoordinator` and the native factory call intact. While the native factory runs synchronously, it makes the no-op flag read YES only for that exact config object on that thread. The previous scope is restored in `finally`; other reads use the original getter. No configuration/response object is written or serialized. Runtime getter resolution/signature checks must succeed; missing configuration or unsupported getter leaves native behavior in place.

The factory returns its own result. No manual ad-completion callbacks, nil replacement, response-array overrides, request/client/signal changes, retries or error suppression. This is better-grounded than test 1, not guaranteed safe: no-op mode may be inappropriate for this response/server session and may still cause errors, leave ads, or affect companion delivery. Its semantics include native break-finished callbacks; it is not a claim that ad viewing is actually completed or invisible to YouTube. No beacons are fabricated by this code.

The existing Observe player ad coordinator control can remain ON; it still returns the native result unchanged. If no-op creation works it will still count an OBJECT, not an ad.

## Post-play test 2: insertion filtering

**Quiet controls → Distractions → Post-play test 2: insertion filtering**

Requires Feed ads and Extended feed formats. Independent of player test 2. The binary owns `YTInnerTubeCollectionViewController / insertBelowVisibleSection:` with a verified void/object signature. This method is separate from addSectionsFromArray and loadWithModel; its existence does not prove these screenshots use it.

At that method, recognize only explicit ad fields/logging and established ad tokens. Unknown/non-YTI inputs pass through. Single-child wrappers can be checked; multi-item sections are retained rather than deleting ordinary content because of one nested ad. Depth/budget limits and exception fallback remain. If recognized as an ad, skip this optional insertion, not the entire existing feed. Skipping the method also skips its ancillary bookkeeping; that is a remaining runtime risk. This controller is shared, not restricted to Home. No generic link/Sponsored text filter or layout hiding.

The old broad model-load experiment is absent. Existing batch feed rules, Watch again/Mix/Shorts/topic cleanup, default logo, settings navigation, background audio, native PiP and existing error forwarding are preserved.

## Build and install

1. Replace repository contents with the contents of QuietTube-v0.12, including hidden .github, new Sources/QTPlayerTest2.m, tests and ABI record. Keep 0.10 as a rollback IPA; preserve the data container.
2. Run Actions → Build QuietTube IPA. Prefer a private repository; public release assets expose the modified IPA and require explicit approval.
3. After success use **Summary → DOWNLOAD IPA — QuietTube 0.12**, yielding `QuietTube-0.12-21.38.2.ipa` directly. GitHub source archives are not the IPA. Private downloads require an authorized GitHub login.
4. Import into LiveContainer, no second injection; fully stop/relaunch the guest to apply settings.

## Test separately

A. Both NEW switches OFF: check normal playback before experimenting. Old failed switches no longer appear.

B. Player test 2 ON, insertion test OFF: restart. Test an ad-bearing video and another video, watch beyond the previous failure interval, then seek/background/native PiP. If any error or sustained stall appears, stop, disable test 2 and restart. If settings are inaccessible, revert to 0.10. There is no automatic recovery. See TEST-PLAN.md for counters that distinguish requested mode from actual native no-op creation.

C. Player test 2 OFF, insertion test ON: restart. Tap a Home video, minimize it, inspect the card below. Check whether the new insertion hook runs and whether recognized ad insertion is suppressed. If it never runs or forwards unknown models, no targeted fix is established. Do not enable all flags as a workaround.

Only combine after each separately succeeds. Ad delivery varies: one ad-free replay or a nonzero counter is not proof of stable blocking. No need to repeat the supplied 0.11 logs.

## Validation

44 Python tests (8 packaging, 6 mocked release, 30 static/source/ABI/scope checks) passed. C under ASan/UBSan: 79 classifier fixtures + 5,000 random iterations and 20 scanner fixtures + 5,000 random iterations. Existing baseline comparisons pass after accounting for explicitly marked additions/version/UI text. Shell syntax, YAML and ZIP checked.

**No Apple SDK build, actual GitHub release upload or 0.12 device test here.** Static binary ABI/call-path findings do not prove semantic safety, ad removal or undetectability. Original downloaded IPA/executable were removed after extracting the small evidence records.
