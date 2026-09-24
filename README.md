# QuietTube 0.13.3 — one-button preparation and minimize tracing

**Source + GitHub build workflow, not a compiled IPA.** Pinned YouTube 21.38.2 base.

## What changes

**Quiet controls → Prepare ad test** saves all seven current prerequisites together: modifications, Ad test profile, feed ads, extended feed formats, additional display-ad formats, element inspection and minimize/mutation tracing. It preserves every other preference. It does not activate hooks mid-session, erase the current report or reset installation counters. Fully stop/relaunch the LiveContainer guest afterward.

The short **Advanced → Ad test report** now shows current-launch versus next-launch flags and a bounded timeline covering:
- Native will-collapse / did-collapse callbacks and layout changes (numeric layout values remain unmapped).
- Five collection mutation dispatch/insert/replace handlers.
- The array-section model's insert notification, including bounded entry-class samples.

Nine method signatures/ownership records were checked against your pinned binary. These new hooks forward original arguments, return values, NSError pointers and native exceptions without changing feed operations. Reporting contains class names/counts/times, not titles, video IDs, URLs or payload dumps. Existing element inspection also captures bounded internal template identifiers locally; it is not an automatic upload.

The trace retains up to 24 preceding events and 96 total events, stopping detailed capture 12 seconds after an observed collapse start. A new observed collapse starts another window. Drops/outside-window counts are explicit. It is not a complete recording: some methods may not run for this UI path, and heavily populated windows may truncate early events. Nearby calls establish timing, not ad identity or causation.

## What does NOT change

The player construction/fallback block remains byte-for-byte identical to 0.13.1/0.13.2. Your 0.13.1 report established five native no-op substitutions with no player ads and stable playback in that session; no universal guarantee follows.

Your 0.13.2 report again showed five substitutions but **zero companion callbacks** while the sponsored card persisted. More flags do not fix an uncalled companion path. That existing experimental callback is unchanged; this release adds observation, **not a claimed sponsored-card fix**. No guessed renderer filtering is added. Accepted cleanup, logo, native PiP/background, settings navigation and sign-in-related code remain unchanged.

## Build and one test

1. Replace repository files with this folder's contents, including hidden `.github`, Sources, tests and evidence records. Commit and start a **new workflow run**, not a rerun of old code.
2. On success: **Summary → DOWNLOAD IPA — QuietTube 0.13.3** → `QuietTube-0.13.3-21.38.2.ipa`. Source ZIP is not installable. Private GitHub downloads require authorized login; public publication requires explicit approval.
3. Import into the same LiveContainer data container; no second injection. Keep the previous IPA for rollback.
4. Open **You → Settings → General → Quiet controls → Prepare ad test**. Fully stop and relaunch the guest.
5. Play a video, swipe down once, then wait about 12 seconds for the sponsored card/window. Avoid further swipes/scrolling before copying **Advanced → Ad test report**. Send that report and whether the card appeared; mention any player regression. No two-run matrix or full diagnostics needed.

## Safety and validation

Existing playback-error safety latch remains: it saves the profile OFF and restores native behavior for future calls only. Existing players are not repaired; restart after errors, or revert for crashes/stalls. Prepare explicitly saves the profile ON again for a new test. Tracing is separately opt-in and never suppresses errors.

59 Python source/packaging/release checks passed clean and in an upgrade overlay; protected player/cleanup hashes pass. C classifier/scanner/status tests pass with ASan/UBSan. Shell and workflow YAML checks pass. See VALIDATION.json.

**Apple SDK compilation, actual cloud release and 0.13.3 device behavior remain unverified here.** No undetectability or guaranteed ad removal claim.
