# QuietTube 0.13.4 — inspect the observed post-collapse insertion

**Source + GitHub build workflow, not an installable IPA.** Same pinned YouTube 21.38.2 base.

## What your 0.13.3 report established

All seven test prerequisites were active. Five native no-op player coordinators were supplied. The companion observer again received zero callbacks. Your screenshot still shows a sponsored card with the floating miniplayer.

The new trace observed this sequence:

```
+0.000s didCollapse — YTWatchLayerViewController
+0.403s applyMutationOperation:error: — YTAppCollectionViewController
+0.403s handleInsertItemSectionContent:error: — YTAppCollectionViewController
+0.403s didInsertEntries:atIndexes: — one YTIElementRenderer
```

This is a concrete candidate path to inspect, not proof that every item inserted by this method is an ad. `YTIElementRenderer` is shared by normal content too. Blocking all calls or clearing the whole array is not justified.

## Corrections and focused inspection

- **Fix our signature-checker mismatch:** the core checker normalizes native `q` and `Q` to `Q`. The two 0.13.3 trace registrations incorrectly requested lowercase `q`. They now request `vQ`/`vQQ`, retaining the binary-verified signed 64-bit native wrapper parameters. A regression check compares all nine registrations with normalized binary encodings.
- Use collapse completion as the timing-window fallback when collapse start is not observed. The report labels the actual anchor. No more misleading “relative to start” label when no start ran.
- At the **observed insert notification**, inspect only exact `YTIElementRenderer` entries in the collapse window: ad-logging-field presence, payload size, existing classifier mask and up to eight internal template-name candidates. These are included directly in the short report, independently of the older global element-capture quota.
- Detail sampling is capped at six entries/window, three entries/call and 256 KiB/entry. No model serialization, graph traversal, raw bytes, title fields, video-ID fields or URLs are printed. Internal template candidates are lexical clues, not decoded renderer roots or an automatic deletion verdict.
- Keep the Prepare button, flag snapshot reporting, 24-event prehistory / 96-event timeline and 12-second window. Remove stale previous-window history on a fresh anchor.

**This revision still passes through insertion operations; it is not a claimed card-removal fix.** Its purpose is to distinguish a recognized ad bypassing the existing presentation filter from an as-yet-unrecognized template on the now-observed path. The report states unavailable getters/missing payloads instead of treating them as “not an ad.”

## Preserved

The player construction/fallback block is byte-for-byte unchanged from 0.13.1–0.13.3. The positive player-ad/stability report was for 0.13.1; later reports confirm substitutions but do not establish universal safety. Existing companion behavior, accepted feed cleanup, logo, native PiP/background, sign-in-related code and settings navigation are unchanged. No retired broad filter or player response/request manipulation is restored.

## Build and one test

1. Replace repository contents, including hidden `.github`, Sources, tests and evidence files. Commit and start a **new workflow run**.
2. Download `QuietTube-0.13.4-21.38.2.ipa` from **Summary → DOWNLOAD IPA — QuietTube 0.13.4**. Private downloads require authorized GitHub login; public publication requires explicit approval.
3. Import into the same LiveContainer data container without a second injection. Keep the previous IPA for rollback.
4. Tap **You → Settings → General → Quiet controls → Prepare ad test** and fully stop/relaunch the guest. This saves only the seven test prerequisites; unrelated settings are preserved. Local class/template inspection is enabled. It is not an automatic upload.
5. Play a video, swipe down once, wait about 12 seconds, then copy **Advanced → Ad test report**. Avoid further swipes/scrolling before copying. Send only that report and card/player outcome; no full diagnostics or two-run matrix.

## Safety and validation

The existing observed-playback-error latch remains; it saves the profile OFF for future calls, not repairs existing players. Restart after errors. Prepare explicitly saves the profile ON for a fresh test. Revert if crashes/stalls occur. New inspection does not suppress or retry native mutations/exceptions.

62 Python source/ABI/packaging/release checks pass clean and overlaid onto 0.13.3; frozen player/cleanup hashes pass. The new signature regression check rejects the erroneous 0.13.3 registrations. C classifier/scanner/status tests pass under ASan/UBSan. Shell/workflow YAML/package checks pass.

**No Apple SDK compilation, real cloud release or 0.13.4 device test here.** No guaranteed blocking, stability or undetectability claim.
