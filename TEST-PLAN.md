# 0.10 — player experiment register

## Test 0: observe the ad coordinator, do not block

Known comparison: user reports 0.9.1 plays through ads without the earlier 10–20-second failures. Those failures came from other modifications, not the current paused player-ad mode. Detection is not established as their cause.

Variable: playerProbe OFF vs ON; all other flags and the same account/app/container stay constant. Both modes should still show ads. Restart the entire guest between modes. No stable ad delivery is assumed across repeats.

| Run | Probe | Expected | Record manually |
|---|---|---|---|
| A | OFF | Existing behavior; no new coordinator hook installed | Ad occurred? Ad-to-content transition worked? At least 5 minutes of content? |
| B | ON | Same playback; hook may be installed or reported unavailable | Hook status and counters; preroll/midroll actually seen; errors/stalls and approximate timing |
| B transitions | ON | Normal seek/background/PiP behavior | What worked/failed; whether any failure preceded or followed an ad |
| Recovery if needed | OFF after full restart | Return to prior behavior | Whether the failure stops; revert to 0.9.1 if necessary |

## What to share

- Version and ACTIVE THIS LAUNCH `playerProbe` value.
- `YTLocalPlaybackController / createAdsPlaybackCoordinator` hook status.
- `player probe coordinator call entered`.
- `player probe coordinator returned object`.
- `player probe coordinator returned nil`.
- Any `playback error YouTube code …` or `playback error other code …` counters.
- What you saw: ads, normal content, stall/error; approximate time into the video; foreground/background/PiP.

Zero-valued counters are omitted. Counts are process-session totals, not video or ad counts. Do not compare them to a different session without noting the restart. There is no probe reset control; restart for a fresh run. Existing capture-reset only clears feed capture, not these counters. A crash may prevent a report. Review any crash report before sharing; do not share tokens, signed media URLs or account data.

## How results determine the next step

- Unavailable/signature mismatch: do not force-install or guess a signature. Inspect the matching native executable or find a different verified entry point.
- Installed, no calls during observed ads: this method is not a demonstrated active boundary for the tested path. Do not assume suppression here will help.
- Calls with object returns: method is active, but this does not establish ad identity, coordinator necessity, or safety of returning nil.
- Nil returns while ads play: another path may exist; not evidence of blocking.
- Error with probe on but not off: halt mutation work and investigate the probe regression first.
- Stable observation and relevant activity: choose one explicitly opt-in blocking hypothesis for the next build. Do not combine coordinator suppression, response transformations and request changes.

The existing error observer always forwards to YouTube's original handler. This build makes no retry/seek/error-masking changes and contains no hidden blocking mode. No assumption that server-side detection caused prior failures. No promise of undetectability or uninterrupted ad-free playback.
