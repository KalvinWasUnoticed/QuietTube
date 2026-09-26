# Changelog

## 1.1.0 — manual diagnostic sessions

- Distribution update: fork IPA releases now also attach the compiled dylib with a separate direct link. A new manual dylib-only workflow supports the original repository and forks, with a per-run prerelease checkbox defaulting to on. No base app is downloaded or uploaded in dylib-only mode; upstream IPA publication remains blocked.
- Both release modes include library notices, SHA256 checksums and source/build metadata. Runtime sources and the CoreGraphics-linked build are unchanged by this distribution update.

- Build correction: explicitly link CoreGraphics for the export popover geometry functions; add a regression check. No production source changes in this correction.

- Adds opt-in, temporary local recording for known playback/error, watch-transition, feed-mutation, explicit-ad and renderer/template discovery paths. It is not an all-events or network logger.
- Adds bounded asynchronous disk history, schema redaction, seven-day cleanup, error-reserved admission, manual export/clear and file protection. Existing reports remain available.
- Caps the older general counter dictionary. Saved preferences, blocking decisions, native player construction and native result/error forwarding remain unchanged outside explicit observation/control additions.
- Adds native logger/observer harnesses and executable admission/size/expiry policy stress tests; see the audit for what actually ran and what still needs Apple/device validation.

## 1.0.2 — audited build and regression gates

- Retains the corrected preference-test syntax and all 1.0.1 preference/session-safety behavior.
- Runs checks on Linux and macOS for pushes/PRs; macOS also compiles/signs the complete iOS library. Manual IPA builds compile before downloading the base.
- Makes the unchanged settings model directly Foundation-testable via header separation. Adds native settings/dependency/preset/read/write tests and separate-process preference tests over all 17 saved flags.
- Adds 100,000 structured C mutation cases, 5,000 malformed Mach-O header cases, interface/build inventory checks and an early delimiter guard.
- Rejects truncated encryption/dylib load commands, invalid dylib name offsets/terminators and non-executable input types before injection. The accepted binary-write path is unchanged.
- All runtime preservation hashes are retained; only packaging validation boundaries are deliberately revised. See the audit for actual local results and pending Apple/device validation.

## 1.0.1 — saved settings stay saved

- Removed the playback-error latch’s persistent write that turned video-ad protection off. Safety fallback is now session-only; saved toggles remain unchanged and are retried on the next launch.
- Added a visible session-pause explanation in settings and the short report.
- Enabled the master switch and video/feed blocking by default only when there are no previous QuietTube preferences. Existing on/off choices are preserved, including on partially initialized installations.
- Removed the destructive historical startup reset. Only absent preference values are initialized.
- Added Foundation preference tests to the macOS build runner and source guards against background settings writes. Player construction/fallback and feed filtering remain unchanged.
- If the older version already saved video blocking off, enable it once after upgrading. The update cannot distinguish an automatic off from your deliberate choice.

## 1.0.0 — public release foundation

- Installer-neutral branding and restart instructions. LiveContainer is listed as the tested environment, not a requirement; other sideloading methods are unverified.
- Shorter README and beginner upload/link/build guide, with Catbox as an optional file host and its size/privacy limits explained.

- Preserves the tested native player protection, scoped explicit-ad feed insertion filter, accepted cleanup, classic logo, Google sign-in/native PiP behavior and RC1 settings layout. Existing preferences remain intact.
- Provides two preview-before-Apply presets and non-modal restart notices.
- Manual **fork → Actions → user-provided decrypted YouTube 21.38.2 HTTPS URL → IPA released in that fork** workflow. No built-in base-app link, no upstream repository publishing.
- Retains exact input SHA256, app version/ID, encryption, ARM64 and duplicate-injection checks. Version-only compatibility is not assumed.
- Adds guarded streaming downloads, draft-first releases, direct IPA Summary links, output SHA256/source metadata and temporary-file cleanup. Explicit rights/publication acknowledgement is required.
- Updates the graphical README and all installation/privacy/maintenance guidance to match the new workflow.
- Retains active tests and required attribution while removing obsolete experimental files and the superseded library-only build-info helper.

Maintainer testing: iPhone 14 / iOS 26.5 / LiveContainer 3.8.0, pinned YouTube 21.38.2, with the earlier runtime/settings now preserved. Local synthetic pipeline tests and mocked GitHub commands are not a live macOS/GitHub release or a fresh device test of 1.0.1. The new preference tests also need execution on macOS/iOS. No DMCA immunity, universal ad-blocking or uninterrupted-playback guarantee is made.
