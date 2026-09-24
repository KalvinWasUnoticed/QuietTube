# Fork. Build. Package locally. Watch.

[← QuietTube](../README.md)

**What this produces:** GitHub Actions produces `QuietTube.dylib`, not YouTube and not an installable IPA. You use that library with an authorized compatible base **on your own computer**. The finished local IPA goes into LiveContainer.

## Before you start

You need:
- A GitHub account and a fork of [QuietTube](https://github.com/KalvinWasUnoticed/QuietTube/fork).
- An iPhone with working SideStore and LiveContainer. The reported test environment is **iPhone 14 / iOS 26.5 / LiveContainer 3.8.0**. Other environments are not confirmed.
- A computer with **Python 3.11+**, storage for the base app and a temporary expanded copy, and the source files from the **same commit** as your library build. Windows, macOS or Linux can run the Python packager; local Xcode is not needed when using the cloud-built library.
- Your own **authorized, unencrypted, exactly matching YouTube 21.38.2 base IPA**. This repository does not provide it, download it, decrypt it or explain how to bypass app encryption.

The local packager accepts only the inspected base with this SHA256:

```text
d0f6f5c9d27f7fea8f040ae59c425b3a8222f67d891937374b21ef8937deba11
```

**The same version number is not enough.** A differently packaged 21.38.2 IPA can fail this check. If you cannot lawfully supply this exact compatible base, stop here. Do not disable the hash, version or encryption guards to force another app through. Permissions to obtain, modify and use the app must be established separately.

## 1. Set up SideStore and LiveContainer

Already running this combination? Skip to step 2.

1. Follow SideStore's official [prerequisites](https://docs.sidestore.io/docs/installation/prerequisites) and [installation guide](https://docs.sidestore.io/docs/installation/install). Complete its device trust, Developer Mode (where applicable), VPN and refresh setup. Use official instructions rather than an old screenshot tutorial; these steps change with iOS releases.
2. Follow the official [LiveContainer installation guide](https://livecontainer.github.io/docs/installation). For the tested standalone route, install LiveContainer through SideStore and complete its setup.
3. Open LiveContainer once and confirm it runs. Follow SideStore's refresh requirements. Keep your Apple credentials in those tools—**QuietTube Actions does not need them**.

Do not install a new SideStore/LiveContainer variant just to match these screenshots if your existing setup works. Their official documentation governs their setup and troubleshooting.

## 2. Fork and run the library build

1. Open [QuietTube](https://github.com/KalvinWasUnoticed/QuietTube), choose **Fork → Create fork**.
2. Open **your fork's Actions tab**. If GitHub asks, enable workflows.
3. Choose **Build QuietTube library** in the workflow list.
4. Select **Run workflow**, choose the branch you intend to build and confirm. Use a new run after committing updates, not a rerun of an old commit.
5. Wait for the source-integrity check, tests and native compilation to finish.
6. Open the run's **Summary → Download library artifact (ZIP)**, or its **Artifacts** section. Download `QuietTube-1.0.0-library`.

You may need to sign into GitHub to download artifacts. They expire after seven days; start another build if necessary. The workflow uses read-only repository contents permission and does not create GitHub Releases. It uploads only the QuietTube library, integrity information and licenses—not arbitrary contents of the build directory.

## 3. Match the source and library

1. From the workflow run, open its **source commit**. Download the repository ZIP for that commit and extract it on your computer. Do not pair a newer source checkout with an older library.
2. Extract the library artifact separately. Locate:
   ```text
   artifacts/QuietTube.dylib
   artifacts/BUILD-INFO.json
   artifacts/SHA256SUMS
   ```
3. Copy these three files into the source folder's `artifacts/` directory, creating it if needed.
4. In a terminal opened at the source folder, run:
   ```sh
   python3 scripts/verify_release.py
   python3 -c "import hashlib,json,pathlib; p=pathlib.Path('artifacts'); i=json.loads((p/'BUILD-INFO.json').read_text()); assert hashlib.sha256((p/'QuietTube.dylib').read_bytes()).hexdigest()==i['library_sha256']; print(i)"
   ```
   On Windows, use `py -3` instead of `python3` if that is how Python is installed.

Check that the printed version and `source_commit` match the run you downloaded. Hashes catch accidental mismatches; they are not proof that a third-party fork is trustworthy. Build source you trust.

## 4. Package with your own base — locally only

Keep the base IPA outside the repository. From the source directory:

```sh
python3 scripts/package.py "/absolute/path/to/your-authorized-base.ipa" "artifacts/QuietTube.dylib" "artifacts/QuietTube-1.0.0-local.ipa"
```

Windows example (adjust paths):

```powershell
py -3 scripts/package.py "C:\Users\You\Downloads\your-authorized-base.ipa" "artifacts\QuietTube.dylib" "artifacts\QuietTube-1.0.0-local.ipa"
```

The tool checks the exact input hash, app ID/version, ARM64 Mach-O structure, encryption state and injection space; it rejects duplicate injection. It removes invalidated signatures and app extensions and adds QuietTube to the guest. LiveContainer must sign/prepare the result. Packaging success is not a runtime test.

**Do not commit or upload the base, output IPA, credentials or signing files.** The `.gitignore` is a guardrail, not a permission grant or a substitute for checking your uploads. There is no cloud packaging step in this release.

## 5. Import and enable

1. Transfer `QuietTube-1.0.0-local.ipa` to your iPhone.
2. In LiveContainer, tap **+** and select the local IPA. Let LiveContainer prepare it. **Do not separately inject the library a second time.**
3. For an upgrade, preserve the existing guest data/container and your working backup. Do not delete account data to fix a version mismatch.
4. Fully stop the guest before opening the updated one. Make sure you selected the intended guest if multiple copies exist.
5. Open **You → Settings → General → Quiet controls**. Its footer should read **1.0.0**.
6. New users: open **Presets**, review **Ads & essentials** or **Focused feed**, then tap **Apply**. Existing users can retain their preferences; nothing is automatically reset or enabled.
7. Fully stop and relaunch the guest to apply changes. Refreshing Home is not a full restart.

Use YouTube's own **Picture in Picture** setting. Background audio has its own QuietTube option. The presets intentionally do not change your background-audio or next-video preferences.

## If something fails

| Symptom | Check |
| --- | --- |
| No Run workflow button | You are in your fork, Actions is enabled and the selected branch contains `.github/workflows/build.yml`. |
| Mixed/incomplete source error | Replace the entire release tree, including hidden `.github` and the manifest. Remove the listed obsolete files. Do not regenerate hashes to conceal a mismatch. |
| Native build failure | Open the failed step and report the compiler error with the source commit. No app log is needed. |
| Download is a ZIP, not an IPA | Expected: this is the library artifact. Follow local packaging, not direct import. |
| Base hash/encryption/version error | The supplied app is not the exact supported input. Do not bypass the guard. No base download is provided by this project. |
| Old settings/footer after an update | Check the source commit, library artifact, local output IPA and selected LiveContainer guest; fully stop/relaunch it. |
| Playback error or feed regression | Keep the short support report, restart, and restore your known-working local build if needed. |

To pause QuietTube without erasing preferences: turn off **Enable QuietTube** and restart. For a problem report, use **Advanced → Troubleshooting → View support report** and review it before sharing. [Settings and limitations →](SETTINGS.md)
