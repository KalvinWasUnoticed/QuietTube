# Release an IPA and dylib, or just the dylib

## Build the IPA

Run **Build QuietTube IPA** in a fork. Supply the compatible base URL and complete the publication acknowledgement. The workflow runs checks and compiles QuietTube before downloading, validating and packaging the base.

A successful run publishes a **prerelease in that fork** with direct Summary/release-note links to:

- `QuietTube-1.2.0-21.38.2.ipa`
- `QuietTube.dylib`, the same compiled library included in the IPA

Original-repository IPA publishing is blocked by both the workflow and publisher. The IPA already includes the tweak. Don’t inject it again.

[Full IPA instructions](INSTALL.md).

## Build just the dylib

This works in **KalvinWasUnoticed/QuietTube or a fork**. No base URL is needed.

1. Commit the complete package, including `.github/workflows/dylib.yml` and the matching manifest. GitHub needs the workflow on the default branch to show its manual Run workflow entry.
2. Open **Actions → Build QuietTube dylib only → Run workflow**.
3. Keep **prerelease** checked for a prerelease, or uncheck it for a regular release.
4. Read and complete the publication acknowledgement, then run it.
5. On success, use **Summary → DOWNLOAD DYLIB** or `QuietTube.dylib` in the release assets.

This flow does not download YouTube, package a YouTube IPA or upload one. Tests can create temporary, non-runnable synthetic IPA fixtures; those never become release assets. GitHub can still attach its normal source archives.

The dylib is not an installable app. It targets **YouTube 21.38.2 / ARM64 / iOS 17+** and needs a compatible, lawfully obtained host app plus injection/signing tools. This workflow cannot validate a host app it never receives. Other builds/installers are not guaranteed. Don’t inject twice or mix unrelated libraries.

## Assets included in both modes

| Asset | Purpose |
| --- | --- |
| `QuietTube.dylib` | Compiled library. |
| `QuietTube-NOTICES.txt` | Project license and existing reference/license notices. |
| `BUILD-INFO.json` | Version, source commit/repository, run, mode, prerelease choice and binary hashes. |
| `SHA256SUMS` | Hashes for the uploaded binaries, notices and metadata. |

Only IPA mode adds the expected IPA. The publisher uses an explicit file list, not a directory glob, so leftover files are not silently uploaded. It checks the dylib’s thin ARM64 MH_DYLIB header; that is not runtime validation.

## Publication and editing

Both flows create/upload a draft first, then publish it. A failed upload can leave an incomplete draft. No success link is written for a failed publication.

Each tag includes the version, run ID and attempt; dylib-only tags also identify that mode. The release job has write permission, and checkout does not persist credentials.

**“Duplicate tag name” on New release?** The workflow already created a release for that tag. Edit that release’s title/notes/label and keep its assets; do not make another release for the same tag.

A regular release can become GitHub’s latest release. Choose by the **IPA + dylib** or **dylib only** label and the actual assets, not just “latest.” Choosing a release label does not establish device compatibility.

Public release assets are public. The acknowledgement is not legal clearance.

## What has been tested

The source-package checks use synthetic files and mocked `gh` commands to test modes, hashes, missing/bad assets, failure handling and accidental-upload prevention. They are not live GitHub tests.

The maintainer subsequently reported a successful standalone 1.2.0 dylib build/release. That is separate evidence from the earlier source-package checks, and does not validate every host app or device configuration. The native source and CoreGraphics-linked build were not changed for the two release flows.
