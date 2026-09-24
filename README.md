# QuietTube 0.13.2 — preserve active player workaround; native companion clearing

**Source + build workflow, not a compiled IPA.** Same pinned YouTube 21.38.2 base. One existing Ad test profile switch, no new settings to enable.

## What your 0.13.1 report established

Five native no-op objects were supplied; you reported no player ads and stable playback. This is the first reported success with the player workaround actually active. It is not a guarantee across all videos, midrolls or future sessions. The player construction/fallback block is byte-for-byte unchanged in 0.13.2 and protected by a frozen hash test.

We interpret your final sentence as authoritative for the remaining issue: the ad pushed below the selected video still appears after minimizing. The old feed-feature hook had zero invocations. Its installation alone did not establish any effect on that card.

## The targeted feed change

Replace the unused YTHotConfig watch-while-feature hook with the binary-verified `YTCompanionAdObserverBehavior / companionAdDidChange:interactionLoggingAdsClientData:` callback.

Static inspection shows the native callback reads the companion object, clears its companion section, and, when there is no companion, skips appending ad content and commits the cleared section. While the profile is active, 0.13.2 calls this native callback with nil companion-update/logging arguments. It does NOT return a nil playback coordinator, suppress the native callback entirely, or manually clear the general feed. When the profile is off or safety-stopped, original arguments are forwarded.

Counters distinguish callback entry, a non-nil companion payload observed, native clearing applied, and the currentAd state checked afterward. Empty state confirms only this observer's state, not that the screenshot card is necessarily gone. The callback's association with the pictured post-minimize card remains unverified on device. It can also remove companion content/recommendations on other surfaces using this observer; it is not Home-only.

Only this standard companion observer is hooked. The separately inspected engagement-shelf observer has different semantics and is deliberately not treated as an interchangeable ad-removal hook. Generic video metadata, id.sponsor_button, all links and ordinary feed shelves are not removed.

## Other changes / preservation

- Fix the garbled installation-state dash: the C strings formatted through %s are now ASCII. No more encoding-dependent em dash in that field.
- Preserve player no-op constructor/scope/delegate/fallback logic exactly; no new player methods, response mutations, request identities or manual completion callbacks.
- Preserve existing feed cleanup, logo, Watch again/Mix/Shorts/topic controls, settings navigation, background audio and native PiP behavior.
- Preserve one-switch activation, bounded reporting and error safety latch. Old experimental controls/hooks remain retired.

## Build and simplest test

1. Replace repository contents with QuietTube-v0.13.2 folder contents, including hidden .github, all Sources/tests and evidence records. Commit and launch a NEW workflow run.
2. After success select **Summary → DOWNLOAD IPA — QuietTube 0.13.2**, downloading `QuietTube-0.13.2-21.38.2.ipa` directly. Private repository recommended; public publication needs explicit approval. Private downloads require authorized GitHub login.
3. Import into LiveContainer in the same data container without a second injection. Keep 0.13.1 for rollback to the reported stable player behavior.
4. Leave **Playback → Ad test profile ON**, fully restart, play a video and swipe down to the mini-player.
5. Send only **Advanced → Ad test report** and whether the card still appears. Also mention any player regression; no separate two-run matrix is required.

Relevant new counters:
- companion callback received
- companion payload observed
- companion native clear applied
- companion state empty after clear / companion state still populated

No callback means this candidate path was not exercised. Clearing with the visible card still present means another renderer/path needs investigation. Neither result should be concealed by another generic filter. You do not need to repeat old reports.

## Safety and limits

Native callback exceptions are not swallowed or retried. The existing playback-error observer still forwards to YouTube. An observed player NSError trips the safety latch, saves the profile OFF and restores native arguments/creation on subsequent calls; already-created players and cleared companion sections are not automatically repaired. Restart after errors. Stalls/crashes may bypass that observer; disable manually or revert if necessary.

No undetectability, universal ad blocking or zero-error guarantee. Native clearing is an implemented hypothesis with verified ABI/control-flow evidence, not a device-confirmed fix for the card.

## Validation

54 Python tests passed clean and after overlay onto 0.13.1, including a player-path byte-preservation check and callback ABI/forwarding checks. C ASan/UBSan:79 classifier fixtures +5000 random iterations;20 scanner fixtures +5000 random iterations;32 status combinations plus inactive-session regression. Shell syntax, YAML and ZIP checked. The input IPA was re-verified against the pinned hash before selected callback disassembly and then removed.

**No Apple SDK compilation, real release upload or 0.13.2 device test here.** Source/C tests and static inspection cannot establish native runtime safety or successful card removal.
