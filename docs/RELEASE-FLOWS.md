# IPA + dylib, or dylib only

## 1. Build QuietTube IPA — forks only

Use the existing manual workflow with your authorized compatible base URL and publication acknowledgement. It runs checks, compiles the library, validates/downloads the exact supported base and packages the IPA.

A successful release now has **two separate direct download links** in both the Actions Summary and release notes:

- `QuietTube-1.1.0-21.38.2.ipa`
- `QuietTube.dylib` — the same compiled file embedded in that IPA

This flow remains a **prerelease in your fork**. Original-repository IPA publication is still blocked in both YAML and the publisher. The IPA already includes the library; **do not inject it again**.

## 2. Build QuietTube dylib only — original repository or forks

1. Commit the complete updated package, including `.github/workflows/dylib.yml` and the matching manifest. GitHub needs the workflow on the default branch for its manual Run workflow entry to appear.
2. Open **Actions → Build QuietTube dylib only → Run workflow**.
3. Leave **prerelease** checked for a prerelease, or uncheck it for a regular release.
4. Confirm the publication acknowledgement and run the workflow.
5. After success, use **Summary → DOWNLOAD DYLIB** or the release asset `QuietTube.dylib`.

This workflow works in **KalvinWasUnoticed/QuietTube and forks**. It does not ask for an IPA URL, download YouTube, package a YouTube IPA or upload one. Regression tests can create temporary, non-runnable synthetic IPA fixtures; those are never release assets. The repository's automatic source archives can still appear on GitHub Releases; those are normal GitHub-generated archives, not IPAs.

The standalone library is **not an installable app**. It targets the existing supported YouTube 21.38.2 / ARM64 / iOS 17+ configuration and requires appropriate lawful host-app preparation/injection/signing tools. The standalone workflow cannot validate an input app because it never receives one. No other-version or universal installer compatibility is implied. Do not inject twice or mix unrelated libraries.

## Shared release assets and safety

Both flows attach:

- `QuietTube.dylib`
- `QuietTube-NOTICES.txt` — project license plus existing reference/license notices
- `BUILD-INFO.json` — version, source commit/repository, workflow run, release mode, prerelease choice and binary hashes
- `SHA256SUMS` — hashes for uploaded binaries, notices and build metadata

Only the IPA flow additionally uploads the expected IPA. The publisher uses an explicit asset list, **not a directory glob**; a leftover IPA is not uploaded by dylib-only mode. Dylib headers must identify thin ARM64 MH_DYLIB output; this is not full runtime validation.

Both workflows run checks and the existing CoreGraphics-linked Apple build before publication. They create/upload a draft first and publish only after success. A failed upload can leave an incomplete draft to inspect; no success download link is emitted. Tags include release mode where appropriate, version, run ID and attempt to avoid replacing an unrelated artifact. Permissions are limited to the release job, and checkout does not persist credentials.

Regular versus prerelease is a publication choice, not a validation certificate. GitHub may make a regular release the latest release: choose the correct **IPA + dylib** or **dylib only** release by its label, not merely by “latest.” Public repository releases are public; this flow is not a guarantee of legal clearance.

## Validation of this distribution change

Local Python and C regression checks and workflow lint are run before packaging the updated source. New publisher tests cover both modes/repositories/release types, exact assets and hashes, no-IPA operation, leftover-file exclusion, missing/bad libraries/notices and failed create/publish behavior. CLI tests use a mocked `gh` executable. They do **not** demonstrate live GitHub permissions/publication or a fresh Apple build. Production sources and `scripts/build.sh` are unchanged from the CoreGraphics link fix.
