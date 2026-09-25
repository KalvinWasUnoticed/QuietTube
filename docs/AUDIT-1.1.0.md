# 1.1.0 logging rebuild — audit and test evidence

## Release status

Complete source package, **not a compiled or device-validated IPA**. Linux checks were executed; macOS Foundation tests and the full Apple SDK build are configured but could not be executed here. Native runtime/UI validation is a release gate, not something source review can replace.

## Scope reviewed

All pre-existing Objective-C implementations were compared with 1.0.2. Changes to those files are enumerated in `tests/fixtures/diagnostics-delta.json`: logging imports/calls, manual observer admission, UI actions, startup notification registration and a bounded general-counter overflow bucket. Tests reverse only these explicit deltas and then verify the original frozen hashes. A direct comparison against the actual prior source tree also passed. The player constructor suffix, feed classifier/scanner, insertion policy, settings model, preference initializer, logo and original native call/result/error paths remain protected.

New modules:

| Module | Responsibility / review |
|---|---|
| QTDiagnosticLog.h/.m | Transient manual session state, fixed schema, finite numeric/identifier validation, private directory, serial asynchronous writes, file/type/size checks, rotation, recent-record validation, replay redaction, overload/error-reserve policy, error-chain bound, export and clear ordering. No preferences or network APIs. |
| QTDiagnosticPolicy.h | Shared executable C policy for admission, overflow-safe byte bounds and finite timestamp expiry. Used by production storage, not a duplicate test implementation. |
| QTDiagnosticsBridge.h/.m | Read-only observations using the existing signature-checked getters. Closed graph edges, depth/node/array bounds, shared sample budget, class/template metadata and explicit marker presence. Unknown content does not change filtering decisions. |
| QTObservationAccess.h | Foundation-only declarations matching the existing core getter interfaces exactly, allowing the new observer to be exercised with native mocks on macOS. |

Existing interfaces reviewed: immutable launch preferences; master gating; absent-only defaults; player atomic latch; native fallback and error forwarding; scoped feed insertion/result/error-pointer forwarding; copy-before-edit feed cleanup; native logo reset/reentrancy; background/autoplay hooks; legacy trace ownership/windowing; settings navigation/preview/apply/dependencies/notices; packaging/download/publish guards and fork-only policy. See [function inventory](FUNCTION-INVENTORY.md) for entry points and [diagnostic behavior](DIAGNOSTICS.md) for actual coverage limits.

## Findings addressed

- General session counters could grow for arbitrarily many distinct error-code keys: now at most 128 distinct keys plus one overflow bucket.
- An observer must not bypass the supported-version guard: manual startup checks 21.38.2 before calling the existing installers.
- Manual observation must not silently enable legacy tracing: legacy capture still checks its original flag; the new observer has its own temporary admission state.
- Error events can be crowded out by feed traffic: reserved queue/rate capacity, with overload counts and no claim of lossless capture.
- Expired/corrupt records must not leak through replay: export prunes and re-sanitizes; incomplete lines are discarded. File reads are bounded and nonregular log files are rejected.
- Clear must not race earlier writes: recording is disabled before deletion is enqueued on the same serial queue. A later explicit Start is a new session.
- Cache eviction can remove the directory: the writer recreates its private directory when absent and rejects a replacement non-directory/symlink.
- UI export uses asynchronous completion, main-thread presentation, weak controller ownership, a per-page busy guard and an iPad popover anchor. Disk errors are reported, not echoed with paths or raw exception text.

## Locally executed checks

- **117 Python tests**, including source/ABI/preservation checks, settings/preference policies, module/interface wiring, privacy-schema guards, diagnostics admission/order guards, downloader/publisher mocks, packaging and 5,000 malformed Mach-O header mutations.
- **Six ASan/UBSan C suites**: original 79 classifier + 20 scanner fixtures and 10,000 random inputs; 32 ad-state combinations; 26 insertion-policy checks; 100,000 structured mutation cases; new **20,000 diagnostic admission combinations + 300,000 size checks** and expiry/nonfinite/overflow boundaries.
- Workflow actionlint, shell syntax, source integrity, local documentation links and final ZIP extraction/retesting.

These are test-case counts, **not complete branch coverage, a security proof or proof of YouTube hook execution**. Python source checks do not execute Objective-C.

## Native tests added — pending macOS execution

The push/PR macOS job and manual IPA job run `scripts/test_native.py` before compiling the iOS library:

- Actual Foundation logger: off/start/stop; schema redaction; 1,000 concurrent calls; error reserve after a flood; export stability; expiry/corrupt tails; disk rotation limits; unrelated-file preservation; preservation of temporarily unreadable records (non-root test runs); clear and storage failure.
- Actual observer with mock native objects/getters: inert off path; Playables and ad-marker clues; payload immutability; bounded getters; oversize/nil/throwing inputs; mutation/player entry points. Mock objects do not validate real YouTube schemas or ABI behavior.
- Existing actual settings-model harness and initializer tests, including 80 reader processes over 16 full 17-flag patterns. Deterministic test flushes do not establish iOS force-kill durability.
- Full iOS build/sign step covers all Objective-C modules and UIKit integration. It is still **unrun here**.

## Required device acceptance

1. Both Source checks jobs must pass; build the exact fork IPA and verify version/commit/checksum. Do not remove checks to get an artifact.
2. Preserve app data on upgrade. Recheck all ON/OFF choices over repeated full reopens; fresh disposable installs should still start master/video/feed protection ON.
3. Before starting logging, verify no event files grow and ordinary player/feed behavior remains normal. Start a session; reproduce one issue; stop; export; verify timing, drop/failure counts and useful clues.
4. Test with player/feed blocking individually off and on. Logging must not enable either or change saved preferences. Missing player-factory observations when its hook is absent are expected.
5. Test minimize/restore, feed insertions, Playables/unknown content, ordinary errors if naturally encountered, background audio, native PiP, sign-in, logo and all existing cleanup. Never assume a sampled mask is causal evidence.
6. Close/reopen: recording must be off, previous recent files exportable unless iOS evicted them. Clear while events are queued; wait for completion, export to check deletion/failure status. Explicitly start again if desired.
7. Exercise share/cancel, back/Done while export is pending, light/dark, larger text and iPad anchoring where available. Measure playback/frame/battery impact with logging off and on.
8. Retention, storage-failure/locked-device behavior and abrupt-exit loss need on-device checks. No termination/crash-handler or last-event durability guarantee is made.

The older [1.0.2 audit](AUDIT-1.0.2.md) is historical. Its uncapped-counter and deferred-logger notes are superseded here; its native/device caveats remain applicable. Expanded capture still does not mean every app event, every server experiment or every new ad is understood.
