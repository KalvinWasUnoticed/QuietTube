# QuietTube 0.13.1 — real single-switch activation and cleanup

**Source + GitHub build workflow, not a compiled IPA or a confirmed player-ad fix.** Same pinned YouTube 21.38.2.

## What your latest report establishes

0.13 had adTest ON but adTestPlayer/adTestFeed OFF, neither workaround hook installed and zero events. Thus the stable five-minute session did not exercise either new workaround. We cannot identify why that video had no ads from those logs, or attribute it to player blocking. Variable ad delivery is possible, not a proven explanation. The report does establish that the post-minimize card appeared while the feed workaround was inactive.

The original “Effective now: on” label only reflected the top-level gate and was misleading. Saved OFF values override registerDefaults defaults; the supplied report does not establish what originally saved those values. 0.13.1 removes the extra gates instead of asking you to navigate another hidden toggle page.

## Changes

- **Ad test profile is now the sole ad-workaround control.** If ON, both the native no-op factory substitution and watch-while-feed-mutation feature hook are attempted. Stale adTestPlayer/adTestFeed preferences are not read or registered.
- **Upgrade behavior:** your saved adTest=ON now requests BOTH workarounds after full restart. Turn it off before upgrading if you want native playback first. New installs still default OFF. No global preference reset.
- Removed the separate pass-through player probe from the build, its initializer/declaration/control/report, the Ad test options page, legacy disabled playerAds control and disabled Home-hiding control. Old keys are ignored. No active nil-coordinator, scoped-config, model-load or insertion experiment remains.
- Empty source stubs and replacement retired-test filenames are retained ONLY for safe overlay uploads, not compiled. This avoids the old stale-file build failure.
- Unified report distinguishes requested state, hook installation, native no-op objects actually supplied, and disabled-feed-feature reads. With zero relevant invocations, it explicitly says blocking/workaround activation was not demonstrated. Hook invocation still does not prove a particular ad was removed.
- Existing working feed cleanup, default logo, navigation, background audio, native PiP, preference snapshot/migration, playback-error forwarding and direct IPA release flow retained. Native player/feed workarounds themselves are unchanged from the unexercised 0.13 implementation.

## The two workarounds being activated

Player: construct the native no-op coordinator with the binary-verified designated initializer, original factory scope and original delegate; fall back to the original factory if checks/construction fail. No synthetic nil, global ad-array overrides, request spoofing or manual fake-completion calls.

Post-minimize feed: disable the binary-verified enableWatchWhileFeedMutationOnIos feature, which gates registration of ad-driven feed mutations. No guessed renderer-title filter, id.sponsor_button removal, arbitrary external-link filtering or whole-view hiding. This is a supported candidate mechanism, not yet confirmed as the source of the user's exact card.

These paths were not active in the latest report. No additional invasive ad filter is added on the basis of that inactive test. If an installed/invoked feed workaround still misses the card, its new report will distinguish that from the activation failure.

## Build and one short test

1. Replace repository contents with this folder's contents, including hidden .github, all Sources and tests. Commit and launch a NEW Actions run; an old run rerun uses its old commit.
2. After success choose **Summary → DOWNLOAD IPA — QuietTube 0.13.1**. Actual asset: `QuietTube-0.13.1-21.38.2.ipa`. Prefer a private repo; public release approval exposes the modified IPA. Private links require GitHub authentication.
3. Import into LiveContainer with the same data container, no second injection. Keep 0.10 for rollback. Ensure **Quiet controls → Playback → Ad test profile** is ON, then fully stop/relaunch the guest. No branch switches remain.
4. Play a video and minimize it. If stable, check beyond the old failure window and native PiP/background.
5. Send **Advanced → Ad test report** plus only: player ad appeared? pushed sponsored card appeared? playback worked/error? Do not repeat the old 0.13 report as new evidence.

## Safety / honest limits

A detected playback NSError trips the atomic safety latch and saves only adTest OFF for the next launch. Future calls use native behavior; existing player objects are NOT repaired. Restart after errors. If saving OFF fails, the report instructs manual disable. A crash or stall may not reach the observer: disable manually or roll back to 0.10 if settings are inaccessible. No retries or error hiding. The report is session-local, fixed-label totals plus last80 events, at most three numeric/domain-bucket error levels; no payloads/IDs/URLs or uploads.

**No guarantee of zero errors, invisible blocking or complete ad removal.** 0.13.1 has not been compiled with an Apple SDK or tested on device here. 0.13 did build/run on your phone, but these newly activated paths still require validation.

## Validation

50 Python tests passed clean and after an overlay onto 0.13. Protected-module/function hashes verify the working feed classifier, scanner, logo, packager, runtime-hook utilities, settings navigation integration and batch filter. C under ASan/UBSan:79 classifier fixtures +5000 random iterations;20 scanner fixtures +5000 random iterations;32 status combinations plus the reported inactive-session regression. Shell syntax, YAML and ZIP checked. New status tests prevent “enabled means blocking works” reporting. Static tests cannot establish native behavior.
