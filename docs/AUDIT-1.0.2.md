# 1.0.2 audit — historical record

This records the checks made for 1.0.2. Later logging changes and counter bounds are in the [1.1.0 audit](AUDIT-1.1.0.md). A later successful build does not change what ran during this audit.

## Environment at the time

These checks ran on the source package without an Apple SDK. No newly compiled library was loaded into YouTube. Source comparisons and synthetic tests do not establish private-hook compatibility or uninterrupted playback.

### Findings and changes

1. **The 1.0.1 missing bracket was a test compilation bug.** The corrected statement is retained. A source delimiter check now catches that class of mistake early; it is explicitly not a compiler.
2. **CI previously missed the platform that builds the product.** Push/PR checks now run on Linux and macOS. macOS runs Foundation tests and compiles/signs every production Objective-C module with the iPhoneOS SDK. Manual IPA builds now do those checks before downloading an input app. Selected interface/compiler errors are fatal. This is configured, not a claim those new jobs ran here.
3. **Settings testing was too dependent on source text.** The existing model now imports a Foundation-only header; UIKit is explicitly imported through the native core header at the UI boundary. No settings-model function body changed. A new macOS test program executes the real catalog, toggle dependencies, preset preview/application, known-key write restriction and read path. Its QTSet boundary is a recording stub, not the production disk writer.
4. **Preference tests previously reopened objects, not processes.** A new test program exercises the real initializer with 16 complete patterns across all 17 flags and 80 separate reader launches. It also checks unrelated values survive. It explicitly flushes its isolated macOS suite, so it is not an iOS force-kill/storage-durability test. The original fresh/legacy/partial-store and 32 × 20 reinitialization tests are retained.
5. **Mach-O input validation accepted malformed known-command layouts too far into parsing.** The packager now rejects short encryption/dylib commands, invalid name offsets, missing name terminators and non-MH_EXECUTE input to injection. Exact base SHA256 remains mandatory. Parser and actual binary-writing/extraction logic retain old-byte protections; only validation was intentionally changed.

### Locally executed

- **104 Python tests:** source/ABI guards, settings and preference policies, integrity, packaging, mocked download/release failures, synthetic end-to-end pipeline, module inclusion and CI wiring. Includes **5,000 deterministic Mach-O header mutations** that must reject safely or preserve executable content outside the header.
- **Five C executables, ASan + UBSan:** 79 classifier fixtures + 5,000 random inputs; 20 scanner fixtures + 5,000 random inputs; all 32 ad-state combinations and inactive-session regression; 26 insertion-policy checks; **100,000 structured mutation cases** with determinism, bounds, capacity, duplicate elimination and input-immutability properties, plus maximum-size/null boundaries.
- Shell syntax, workflow actionlint, release hashes, local documentation links and source comparisons.
- Final ZIP is separately extracted and checked again before delivery.

The numbers count executed cases, not function/branch coverage. Mutation tests used deterministic inputs, not coverage-guided fuzzing. They are not a security proof. Python source checks do not execute Objective-C.

Function-by-function entry-point inventory: [runtime functions](FUNCTION-INVENTORY.md).

### Module/interface review

| Area | Functions/contract reviewed | Evidence and boundary |
|---|---|---|
| Core | option catalog, initialization/snapshot, QTOn/QTSet, type normalization, getters, hook installation, counters, capture/reset/report, constructor retries, restart comparison | Preserved function bodies; source guards. Main-queue bounded installation attempts; raw saved choices distinct from effective master-gated flags. Native execution pending. |
| Preferences | absent-only initialization, old-marker recognition, explicit false, first-install defaults | Source guards passed; actual Foundation execution configured but pending. Local data deletion/new containers cannot preserve choices. |
| Player | typed native no-op construction, scope/delegate/ABI guards, fallback, atomic session pause, error/report handling | Player suffix byte protection and ABI/source checks passed. Native error forwarding retained. No retry/seek/new player substitution strategy. Existing players are not repaired by the latch. |
| Feed insertion | exact-class/explicit-marker decision, batch limit, copied entries, synchronous thread-local scope, native result/error forwarding, finally restoration, counters/report | Policy C tests and source/ABI guards passed. Unknown/unmarked entries pass; native hook execution and server-pushed elements untested here. |
| Feed cleanup | closed getter/setter edge list, copy-before-edit, shelf titles, Mix destinations, template masks, node/depth guards, top-level nonempty fallback | Production C classifier stressed; Objective-C traversal preserved and source-reviewed, not dynamically exercised. Heuristics can miss new formats or match nested content. Large native graph performance is not measured. |
| Other playback | background playability flags, automatic-next actions, playback-error forwarding | Existing scoped hooks and off-path behavior protected. Native PiP/sign-in have no added replacement hooks. Device regression required. |
| Logo | scoped native default reset, main-thread/reentrancy/ABI guard, finally reset, original fallback | Byte preservation + inspected-ABI/source checks. Rendering not tested here. |
| Settings model | all 16 option rows + master, dependencies, presets, titles/groups, saved reads, allowed writes | Static guards passed; actual Foundation model test program pending macOS. Enabling some options intentionally also enables dependencies; disabling does not erase dependent choices. Presets/support setup are explicit user changes. |
| Settings UI | owned navigation sheet, pages, switches, restart/pause footer, preview/cancel/apply, notices, reports, reset confirmation, native General-row injection | Existing navigation/integration protected. UIKit compile gate configured. Touch layout, accessibility, dark/light, large text, cancellation and animation need device checks. |
| Diagnostics | bounded mutation window and samples, template-name capture, numeric/allowlisted errors, shared insertion owner, prepare action | C scanner stress + source/privacy guards passed. No raw payload dump, network capture or upload added. Not an all-events logger. |
| Distribution | URL/DNS/redirect/hash/size/time checks, extraction, ARM64 commands, injection, signing handoff, exact artifact publication | Mocked/synthetic tests and YAML lint passed. No live network-download/publish or Apple build was run in this audit. Fork/acknowledgement restrictions unchanged. |

### Limits recorded in this audit

- No Apple compilation, native Foundation execution or UIKit/native hook run happened in this environment. The new macOS jobs must pass; merely adding them is not test evidence.
- General session counters are aggregates, not an all-events history. Their dictionary is not hard-capped against arbitrarily many distinct native error codes. Bounded trace rings do not imply every diagnostic structure has a strict byte bound. A future logger expansion should address this explicitly and remain privacy-limited.
- Safety pause affects future player/scoped insertion calls; it is not a universal switch for every independent feed-cleanup rule. It does not mutate saved settings or repair existing native objects.
- URL validation does not pin the eventual connection's resolved address; it is not an SSRF-proof claim. Exact hash pinning and isolated CI still matter.
- Input archive extraction is protected by exact input hash and path checks, not a general-purpose ZIP-bomb sandbox. Do not remove the pin and treat arbitrary IPAs as equivalent.
- Third-party installers, account authentication, native PiP, background playback and new server-side features need actual-device evidence. Prior maintainer evidence is not fresh 1.0.2 validation.
- This pass does not implement the proposed expanded logger. Nor does it broaden blocking rules, alter hooks or allow upstream publishing.

## Acceptance checklist for the exact built IPA

1. Commit this complete source tree. Confirm both Source checks jobs pass, including Foundation tests and the iOS compile/sign step on macOS.
2. Run the manual fork build with your authorized pinned base. Confirm the run's exact IPA, version/commit metadata and SHA256; do not reuse an older release by mistake.
3. Upgrade while preserving app/container data. Check every saved switch, including deliberate OFF values. Cycle full stop/reopen at least 10 times; verify all choices, not just the effective ad state.
4. Separately use a fresh disposable app/container: master/video/feed blocking must start ON. Do not delete your main installation merely to test defaults.
5. Exercise every settings group, quick toggles, preset cancel/apply, dependent options, master off/on, restart footer and reset Cancel. Confirm no unexpected changes to background/autoplay choices from presets.
6. Check ordinary playback, minimize/restore, feed insertion, Mix/Watch again/Playables toggles, logo, sign-in, background audio and native PiP. On a playback error, capture the report; saved ad protection must remain ON while session pause is explained. Do not induce dangerous failures or assume logs prove causal ad identity.
7. Check light/dark, larger text, modal close/back, notices, reports and reset in a disposable setup. Keep a known-working IPA and data backup.

A failed stage blocks release for that configuration. Changing a preservation hash or removing a test does not fix it.
