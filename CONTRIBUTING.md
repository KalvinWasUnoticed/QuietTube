# Contributing

Keep QuietTube small, readable and focused on watching. Do not add unrelated features merely because another enhancer has them.

## Check a change

Use Python 3.11+ and a C compiler:

```sh
bash scripts/check.sh
```

This runs the release-integrity guard, Python source/packaging/distribution tests, six C suites under AddressSanitizer/UndefinedBehaviorSanitizer and shell checks. Native compilation requires macOS/Xcode's iPhoneOS SDK. Push/PR CI now has a macOS leg that runs Foundation tests and compiles the iOS library; the manual IPA workflow does the same before downloading its base. Actual iOS behavior requires device testing.

`tests/fixtures/preservation.json` protects the tested runtime (version labels normalized), player constructor suffix and accepted integration boundaries. `native-abi.json` contains only method/ivar metadata used by current ABI tests, not executable disassembly. **Do not regenerate preservation hashes just to make a failure pass.** A runtime change needs a separate rationale, ABI review, regression tests and device evidence.

The release manifest catches mixed uploads; it is not a trust signature. Intentional source changes require a reviewed manifest update after tests are updated. It must not be used to bless accidentally restored old code. The runtime-preservation baseline is a separate safeguard.

## Preparation validation

The final preparation suite passes 128 Python checks. The current validation includes a synthetic download → package → release-command round trip, mocked HTTP/GitHub failure cases, source/runtime preservation checks and six C sanitizer suites: 79 classifier fixtures + 5,000 random iterations; 20 template-scanner fixtures + 5,000 random iterations; 32 status combinations + an inactive-session regression; 26 insertion-policy checks; 100,000 structured mutation cases with boundary, determinism and input-immutability checks. The diagnostic policy adds 20,000 admission combinations, 300,000 size checks and expiry/overflow cases. Python additionally mutates 5,000 Mach-O headers. Workflow YAML and actionlint, shell syntax, relative documentation links, the source manifest and ZIP integrity were checked. No proprietary base or real GitHub build was used for these final preparation tests.

## Scope of this release

The player constructor/fallback suffix, feed insertion/filter logic, logo and native integration remain protected. In 1.0.1 the preference initializer and safety-latch persistence policy deliberately change: missing defaults are initialized conservatively, and playback errors may pause only the current session without saving a user toggle off. The revised protection record documents these exceptions; it does not unfreeze the player/feed implementation. Do not refactor hook logic during documentation/distribution work. Keep preference keys and defaults stable. Use QTSettingsModel for public labels, prerequisite changes and preset bundles.

Preserve the safety latch, thread-local feed scope, unknown-content pass-through, native results/errors, nonempty-section safeguards, native PiP/sign-in behavior and settings-sheet navigation. No reset on upgrade, no background preference mutation from playback errors, no live hook installation from switches and no confirmation dialog for ordinary toggles.

## Test evidence and limits

Maintainer-reported: iPhone 14 / iOS 26.5 / LiveContainer 3.8.0, installed through SideStore; ad blocking, Google sign-in, native PiP, background audio and the RC1 settings worked. One captured feed transaction explicitly withheld an ad-marked entry and produced no subsequent insert notification/card. This is limited device evidence, not an all-ads/all-devices guarantee.

Before tagging/publishing, run the fork IPA workflow with an authorized pinned base, verify the release IPA metadata/hash, and test navigation, fast toggles, preset cancellation/Apply, light/dark/large text, restart state, player/feed behavior, native PiP/background and sign-in. Keep a working local backup. The new fork IPA pipeline was not executed on GitHub during repository preparation. Mocked release commands do not prove live permissions, macOS compilation or successful publication.

## Repository hygiene

- Keep active sources, build/packaging helpers, tests/fixtures, concise docs, referenced graphics and required notices.
- Do not restore a built-in base download URL, upstream IPA publication, development diaries, disassembly dumps or retired stub modules. IPA publication remains restricted to the invoking fork and explicit acknowledgement. The separately authorized dylib-only workflow also permits the original repository, with explicit acknowledgement and a per-run prerelease choice.
- Do not commit proprietary app binaries, compiled libraries, credentials, signing data or personal diagnostic captures.
- Third-party license notices are intentionally retained even when not compiled. They are not disposable build residue.
- For maintainer publication and old-release cleanup, see [docs/MAINTAINERS.md](docs/MAINTAINERS.md).

## Preference regression checks

`tests/test_preferences.m` links the actual Foundation-only initializer, tests fresh/legacy/partial stores and 32 on/off combinations over 20 reinitializations. `scripts/check.sh` executes it on the macOS build runner before the iOS library compiles. It is skipped explicitly on Linux; it has not been executed during this preparation. It is not an iOS multi-process/data-container test. Device checks should cover at least several full closes/reopens, both manual off values, a clean install and an upgrade. Preserve existing app data when testing persistence.

`python3 scripts/test_native.py` on macOS also executes the production settings model with an isolated write-boundary stub and runs the actual initializer across 80 reader processes for 16 complete 17-flag patterns. The subprocess probe explicitly flushes its isolated suite for deterministic ordering; it does not prove iOS force-kill durability. All new native tests remain unexecuted in this Linux preparation. Full audit: [docs/AUDIT-1.1.0.md](docs/AUDIT-1.1.0.md).

## Diagnostics review boundary

`diagnostics-delta.json` enumerates the intentional logging additions; preservation checks reverse exactly those deltas before comparing the old runtime hashes. Do not broaden this record to hide unrelated behavior changes. The real Foundation logger and observer (with mocked native getter boundary) are compiled and run by `scripts/test_native.py` on macOS. Linux executes their shared C admission/storage/expiry policy and source guards, not Foundation or UIKit. Capture privacy is schema-limited, not guaranteed anonymization.

Distribution changes are documented in [docs/RELEASE-FLOWS.md](docs/RELEASE-FLOWS.md). New publishing tests are mocked/synthetic; live release creation and fresh Apple compilation were not executed for this change.
