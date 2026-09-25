# Changelog

## 1.0.0 — final fork-build package

- Installer-neutral branding and restart instructions. LiveContainer is listed as the tested environment, not a requirement; other sideloading methods are unverified.
- Shorter README and beginner upload/link/build guide, with Catbox as an optional file host and its size/privacy limits explained.

- Preserves the tested native player protection, scoped explicit-ad feed insertion filter, accepted cleanup, classic logo, Google sign-in/native PiP behavior and RC1 settings layout. Existing preferences remain intact.
- Provides two preview-before-Apply presets and non-modal restart notices.
- Manual **fork → Actions → user-provided decrypted YouTube 21.38.2 HTTPS URL → IPA released in that fork** workflow. No built-in base-app link, no upstream repository publishing.
- Retains exact input SHA256, app version/ID, encryption, ARM64 and duplicate-injection checks. Version-only compatibility is not assumed.
- Adds guarded streaming downloads, draft-first releases, direct IPA Summary links, output SHA256/source metadata and temporary-file cleanup. Explicit rights/publication acknowledgement is required.
- Updates the graphical README and all installation/privacy/maintenance guidance to match the new workflow.
- Retains active tests and required attribution while removing obsolete experimental files and the superseded library-only build-info helper.

Maintainer testing: iPhone 14 / iOS 26.5 / LiveContainer 3.8.0, pinned YouTube 21.38.2, with the earlier runtime/settings now preserved. Local synthetic pipeline tests and mocked GitHub commands are not a live macOS/GitHub release or a fresh device test of 1.0.0. No DMCA immunity, universal ad-blocking or uninterrupted-playback guarantee is made.
