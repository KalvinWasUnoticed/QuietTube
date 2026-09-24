# 0.13 audit

## Intent and scope

User requested fewer manual test cycles, stronger troubleshooting and actual targeted workarounds. One default-off adTest profile enables two default-on subordinate options. Normal testing needs one switch/restart and one short report. Branch overrides are only in Advanced → Ad test options. Existing working flags are not reset. Legacy failed experiment keys are not registered or read; a retired source stub and replacement old test filenames make overlay upgrades safe.

## Corrections

0.12's getter-installed message was false on subsequent delayed install attempts, because before/after IMP equality meant already-installed rather than failure. Persistent per-branch installation flags now distinguish success/retries. Three missing-config factory events mean no-op selection was NOT demonstrated. That getter and thread-local config scope are removed. The inactive insertion method hook is removed.

## Player workaround

Uses the exact verified no-op initializer with typed Objective-C init-family dispatch for ARC, original factory delegate and read-only object_getIvar of the verified scope ivar. Rejects unavailable/wrong constructor encoding or non-object ivar. Native no-op result checked before returning; no valid result/missing prerequisites/constructor exception calls original factory once. Original exceptions remain visible. No synthetic nil, no response arrays, no serialized config writes, alternate-client requests, fake callback invocation, retry/seek loop or signal suppression. It bypasses original factory side effects on success; native construction is not proof of safe semantics for every stream or server state.

## Feed workaround

BOOL feature getter enableWatchWhileFeedMutationOnIos returns NO while profile is effective, leaving native disabled-path handling intact. Static ad-adapter initializer evidence and getter signatures recorded. This is a feature-wide setting, so other readers may be affected. No UI hiding, generic metadata/title/link matching, broad model-load edits or arbitrary insert/replace result fabrication. Does not guarantee all companion/ad surfaces are covered.

## Safety / reporting

C atomic safety latch on observed NSError; profile saved OFF for next launch and new hook invocations forward to native after trip. Current no-op objects are not replaced; the failed player still requires restart. Native error handler is always forwarded. Crashes/stalls or other error paths may not trip. Failed saving reports need for manual disable. NSError chain max3, allowlisted domain categories + code only. Fixed-label event totals and rolling last80 relative-time events, bounded report, no objects/IDs/URLs/response dumps persisted or transmitted. New logging is separate from already capped template capture.

## Preservation / local checks

Based on 0.10. Existing pure C feed classifier/scanner, logo module, background/native PiP, authentication/network behavior, settings navigation and array safeguards retained. New integration adds observer/report and profile installer; direct IPA workflow versioned0.13 with visibility/success gates preserved. Old baseline comparisons normalize only explicit new blocks and UI/version/report changes, then hash remaining source/build content.

51 Python tests passed clean and after overlay onto 0.12 (8 packaging,6 mocked release,37 source/ABI/scope checks). Retired-test filenames overwritten, avoiding the 0.12 stale-file failure. C ASan/UBSan:79 classifier fixtures+5000 iterations and20 scanner fixtures+5000 iterations. Shell syntax passed; YAML/archive checked. Metadata/selected disassembly inspected from re-verified pinned binary; downloads deleted afterward.

No Apple SDK compile, device execution or real release upload for0.13 here. Tests do not prove ARC lifetime, native semantic safety, ad-free playback or absence of regressions. No zero-error/undetectability promise. The change in strategy is concrete but still requires a device result.
