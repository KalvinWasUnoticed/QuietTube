# Maintaining and publishing QuietTube

## Two release paths

The repository provides the tweak, not a YouTube base app link.

- **Build QuietTube IPA** runs in forks. The user supplies the authorized, exact supported decrypted 21.38.2 input. The job compiles, downloads/checks, packages and publishes an IPA plus dylib in that fork.
- **Build QuietTube dylib only** runs in the original repository or forks. No base app is supplied or distributed. The caller chooses prerelease or regular release.
- **Source checks** runs tests and the macOS compile check without downloading or publishing a real app. Tests may create synthetic, non-runnable fixtures.

Both release flows require publication acknowledgement. A public repository makes its assets public. [Inputs, assets and publication behavior](RELEASE-FLOWS.md).

Do not store Apple credentials or add a personal token for these workflows. Use their existing job permissions.

## Replace the source tree carefully

Back up your changes. Replace the old tracked contents with the complete package at the repository root, including hidden `.github`. Preserve the repository and local `.git` directory. Commit the update and start a new run; re-running an old failed job uses the old commit.

The manifest rejects mixed versions and known obsolete files. It does not prove who authored the files. Do not change hashes to hide a mixed upload.

`README.md` is editorial copy, not a frozen build input. You can edit it without updating a checksum. Tests check its local links, not mandatory wording. Other files listed in the manifest still need reviewed hashes when deliberately changed. Put release-specific changes in the release notes; the README links there.

## Check the artifact you plan to publish

Run the source checks and native build. For IPA mode, use the real authorized pinned base in a fork. Confirm the direct downloads, source commit and hashes. A skipped job is not a successful build, and an incomplete draft is not a completed release.

Test the exact output while preserving a backup and existing data. Check the 1.2.0 footer, saved choices over restarts, fresh-install defaults in a disposable container, presets, navigation, large text/light/dark, playback/feed behavior, sign-in, native PiP and background audio. New logger controls need their own [device checks](AUDIT-1.2.0.md#required-device-acceptance).

LiveContainer is the reported tested method, not the only imaginable installer. Do not claim another method works until it has evidence. A regular release label is a publication choice, not a stable-device verdict.

## Remote cleanup is separate

Replacing HEAD does not remove old assets or history. Review old releases, artifacts, Actions runs/logs, tags, branches, wiki/issues and obsolete hosted-base links. Remove material you lack rights to distribute. Revoke exposed credentials.

A deletion commit leaves history. A history rewrite needs backups, coordination and appropriate advice; even a force push cannot erase third-party clones, forks or every cache. No remote cleanup is performed by delivering this source package. Keep required license/credit text.

## Keep the claims straight

The output IPA has app extensions removed and needs installer signing/preparation. Other installers can handle identities, entitlements and sign-in differently. Keep the exact-input guard; a version string alone is not enough.

Catbox is a user-selected upload host, not a source of YouTube downloads. A fork, checkbox or disclaimer does not establish permission to obtain, modify or distribute the app. Source functionality, service terms, trademarks and circumvention allegations can raise separate issues. For legal advice, ask a qualified professional; [GitHub’s DMCA policy](https://docs.github.com/en/site-policy/content-removal-policies/dmca-takedown-policy) describes its removal process.

Do not advertise “DMCA-proof,” “undetectable,” “all ads blocked” or official affiliation.

## What belongs in the tree

`Sources` is the active implementation. `scripts` handles checks/build/distribution; `tests/fixtures` records the ABI, preservation and distribution evidence. `.github` contains workflows and the issue template. `docs/assets` holds the README artwork and real screenshots. `VERSION` and the manifest identify the source package.

Keep those files and `LICENSE`/`Notices`. Leave out retired stubs, raw disassembly, development diaries, obsolete baselines and old publishers.
