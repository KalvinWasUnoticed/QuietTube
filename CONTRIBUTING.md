# Contributing

Keep QuietTube small, readable and focused on watching. Do not add unrelated features merely because another enhancer has them.

## Check a change

Use Python 3.11+ and a C compiler:

```sh
bash scripts/check.sh
```

This runs the release-integrity guard, Python source/packaging/distribution tests, four C suites under AddressSanitizer/UndefinedBehaviorSanitizer and shell checks. Native compilation requires macOS/Xcode's iPhoneOS SDK, locally through `scripts/build.sh` or through the manual Actions workflow. Actual iOS behavior requires device testing.

`tests/fixtures/preservation.json` protects the tested runtime (version labels normalized), player constructor suffix and accepted integration boundaries. `native-abi.json` contains only method/ivar metadata used by current ABI tests, not executable disassembly. **Do not regenerate preservation hashes just to make a failure pass.** A runtime change needs a separate rationale, ABI review, regression tests and device evidence.

The release manifest catches mixed uploads; it is not a trust signature. Intentional source changes require a reviewed manifest update after tests are updated. It must not be used to bless accidentally restored old code. The runtime-preservation baseline is a separate safeguard.

## Preparation validation

The final preparation suite passes 87 Python checks. The current validation includes a synthetic download → package → release-command round trip, mocked HTTP/GitHub failure cases, source/runtime preservation checks and four C sanitizer suites: 79 classifier fixtures + 5,000 random iterations; 20 template-scanner fixtures + 5,000 random iterations; 32 status combinations + an inactive-session regression; 26 insertion-policy checks. Workflow YAML and actionlint, shell syntax, relative documentation links, the source manifest and ZIP integrity were checked. No proprietary base or real GitHub build was used for these final preparation tests.

## Scope of this release

Every compiled runtime module is retained from the tested RC1 baseline, apart from release-label text; settings descriptions now use installer-neutral wording and the About copy describes the confirmed test environment. Do not refactor hook logic during documentation/distribution work. Keep preference keys and defaults stable. Use QTSettingsModel for public labels, prerequisite changes and preset bundles.

Preserve the safety latch, thread-local feed scope, unknown-content pass-through, native results/errors, nonempty-section safeguards, native PiP/sign-in behavior and settings-sheet navigation. No reset on upgrade, no live hook installation from switches and no confirmation dialog for ordinary toggles.

## Test evidence and limits

Maintainer-reported: iPhone 14 / iOS 26.5 / LiveContainer 3.8.0, installed through SideStore; ad blocking, Google sign-in, native PiP, background audio and the RC1 settings worked. One captured feed transaction explicitly withheld an ad-marked entry and produced no subsequent insert notification/card. This is limited device evidence, not an all-ads/all-devices guarantee.

Before tagging/publishing, run the fork IPA workflow with an authorized pinned base, verify the release IPA metadata/hash, and test navigation, fast toggles, preset cancellation/Apply, light/dark/large text, restart state, player/feed behavior, native PiP/background and sign-in. Keep a working local backup. The new fork IPA pipeline was not executed on GitHub during repository preparation. Mocked release commands do not prove live permissions, macOS compilation or successful publication.

## Repository hygiene

- Keep active sources, build/packaging helpers, tests/fixtures, concise docs, referenced graphics and required notices.
- Do not restore a built-in base download URL, upstream-repository publication, development diaries, disassembly dumps or retired stub modules. The current publisher is restricted to the invoking fork and explicit acknowledgement.
- Do not commit proprietary app binaries, compiled libraries, credentials, signing data or personal diagnostic captures.
- Third-party license notices are intentionally retained even when not compiled. They are not disposable build residue.
- For maintainer publication and old-release cleanup, see [docs/MAINTAINERS.md](docs/MAINTAINERS.md).
