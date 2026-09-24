# 0.13 simplified test

Turn on ONLY the new **Playback → Ad test profile** switch, keeping normal defaults/working flags. Fully restart the guest. Play an ad-bearing candidate video, watch beyond the earlier failure window, minimize to Home and inspect the area below it. If stable, check seek/background/native PiP. Ad delivery varies; do not infer success from a single missing ad.

Send: **Advanced → Ad test report**, plus three observations:
- Player ads appeared: yes/no/not enough opportunity.
- Sponsored card pushed after minimizing: yes/no.
- Playback: worked, stalled or error (approximate time).

The report contains branch installation status and events including player factory called, native no-op coordinator supplied, original factory fallback reasons, and watch-while feed mutation disabled. No-op object count proves substitution only, not ad removal. Feed flag-read count proves the feature getter ran, not unique card removal.

On an observed playback NSError, the report shows SAFETY STOP; the profile is saved OFF and new calls use native behavior. Restart after an error. Current objects may remain altered until restart. No error seen by this hook means no automatic trip; turn off manually on a stall or roll back to 0.10 if crashing/settings inaccessible. Retired flags are ignored here; going back to older experimental builds could reactivate their saved keys.

Optional isolation ONLY if requested after reading the report: Advanced → Ad test options permits turning off one branch, then restart. No two-run matrix is required initially. Automatic safety stop switches off the single profile, not your working cleanup/audio flags.

No raw player data, URLs, credentials, userInfo dump or automatic uploads. Trace is in-memory and capped at 80 events, with fixed-label totals and numeric/domain-bucket error details (max three levels per error). Restart clears it. Template capture is separate and unnecessary for the initial report.
