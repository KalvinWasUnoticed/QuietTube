# 0.11 test report — two independent experiments

Keep existing flags constant. Fully stop/relaunch LiveContainer's guest between runs. Session counters reset on process restart; Clear template capture does NOT reset counters.

## Run B: player test 1 only

Settings: playerExperiment1 ON; companionAds OFF. playerProbe may remain ON, but suppression takes precedence. Diagnostics must say TEST 1 — coordinator suppression.

Record:
- Video played / stalled / showed error / crashed?
- Preroll or midroll actually seen? Approximate uninterrupted playback duration?
- Seeking, background audio, native PiP results?
- `player test 1 coordinator creation suppressed` counter.
- Any `playback error … code …` counter and the visible error text/time.

An installed hook or suppressed call is not proof of ad removal. Zero omitted counters mean no recorded event, not necessarily no failure. If it fails, stop and restore test 1 OFF + full restart; if settings are inaccessible, revert to 0.10. Restoring 0.10 leaves the unknown experiment flag stored but ignored; remember to turn it off if returning to 0.11. Do not keep retrying or change network/client settings to hide the failure.

## Run C: post-play sponsored cards only

Settings: playerExperiment1 OFF; companionAds ON; feedAds ON; extendedFeed ON. Diagnostics should report observation-only or native player mode.

Tap a Home video, minimize with a downward swipe, and inspect the card beneath the selected video. Compare with this new switch OFF. Record normal Home content and search/subscription behavior too, because the controller is shared.

Relevant NEW evidence:
- `YTInnerTubeCollectionViewController / loadWithModel:` hook status.
- `post-play model-load boundary invoked`.
- `post-play model-load input unsupported — kept original`.
- `post-play model-load changed`.
- `match post-play display-ad template candidate`.
- `empty model-load result prevented — kept original` or `model-load filter exception — kept original`.

A model-load hit is not proof of a post-minimize insertion; the hook can run for other loads. A format hit is not uniquely tied to a screenshot. If cards remain, clear template capture immediately BEFORE reproducing to avoid the already-observed 128-sample cap, then share only fresh groups and these new counters. Do not resend the old 0.10 capture as new evidence. Never block generic injection or video_metadata keys as a workaround.

## Stop conditions / privacy

Stop on crash, repeatable playback failure, missing ordinary content or navigation regression. Disable only the implicated new experiment, restart and compare. No automatic retries, error masking, crash recovery or server-side invisibility is implemented. Existing error observer forwards to YouTube unchanged. No raw player/request/response objects, signed URLs, cookies or tokens are logged. Review reports/screenshots before sharing.
