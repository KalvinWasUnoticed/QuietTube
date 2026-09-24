# 0.13.1: one switch, one restart, one report

Use Playback → Ad test profile ON. There is no Ad test options page and no branch setting to enable separately. If upgrading with this switch already ON, both workarounds now attempt to activate after the guest is fully restarted. Old branch OFF preferences are ignored.

Play a video, minimize it, observe the pushed card. Watch beyond the previous failure window if playback is stable. Send Advanced → Ad test report plus:
- Player ad seen: yes/no/not enough opportunity.
- Card pushed after minimizing: yes/no.
- Playback: worked/error/stall and approximate time.

Report stages:
1. Profile requested this launch.
2. Installation state: OFF / SAFETY STOP / WAITING-UNAVAILABLE / PARTIAL / BOTH HOOKS INSTALLED.
3. Player factory invocation and number of valid native no-op objects supplied.
4. Feed feature getter reads returning disabled.

Stages 2 and 3 are not proof of removing an ad. Zero substitution/getter-read counts explicitly indicate unobserved workaround activity. Missing ads while hooks are absent must not be counted as blocking success. This was the issue in the latest 0.13 run.

On an observed error, the safety latch saves the profile OFF, without resetting feed/audio/appearance flags. Restart; current player state is not repaired. Stalls/crashes can bypass the observer: disable manually or revert to 0.10. A new run's short report is enough; no repeat of the supplied 0.13 counters is requested.
