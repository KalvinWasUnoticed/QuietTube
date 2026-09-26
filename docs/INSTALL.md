# Build and install the IPA

[← QuietTube](../README.md)

This guide is for an IPA with QuietTube included. **Only need the dylib?** Use the [separate library workflow](RELEASE-FLOWS.md#build-just-the-dylib); it needs no base app.

The GitHub build does not need Xcode on your computer, Python installed locally or an Apple login. Your installer has its own requirements.

## What you need

- A GitHub account and your own fork.
- A compatible **decrypted YouTube 21.38.2 IPA**. This repo does not supply the app or decryption instructions.
- The rights to upload, modify and share it. The output goes to your fork’s Releases. If the fork is public, so is the download.
- A way to install/sign IPA files on your iPhone.

The input check accepts the exact inspected file. A different 21.38.2 IPA can fail it. Don’t remove the check to force a build through.

## 1. Upload the base IPA

[Catbox](https://catbox.moe/) is one option, if your file fits its **200 MB** limit and you have permission to share it.

1. Open Catbox and choose **Select or drop files**.
2. Select the decrypted `.ipa`.
3. Let it upload; use **Go!** if the page asks you to start it.
4. Copy the file link—not the homepage URL.
5. Open the link to check that it downloads the file itself, without another button or a sign-in page.

For larger files, use another host with a direct HTTPS download link. Keep the IPA unchanged; don’t wrap it in another ZIP. Check the host’s current limits before uploading.

Anyone with a Catbox file link may be able to download it. Follow [its rules](https://catbox.moe/legal.php). The build does not delete that upload for you.

## 2. Fork the repository

1. Open [QuietTube](https://github.com/KalvinWasUnoticed/QuietTube).
2. Choose **Fork → Create fork**.
3. Open **Actions** in your copy and enable workflows if GitHub asks.

The IPA workflow runs in forks, not the original repository. The dylib-only workflow has a different rule.

## 3. Run the build

1. Select **Actions → Build QuietTube IPA → Run workflow**.
2. Paste the direct link into **base_ipa_url**.
3. Read **acknowledge_rights**. Check it only if you have the required rights and accept the publication notice.
4. Choose **Run workflow**, then open the new run.

The job checks the source, runs tests and compiles QuietTube first. It then downloads and validates the base, packages the IPA and publishes to your fork. Without a fork or acknowledgement, it skips the job.

The URL is **not a secret**. GitHub can retain workflow inputs even though the downloader masks its own output. Don’t use passwords or sensitive long-lived tokens in it.

## 4. Download the right asset

When the run succeeds, open **Summary → DOWNLOAD IPA — QuietTube 1.2.0**. Or open that run’s release and download:

```text
QuietTube-1.2.0-21.38.2.ipa
```

The release also has a separate `QuietTube.dylib`, checksums, notices and build metadata. Those are not substitutes for the IPA. GitHub’s source ZIP is not an installable app either.

Choose the release from the run you just completed. The newest release might be **dylib only**, with no IPA. The IPA workflow creates prereleases; a library release can use either label.

## 5. Install it

Follow your installer’s signing instructions. **QuietTube is already in the IPA. Don’t inject it again.** Keep a working copy and back up important data before replacing an app.

The reported device setup is iPhone 14 / iOS 26.5 / LiveContainer 3.8.0, installed through SideStore. Other methods have not been verified. App identifiers, entitlements and sign-in behavior can differ. The package removes app extensions and still needs signing/preparation.

### Using LiveContainer

1. Save the IPA to Files.
2. Open LiveContainer, tap **+**, and select it.
3. Let LiveContainer prepare it. On an update, preserve the existing data container.
4. Stop the old guest completely, then launch the updated one.

For setup, use the official [SideStore prerequisites](https://docs.sidestore.io/docs/installation/prerequisites), [SideStore installation guide](https://docs.sidestore.io/docs/installation/install) and [LiveContainer installation guide](https://livecontainer.github.io/docs/installation). Apple credentials belong in trusted installation tools, never in this workflow.

## 6. Find the settings

Open **You → Settings → General → Quiet controls**. The footer should show **1.2.0**.

Fresh installs start with the master switch and video/feed blocking on. Updates keep saved choices. Presets are optional. Close and reopen the app to apply switch changes; in LiveContainer, stop and relaunch the guest. Manual diagnostic sessions are separate and start without a restart.

[Settings, dependencies and the 1.0.0 upgrade fix](SETTINGS.md).

## Build or install trouble

| Symptom | Check |
| --- | --- |
| No Run workflow button | The workflow must be on the default branch. Check Actions is enabled and you are in the right repository. |
| IPA job skipped | Use a fork and complete the acknowledgement if you have the rights. |
| Download rejected | Check the direct link, host availability and file-size limit. No sign-in page or HTML download wrapper. |
| Hash/compatibility error | The file is not the exact supported input. Its name or version label is not enough. |
| Mixed-source error | Replace the complete source tree, including hidden `.github`, and commit before starting a new run. |
| Build/publish error | Open the failed step. Report its error and source commit. Repository permissions can prevent publishing. |
| Incomplete draft release | A create/upload/publish step may have failed. Inspect it; don’t assume its assets are complete. |
| Duplicate tag on New release | The workflow already created the release. Edit the existing release instead. |
| Old settings or old version | Check which artifact and app/container you are opening, then fully restart it. |
| Playback/sign-in trouble | Keep or restore the working build. Capture a short reviewed report; don’t assume an untested installer behaves like the tested setup. |

To pause modifications, turn off the master switch and restart. Individual choices stay saved. [Diagnostic capture](DIAGNOSTICS.md) explains how to collect useful evidence without posting raw captures.

<details>
<summary>Exact input, network limits and local packaging</summary>

Accepted input SHA256:

```text
d0f6f5c9d27f7fea8f040ae59c425b3a8222f67d891937374b21ef8937deba11
```

The downloader requires public HTTPS destinations on port 443, including redirects. It limits downloads to **2 GiB / five minutes**; the host can impose a smaller limit. It rejects HTML, incomplete downloads and hash mismatches. DNS checks are an extra guard, not a guarantee against every network attack.

Packaging checks the app ID/version, ARM64 structure, encryption state and duplicate injection. Download checksums and source metadata come with the release. Draft-first publication prevents a failed upload from being presented as a completed release. Runner cleanup does not remove published assets or GitHub records.

Local compilation needs macOS and Xcode’s iPhoneOS SDK:

```sh
bash scripts/build.sh
```

With Python 3.11+ and the compiled library:

```sh
python3 scripts/package.py "/path/to/authorized-base.ipa" "artifacts/QuietTube.dylib" "artifacts/QuietTube-1.2.0-local.ipa"
```

On Windows, the Python packaging step can use `py -3` with a matching compiled library. It does not compile the iOS library for you.

</details>

Use only files you have the rights to use and distribute. A host, fork or checkbox is not legal clearance. [Privacy](PRIVACY.md).
