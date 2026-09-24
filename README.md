# QuietTube · 0.14.0-rc1

An unofficial YouTube customization focused on fewer distractions, native playback and understandable settings. **Not affiliated with or endorsed by YouTube or Google.**

**Release candidate — source and build workflow, not a compiled IPA.** The new settings UI needs native build/device validation before general release. Nothing has been published by this preparation pass.

## What's new

- Native grouped settings: **Presets, Ads, Feed, Playback, Appearance, Advanced**.
- Plain-language option labels, descriptions and retained feature limitations.
- Non-modal “Saved · Restart to apply” notice: automatically dismisses after three seconds; rapid changes replace the notice rather than stacking dialogs. A persistent footer shows pending changes until the guest restarts.
- Enabling a dependent setting also saves its prerequisites. Disabling a prerequisite preserves dependent selections and explains when they are paused.
- Optional presets with a complete before/after preview and explicit Apply. Leaving the preview makes no changes.
- Troubleshooting tools moved under Advanced, with local-capture/privacy explanations.
- Existing preference keys, defaults and launch snapshot behavior retained. **No preset or migration is silently applied to existing users.** New-install modifications remain off until enabled.

### Presets

| Preset | Saves | Leaves alone |
|---|---|---|
| Ads & essentials | Master, video/feed ad blocking, additional ad formats, extended matching, classic logo ON; detailed tracing/template capture OFF | Other feed choices, background audio, next-video setting |
| Focused feed | Ads & essentials plus all available feed cleanup ON | Background audio and next-video setting |

Presets are targeted bundles, not a reset. Choosing Ads & essentials after Focused feed does **not** undo the earlier feed cleanup. The preview lists every affected setting, including unchanged ones. Basic bounded support counters remain available when detailed capture is off.

## Stable runtime baseline

The user reported successful feed blocking in 0.13.5: one explicit-ad entry matched and withheld, native insertion returned, and no sponsored card appeared. Further use was reported working well. Earlier 0.13.1 player tests reported active native no-op substitution without player ads or playback errors in that session.

This candidate does not redesign those paths. Frozen hashes protect eight runtime modules plus the accepted integration/cleanup boundaries. This is limited device evidence, not a guarantee for all videos, ads or future YouTube updates.

## Compatibility and installation

- Exact inspected base: **YouTube 21.38.2**, pinned SHA256 in the build/evidence records. Do not substitute a newer IPA without revalidating private APIs.
- Reported test environment: iPhone 14, iOS 26.5, LiveContainer 3.8.0. Broad device compatibility is not established.
- The library targets iOS 17+. This is a build target, not proof of support on every device/version.
- Use YouTube's native Picture in Picture setting. No replacement player or separate PiP control is added.

For your private evaluation build:
1. Copy all repository contents, including hidden `.github`, and commit. When upgrading the repository, remove obsolete root `AUDIT.md`, `BINARY-RESEARCH.md` and `PLAYER-ADS-RESEARCH.md`; their historical versions now live under `docs/history`. Start a **new** Build QuietTube IPA workflow run.
2. On success use **Summary → DOWNLOAD IPA — QuietTube 0.14.0-rc1**. The link downloads the actual `.ipa`, not an artifact ZIP. Private downloads require GitHub login with repository access.
3. Import into the same LiveContainer data container, without a second injection. Keep 0.13.5 for rollback. Do not delete existing app data.
4. Open **You → Settings → General → Quiet controls**. Existing users can keep their preferences; new users can preview a preset.
5. Fully stop/relaunch the LiveContainer guest after changing settings. Refreshing Home is not a restart.

The workflow fetches a third-party-hosted base and verifies its exact hash; host availability and redistribution authority are separate concerns. Public IPA publishing remains explicitly gated. Prefer a public **source-only** release unless you have established the necessary redistribution rights. See [RELEASE-CHECKLIST.md](RELEASE-CHECKLIST.md).

## Troubleshooting and rollback

Advanced → Troubleshooting → View support report is the short report (previously “Ad test report”). Prepare a support test is only for diagnosing issues: it enables protection, extended matching and detailed local capture, preserving unrelated preferences. Review reports before sharing.

The playback-error safety latch remains unchanged: future calls revert to native behavior and protection is saved OFF. It does not repair existing players or restore withheld feed entries. Restart after errors; revert the IPA for crashes/stalls or broken feed updates.

To pause QuietTube without erasing preferences, turn off its master switch and restart. Advanced → Disable all options deliberately clears all toggle selections and still asks for confirmation.

## Validation and project documents

78 Python source/ABI/packaging/release checks pass clean and in a 0.13.5 upgrade overlay. Four C sanitizer suites pass. These are **not native UI or device tests**. See VALIDATION.json and TEST-PLAN.md.

- [Release checklist](RELEASE-CHECKLIST.md): publication gates, compatibility and rights review
- [Privacy](PRIVACY.md): local reports and third-party app data practices
- [Contributing](CONTRIBUTING.md): protect the stable runtime
- [Changelog](CHANGELOG.md)
- [Historical research](docs/history): prior iterations retained for provenance, not current instructions

QuietTube source is MIT licensed; third-party notices remain in Notices. The license does not license YouTube's binary, trademarks or services. No anti-detection, universal blocking or uninterrupted-playback promise is made.
