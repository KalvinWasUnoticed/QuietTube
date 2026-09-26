# Contributing

I want QuietTube to stay focused on watching. Another tweak having a feature is not, by itself, a reason to add it here.

## Run the checks

Python 3.11+ and a C compiler:

```sh
bash scripts/check.sh
```

That checks the source manifest, runs the Python tests and six C suites under AddressSanitizer/UndefinedBehaviorSanitizer, and checks shell syntax. On macOS it also runs the Foundation tests through `scripts/test_native.py`.

The iOS library needs macOS and Xcode’s iPhoneOS SDK:

```sh
bash scripts/build.sh
```

Push/PR CI has Linux and macOS jobs. The macOS job runs the native tests and compiles the library. Both manual release flows check and compile before publication; the IPA flow does so before downloading its base. None of this replaces a device test.

## Don’t hide a regression with a new hash

`release-manifest.json` catches incomplete or mixed uploads. It is not an authenticity signature. Intentional source changes need reviewed hashes; an unexpected mismatch needs investigation.

`tests/fixtures/preservation.json` is a different guard. It protects runtime code, the player constructor and accepted hook boundaries. `native-abi.json` records method/ivar metadata, not disassembly. Do not regenerate those baselines just to make a failure pass.

The logging changes are listed in `diagnostics-delta.json`. Tests reverse exactly those additions before comparing the earlier runtime hashes. Expanding that list to conceal an unrelated behavior change defeats the test.

## Keep these contracts

- Keep preference keys and saved choices. Do not reset them on upgrade or save a switch off from a playback-error callback.
- Preserve the session safety latch, thread-local insertion scope, native return values/error pointers and exception forwarding.
- Let unknown content pass. Preserve copy-before-edit and the nonempty top-level presentation safeguard.
- Leave native PiP/sign-in behavior alone. Keep QuietTube’s settings sheet separate from YouTube’s private navigation layout.
- Switches save for the next launch; they do not install hooks live. The explicit manual diagnostic action has its own observation path and version guard.
- Use `QTSettingsModel` for labels, dependencies and preset bundles. Ordinary toggles should not create confirmation dialogs.

A runtime change needs a reason, an ABI review, regression checks and device evidence. Documentation work is not a reason to refactor hooks.

## What the tests establish

The preceding distribution package passed **128 Python checks** and **six C sanitizer suites**, including synthetic packaging/publication failures and bounded mutation tests. The detailed counts and limits are in the [1.1.0 audit](docs/AUDIT-1.1.0.md); keep historical results tied to the version that produced them.

The Foundation initializer tests cover fresh, legacy and partial stores, plus 32 combinations over 20 reinitializations. Separate-process tests use 16 full 17-flag patterns and 80 reader launches. They explicitly flush the test suite for deterministic ordering; that does not prove iOS force-kill durability.

The settings tests run the real model with a recording stub at its write boundary. Logger tests run the actual Foundation implementation; observer tests use mocked native getters. Linux checks their shared C policies and source constraints, not Foundation or UIKit.

Earlier device evidence came from iPhone 14 / iOS 26.5 / LiveContainer 3.8.0, installed through SideStore. Ad blocking, sign-in, native PiP, background audio and the RC1 settings worked there. An observed feed transaction withheld an explicitly marked entry without a later insert notification/card. That is evidence for that path, not every ad.

The maintainer later reported a successful standalone 1.1.0 dylib build/release on GitHub. Do not confuse it with the earlier local checks or a fresh device test of all logging/UI behavior.

## Before publishing a behavior change

Build the exact artifact, verify its commit/checksum and keep a working backup. Test saved off/on values over full restarts, preset cancellation/Apply, dependency toggles, navigation, notices and large text/light/dark layouts. Check playback, feed insertion, sign-in, native PiP and background audio on the installation method you claim to support.

For logging changes, check start/stop/export/clear, storage errors, dropped events and callback overhead. Reports contain identifier clues; allowed fields are not a promise of anonymity.

## Repository boundaries

Keep active sources, tests/fixtures, scripts, docs/artwork and required notices. Do not add proprietary app binaries, credentials, signing data, raw captures or disassembly dumps. Don’t restore retired stub modules or built-in base-app URLs.

IPA publication stays fork-only with acknowledgement. The separate dylib-only flow also permits the original repository and a per-run prerelease choice. Both rules are deliberate. [Release flows](docs/RELEASE-FLOWS.md).

Keep `LICENSE` and third-party license notices intact. The [maintainer guide](docs/MAINTAINERS.md) covers source replacement and remote cleanup.
