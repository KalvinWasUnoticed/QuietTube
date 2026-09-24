# Contributing

Use 0.13.5 as the device-tested runtime baseline. Settings/branding changes must not casually modify the player factory, scoped feed insertion, safety latch, accepted cleanup, native PiP/sign-in behavior or settings integration.

Run the Python suite and four C sanitizer tests. RELEASE-RUNTIME-BASELINE.json protects runtime files (version text normalized). Do not regenerate it merely to make a failing test pass. Changes to protected behavior require a separate rationale, native ABI evidence and device validation. UI-source tests are guardrails, not UI automation.

Keep preference keys stable; use QTSettingsModel for labels, prerequisite changes and preset definitions. Do not reset/enable options on upgrade, add live hook installation to a switch, remove feature caveats, or make basic toggling modal. Update preset previews and tests when bundles change.

Do not submit proprietary app binaries, credentials or personal diagnostic captures. Maintain third-party notices. Source publication and app-binary redistribution have different permission requirements.

The two retired player-source stubs remain intentionally for safe repository overlays and are not compiled. Historical ABI records support reproducibility. Backend preference and diagnostic identifiers are kept stable; plain-language UI copy is centralized in the presentation catalog.
