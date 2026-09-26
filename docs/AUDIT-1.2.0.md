# 1.2.0 audit and test record

This records the logging work, the linker correction and the later distribution update. Keep those stages separate. A successful build is not a device test.

## Build history

The logging package was prepared and checked on Linux. Its new Foundation tests and iOS build could not run in that environment.

The supplied GitHub run then passed the regression step, including the configured macOS tests, but failed linking on `CGRectGetMidX` and `CGRectGetMidY`. The new export popover used CoreGraphics; the build linked only Foundation and UIKit. Adding CoreGraphics fixed the missing dependency in the build configuration, and a regression check was added. No production source changed for that correction.

The maintainer later reported a successful standalone **1.2.0 dylib build and release**. That is later build evidence, not a retroactive Apple test of the original local package or proof that every new control works on-device.

The subsequent distribution package added the [two release flows](RELEASE-FLOWS.md) and reached **128 Python tests**. IPA publication remains fork-only; dylib-only publication is allowed upstream or in forks. The logging/linker results below retain their own counts.

## Code reviewed

Existing Objective-C implementations were compared with 1.0.2. `tests/fixtures/diagnostics-delta.json` records the intentional changes: logging imports/calls, manual observer admission, UI actions, startup notification registration and the general-counter cap. Tests reverse exactly those changes before checking the original hashes. A direct comparison against the prior source tree also passed.

The player constructor suffix, feed classifier/scanner, insertion policy, settings model, preference initializer, logo and underlying native call/result/error paths remain protected.

| New module | What was checked |
| --- | --- |
| `QTDiagnosticLog.h/.m` | Temporary session state, fixed field schema, finite numbers/valid identifiers, private directory, serial writes, file/type/size checks, rotation/expiry, export revalidation, queue/rate reserves, error-chain limit and clear ordering. No preference writes or network APIs. |
| `QTDiagnosticPolicy.h` | Admission, overflow-safe byte bounds and finite timestamp expiry. Production uses the same C policy that the tests execute. |
| `QTDiagnosticsBridge.h/.m` | Existing signature-checked getters; closed traversal edges and depth/node/array limits; shared sampling budget; class/template and explicit-marker observations. No new filtering decisions. |
| `QTObservationAccess.h` | Foundation-only declarations that match the core getter interfaces, so mock-object tests can call the observer on macOS. |

Existing interfaces reviewed included launch snapshots/defaults/master gating, the atomic player latch, native fallback/error forwarding, scoped insertion/error-pointer handling, copy-before-edit filtering, logo reentrancy, background/autoplay hooks, legacy trace ownership/windows, settings navigation/dependencies/presets/notices and packaging/download/publication guards. [Function inventory](FUNCTION-INVENTORY.md).

## Problems addressed

- Arbitrary error-code keys could grow the general counter dictionary. It now allows 128 distinct keys plus one overflow bucket.
- Manual observation could have bypassed the version guard. Startup checks 21.38.2 before calling the installers.
- Starting a session must not enable older tracing switches. Their original flags still govern that capture.
- Feed traffic can crowd out errors. Queue/rate reserves reduce that risk; drops remain possible and are counted.
- Export must not replay expired/corrupt data. It prunes and checks fields again, drops incomplete lines, limits reads and rejects nonregular log files.
- Clear must follow earlier writes. It disables admission before queuing deletion on the same serial queue. A later Start is a new session.
- Cache eviction can remove the directory. The writer recreates it when absent and rejects a replacement non-directory/symlink.
- Export finishes asynchronously, presents on the main thread, uses weak controller ownership and a per-page busy guard, and anchors the iPad popover. Failures are counted without printing paths or raw exceptions.

## Local logging/linker checks

| Check | Recorded result |
| --- | --- |
| Python | **118 tests**, including ABI/preservation, preferences/settings, interfaces, field restrictions, queue/order guards, download/publish mocks, packaging and **5,000 Mach-O header mutations**. |
| C under ASan/UBSan | **Six suites**: 79 classifier fixtures, 20 scanner fixtures, 10,000 random inputs, 32 ad-state combinations, 26 insertion-policy checks and 100,000 structured mutation cases. |
| Diagnostic policy | **20,000 admission combinations**, **300,000 size checks**, plus expiry/nonfinite/overflow boundaries; included in the six C suites. |
| Package/workflows | actionlint, shell syntax, source hashes, local links and checks repeated after extracting the ZIP. |

These are case counts, not complete branch coverage, a security proof or execution of YouTube’s private hooks. Python source checks do not execute Objective-C.

## Native test programs

The macOS jobs run `scripts/test_native.py` before compiling the iOS library. These were added during Linux preparation; do not describe them as having run locally then.

- The actual Foundation logger is tested for off/start/stop, allowed fields, 1,000 concurrent calls, error reserves after a flood, stable export, expiry/corrupt tails, rotation limits, unrelated-file retention, unreadable-file preservation on non-root runs, clear and storage failure.
- The actual observer is called with mock native objects/getters: off-path behavior, Playables/ad clues, payload immutability, read limits, oversized/nil/throwing inputs and mutation/player entry points. Mocks do not establish real YouTube schemas or hook compatibility.
- The settings model and initializer tests include 80 reader processes over 16 full 17-flag patterns. Test flushes make ordering deterministic; they do not prove iOS force-kill durability.
- The build/sign step compiles every Objective-C module and UIKit integration. The later reported successful dylib build is recorded above; device behavior still needs its own evidence.

## Required device acceptance

1. Pass both Source checks jobs, build the intended artifact and verify version/commit/checksum. Do not remove checks to obtain a file.
2. Preserve data during upgrade. Recheck saved ON/OFF choices over full reopens; use a disposable fresh install to check master/video/feed defaults.
3. With recording off, confirm event files do not grow and playback/feed behavior stays normal. Start, reproduce, stop and export; inspect timing, drops, failures and clues.
4. Test player/feed switches independently. Logging must not enable them or change saved preferences. No factory hook means no factory observations.
5. Check minimize/restore, feed insertion, Playables/unknown content, naturally encountered errors, background audio, native PiP, sign-in, logo and existing cleanup. A sampled mask is not causal evidence.
6. Reopen: recording must be off; recent files should remain exportable unless evicted. Clear with writes queued, wait, then check export/deletion failures. Start again explicitly if needed.
7. Check share/cancel, back/Done during export, light/dark, larger text and iPad anchoring where available. Measure frame/playback/battery impact with recording on and off.
8. Check retention, locked-device/storage failures and abrupt-exit loss. There is no promised termination callback, crash handler or last-event durability.

The [1.0.2 audit](AUDIT-1.0.2.md) remains a historical record. Its uncapped-counter and deferred-logger notes were superseded by this work. Expanded logging still does not capture every event, server experiment or new ad format. [Actual capture limits](DIAGNOSTICS.md).
