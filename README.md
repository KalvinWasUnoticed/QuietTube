# QuietTube 0.13 — one ad-test profile, targeted workarounds, bounded report

**Source + GitHub build workflow, NOT a compiled IPA.** Same pinned YouTube 21.38.2 base. These are implemented workarounds requiring native/device validation, not a promise of ad-free, error-free or undetectable playback.

## One test, one report

1. Build/install 0.13 as below. Keep 0.10 as a rollback IPA and preserve the guest data container.
2. Open **You → Settings → General → Quiet controls → Playback → Ad test profile**. Turn this ONE new switch on. Leave the two Ad test options at their defaults (both on); your established feed/appearance/audio settings stay unchanged.
3. Fully stop/relaunch the LiveContainer guest. Play a video where ads occurred, continue watching beyond the old failure window, and swipe down to minimize. Check whether a sponsored card is pushed into the feed. No mandatory two-run matrix.
4. Open **Quiet controls → Advanced → Ad test report** and send only that short report plus “player ads: yes/no; pushed card: yes/no; playback: worked/error”. Ads vary between plays; one ad-free run is not definitive.

Stop at any playback error or sustained stall. A detected playback error trips the safety latch, reverts NEW calls to native behavior and saves the profile OFF for the next launch. **Restart the guest afterward**: an existing coordinator/player cannot be repaired by this latch. Stalls/crashes may not trigger the existing error hook; disable manually or revert to 0.10 if needed. There are no retry/seek loops or hidden errors.

## What actually changed

### Player: verified native constructor, no missing-config dependency

The 0.12 run never selected the native no-op coordinator: three factory calls had missing config, no scoped flag reads/no-op results were reported. The three “hook not installed” lines were also a diagnostic bug: the install retry compared the already-installed IMP to itself. This was not evidence that no-op playback had been successfully tested and failed.

0.13 removes the config getter hook and pointer-scoping approach. At the verified native factory method it reads the verified object ivar `_serviceRegistryScope` and calls the native `YTNoOpAdsPlaybackCoordinator` initializer `initWithServiceRegistryScope:delegate:` using that scope and the original delegate. It does not use parameterless init (known to return nil). The typed initializer preserves ARC init-family ownership conventions. It does not require a response/config to exist yet.

Only a valid native no-op object is substituted. Missing scope/delegate, unavailable constructor ABI or construction failure leaves the original factory behavior available. No synthetic nil coordinator, global response-array overrides, serialized config edits, request rewrites, signal suppression or fabricated ad-completion calls. The native object's own lifecycle callbacks still run. This can still be incompatible with particular responses or playback modes and may leave ads or cause errors; no device success claim yet.

### Feed: native watch-while mutation feature, not another guessed UI insertion hook

Fresh inspection of the pinned binary located `YTInFeedDynamicSectionListLayoutRenderingAdapter`. Its initializer checks `YTHotConfig.enableWatchWhileFeedMutationOnIos` before registering a layout-enter listener with mutation operations. 0.13 returns NO from this specific feature getter while the profile/feed branch is effective. Native code handles the disabled path. This targets a verified ad-specific mutation mechanism; it does NOT prove that every pictured card uses it. Other readers of this feature flag may also be affected.

The unused insertBelowVisibleSection hook and failed broad loadWithModel hook are not active. Generic metadata, id.sponsor_button, external links and ordinary horizontal shelves are not removed. Existing batch feed cleanup remains unchanged. Native disabled-feature/error behavior is not hidden from YouTube and is not an undetectability technique.

### Diagnostics and safety

Installation-success flags persist through scheduled retries, avoiding false “not installed” reports. The new report shows requested/effective/saved state, branch settings, installed states, fixed event totals, and the last 80 relative-time events. Numeric error domain categories and up to three underlying-error levels are included. No video/account IDs, signed URLs, localized error descriptions, raw userInfo, response bodies or automatic uploads. Reports are session-local; restart resets them.

The safety latch activates only when the existing native playback-error observer sees an NSError while this profile is enabled. It cannot guarantee interception of every failure. It does not retry, suppress the native error handler, reset the player, roll back an existing coordinator or recover from crashes. If saving OFF fails, the report says so; turn it off manually.

Advanced → Ad test options exposes **Player workaround** and **Post-play feed workaround** for troubleshooting only. Both default on but do nothing without Ad test profile. Normally do not change them. Old playerExperiment1/companionAds/playerExperiment2/insertionAds2 keys are ignored, even if previously saved on. The old paused playerAds control is not this profile.

## Build / actual IPA download

Extract QuietTube-v0.13.zip. Upload/replace the CONTENTS of its QuietTube-v0.13 folder at your repository root, including hidden .github, Sources/QTAdProfile.m and all tests. Retired test filenames and an empty retired source stub are included so overlay upgrades overwrite stale content. Commit changes and start a NEW workflow run (not a rerun of an old commit).

Prefer a private repository. Public release publication requires explicit approval. After success click **Summary → DOWNLOAD IPA — QuietTube 0.13** for `QuietTube-0.13-21.38.2.ipa` directly, not GitHub's source ZIP/TAR. Private downloads require an authorized GitHub login. Import into LiveContainer without another injection; restart the guest.

## Preservation and validation

Based on the 0.10 stable feed/player-with-ads baseline. Existing logo, batch feed/Watch again/Mix/Shorts/topic rules, settings navigation/Done, background audio, native PiP and sign-in paths remain. New code does not change server identity or authentication. The native playback-error handler still executes; the new observer only records/trips the profile.

51 Python tests passed clean AND after overlaying onto 0.12. Existing source-baseline comparisons pass after accounting for marked additions/version/UI/report changes. C under ASan/UBSan: 79 classifier fixtures + 5,000 randomized iterations, 20 scanner fixtures + 5,000 randomized iterations. Shell syntax, workflow YAML and ZIP checked. Relevant class/method/ivar metadata parsed from the re-downloaded hash-verified base; original IPA/executable removed afterward.

**No Apple SDK/native compile, real release upload or 0.13 device execution here.** Static ABI/disassembly and source/C tests do not establish ARC/runtime behavior, successful ad blocking or absence of regressions. See AUDIT.md and BINARY-RESEARCH.md for limits.
