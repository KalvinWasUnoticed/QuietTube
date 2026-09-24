# 0.13.2 — focus on the remaining companion card

Keep the existing Ad test profile ON. Restart the entire guest after upgrading. Play a video, minimize it, and inspect the area below the selected item. Keep 0.13.1 as the player-stable rollback build.

Send the short Advanced → Ad test report plus “card remains / card gone”, and flag any new player error. No additional switch or two-run matrix.

Expected evidence:
- Native no-op objects continue being supplied by unchanged player code.
- Companion observer hook installed.
- Companion callback received, with separate count for actual payload observed.
- Native clear applied and current-ad empty/remaining state afterward.

An installed hook with no callback is not an active fix. Empty observer state with a visible card means the actual card is not yet explained by this path. A clear applied to an already-empty callback does not count as a blocked ad. Counts are not unique cards or videos.

Safety: stop on errors or missing wanted content. The safety latch reacts only to observed playback NSError, not every possible UI exception/crash/stall. It saves profile OFF; restart is needed. Already-cleared companion state is not automatically restored. No error hiding, retry loop or request spoofing. Report is bounded/session-only; no IDs, URLs or raw payloads.
