# 0.12 — separate tests and report

The failed 0.11 runs are already recorded; do not repeat suppression of coordinator creation. Use 0.10 if rollback is needed. Restart the entire guest between configurations; template reset does not reset session counters.

## B: native no-op player only

playerExperiment2 ON, insertionAds2 OFF. Existing playerProbe may be ON. Observe actual playback, preroll/midroll, duration before an error, seeking, background audio and native PiP. Stop at first error/stall.

Report these NEW signals plus visible outcome:
- Hook status: YTIIosPlayerConfig / useNoOpAdsCoordinator.
- Hook status: YTRealAdsPlayerServices / adsPlaybackCoordinatorWithOverlayManager:delegate:parentResponder:contentPlayerResponse:.
- player test 2 native factory entered.
- player test 2 scoped no-op flag read.
- player test 2 native no-op coordinator returned.
- player test 2 missing config — native selection, other coordinator returned, or native factory returned nil.
- Any unavailable-getter / not-installed message and playback error counters.

Interpretation: requested flag alone is insufficient. Factory calls without flag reads mean the object/path is not being selected as intended. A returned native no-op object proves selection, NOT ad removal/stability. Error code 0 alone does not distinguish state failure, media/network problems or server enforcement. If errors occur, disable and restart. If UI unavailable revert to 0.10; it ignores test 2 keys. Reinstalling 0.12 later may restore saved ON state.

## C: insertion filtering only

playerExperiment2 OFF, insertionAds2 ON, feedAds/extendedFeed ON. Tap Home video, minimize, inspect card. Check ordinary feed/search/subscriptions/navigation too.

Report:
- Hook status: YTInnerTubeCollectionViewController / insertBelowVisibleSection:.
- post-play test 2 insertion entered, insertion forwarded, ad insertion suppressed.
- explicit ad field / explicit ad logging / existing ad tokens / display ad tokens counters.
- unsupported input or inspection exception counters.

No invocation: wrong path for that test. Forwarded inputs: no recognized ad; not proof there was no ad. Suppression: a recognized insertion was skipped, not necessarily the pictured card. Unknown and multi-item inputs are intentionally retained. No title/metadata/sponsor-button fallback.

If fresh capture is needed, clear it immediately before reproduction; old reports reached the 128-sample cap. Review reports before sharing. No raw playback payloads, request bodies, signed URLs, cookies or tokens are logged. A crash may prevent error-counter capture. There is no auto retry, automatic recovery or telemetry falsification.
