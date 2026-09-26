# Changelog

## Documentation and artwork refresh — no runtime change

- Rewrites the docs in plain language and puts the IPA/dylib paths where readers can find them.
- Replaces the gradient banner with a flat printed-label design and adds an editable project mark. The real RC1 screenshots stay unchanged.
- Separates the maintainer-reported successful dylib build from earlier source-only test records. It does not claim new device validation.
- Keeps version 1.1.0, source behavior, workflows, safeguards and all license text unchanged.

## 1.1.0 — manual diagnostic sessions

- Adds temporary, opt-in recording for supported playback/error, watch-transition, feed-mutation, explicit-ad and renderer/template paths. It is not an all-events or network logger.
- Stores limited history asynchronously, with allowed-field checks, seven-day cleanup, error-reserved queue/rate capacity, file protection, export and clear. Older reports remain available.
- Caps the general counter dictionary. The observation additions do not change saved preferences or the underlying player/filter decisions and native result/error forwarding.
- Adds native logger/observer tests and shared C admission/size/expiry tests. See the [audit](docs/AUDIT-1.1.0.md) for the evidence and its limits.
- Fixes the export popover’s missing CoreGraphics link dependency and adds a check for it. No production source changed in that build correction.
- Adds a separate dylib asset/link to fork IPA releases. Adds a no-base-app dylib-only workflow for the original repository and forks, with a prerelease checkbox defaulting to on.
- Includes notices, checksums and build metadata in both release modes. IPA publication remains fork-only. The distribution update leaves the native source and corrected build script alone.

## 1.0.2 — build checks

- Keeps the corrected preference-test syntax and 1.0.1 preference/session behavior.
- Runs push/PR checks on Linux and macOS; macOS also compiles/signs the iOS library. Manual IPA builds compile before downloading the base.
- Separates the settings model’s header dependency so Foundation tests can execute it. Adds model/dependency/preset tests and process-level tests over all 17 saved flags.
- Adds 100,000 structured C mutation cases, 5,000 malformed Mach-O header cases, module/interface checks and a delimiter check.
- Rejects truncated encryption/dylib commands, invalid name offsets/terminators and non-executable injection inputs. The accepted binary-writing path is unchanged.
- Keeps the runtime preservation hashes; only the reviewed packaging-validation boundary changes. [Historical audit](docs/AUDIT-1.0.2.md).

## 1.0.1 — saved settings stay saved

- Removes the playback-error handler’s persistent write that turned video-ad blocking off. The fallback is session-only; a new launch retries the saved choice.
- Shows the session pause in settings and the report.
- Starts master/video/feed blocking on only for a fresh preference store. Existing on/off values survive, including partially initialized stores.
- Removes the old startup reset. Initialization fills absent values only.
- Adds Foundation preference tests and source guards against background writes. Player construction and feed filtering remain unchanged.
- An off value already saved by the older version still needs to be enabled manually. It cannot be distinguished from a deliberate off.

## 1.0.0 — first public release

- Uses installer-neutral wording and a shorter README/build guide. LiveContainer is the tested environment, not a requirement; Catbox is an optional upload host with size/privacy limits.
- Keeps the preceding native player approach, scoped feed insertion, cleanup, classic logo, native PiP/sign-in behavior and RC1 settings layout.
- Adds two preview-before-Apply presets and non-modal restart notices.
- Uses the manual fork → user-supplied decrypted 21.38.2 URL → IPA release flow. No built-in base link or upstream publishing in this version.
- Checks the exact SHA256, app version/ID, encryption, ARM64 and duplicate injection. Adds guarded downloads, draft-first publication, direct IPA links, source/checksum metadata and temporary-file cleanup.
- Keeps tests and attribution; removes obsolete experiments and the superseded library-only build-info helper.

Historical device evidence came from iPhone 14 / iOS 26.5 / LiveContainer 3.8.0 with the supported YouTube 21.38.2 base. Local synthetic tests were not Apple/device tests. The later successful standalone 1.1.0 GitHub build was reported separately; it does not turn earlier audits into device validation or establish universal ad blocking.
