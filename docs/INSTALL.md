# Build and install QuietTube

[← Back to QuietTube](../README.md)

**You supply a compatible YouTube IPA. GitHub builds your QuietTube IPA. You install it.**

You don't need Xcode, Python or an Apple login for the build. Your installation method may have its own setup requirements.

## Before you start

Have these ready:
- A GitHub account.
- Your own compatible **decrypted YouTube 21.38.2 IPA**. QuietTube does not supply the app or instructions for decrypting it.
- Permission to upload, modify and share that file. The finished IPA is published in your fork; **if the fork is public, the download is public too**.
- Your preferred way of installing IPA files on your iPhone.

**Compatibility check:** the build accepts only the exact app file that was inspected and tested. It checks this automatically. A different copy of 21.38.2 may be rejected—don't disable the check to force it through.

## 1. Upload your IPA and copy its link

We recommend **[Catbox](https://catbox.moe/)** as a simple upload option, provided you have permission to share the file and it meets the host's rules.

1. Open Catbox and choose **Select or drop files**.
2. Select your decrypted YouTube 21.38.2 `.ipa` file.
3. Let the upload finish; use **Go!** if the page asks you to start it.
4. Copy the **file link** it gives you. Don't copy the Catbox homepage address.
5. Check that opening the link offers the file itself—not a sign-in screen or a download page with another button.

Catbox [currently allows uploads up to 200 MB](https://catbox.moe/). For a larger file, use another host offering a **direct HTTPS file link**. Keep the IPA unchanged; don't put it inside another ZIP.

**Don't treat the upload as private.** Anyone with the link may be able to download it. Follow [Catbox's rules](https://catbox.moe/legal.php), and don't upload private account data or files you aren't allowed to share. The build does not remove your Catbox upload afterward.

## 2. Make your own fork

1. Open [QuietTube on GitHub](https://github.com/KalvinWasUnoticed/QuietTube).
2. Choose **Fork → Create fork**. A fork is your own copy of the repository.
3. In **your copy**, open **Actions**.
4. If GitHub asks, enable the workflows.

Use your fork—not the original repository—for the next step.

## 3. Start the build

1. In **Actions**, select **Build QuietTube IPA**.
2. Choose **Run workflow**.
3. Paste the direct file link into **base_ipa_url**.
4. Read **acknowledge_rights** and check it only if you have the required rights and understand that a public fork publishes a public IPA.
5. Choose **Run workflow** again to start.
6. Open the new run and wait for it to finish.

The build checks the input, builds QuietTube and packages the IPA. It then publishes the result to **your fork's Releases**. If you're outside a fork or leave the acknowledgement unchecked, the job is skipped and no IPA is created.

The URL is a workflow input, **not a secret**. Don't use a link containing passwords or sensitive long-lived access tokens. The script avoids printing the URL, but GitHub may retain workflow inputs in its records.

## 4. Download the finished IPA

When the run succeeds:

- Open its **Summary → DOWNLOAD IPA — QuietTube 1.0.0**, **or**
- Open your fork's **Releases**, select the newest build and download **QuietTube-1.0.0-21.38.2.ipa**.

Download the `.ipa`, not the source-code ZIP. The release also includes small verification files; those are not what you install. Each run has its own release, so make sure you're downloading the build you just ran.

## 5. Install it your way

Use your preferred IPA installer and follow its signing instructions. QuietTube is already included—**don't inject it a second time**. Keep your current working copy and back up important data before replacing an app.

**Only LiveContainer has been tested:** iPhone 14, iOS 26.5, LiveContainer 3.8.0 installed through SideStore. LiveContainer is not a design requirement, but other methods are not yet verified. Signing rules, app identifiers and sign-in behavior can differ. The output needs signing/preparation and has app extensions removed, matching the tested packaging setup.

### If you use LiveContainer

1. Save the IPA to Files on your iPhone.
2. Open LiveContainer, tap **+**, and choose the IPA.
3. Let it prepare the app. When updating, preserve the existing data container.
4. Fully stop the old guest and launch the intended updated one.

Need to set it up first? Use the official guides: [SideStore prerequisites](https://docs.sidestore.io/docs/installation/prerequisites) → [SideStore installation](https://docs.sidestore.io/docs/installation/install) → [LiveContainer installation](https://livecontainer.github.io/docs/installation). Apple credentials belong in those trusted setup tools, never in the QuietTube workflow.

## 6. Turn on the options you want

Open **You → Settings → General → Quiet controls**. The footer should show **1.0.0**.

New users can open **Presets**, choose **Ads & essentials** or **Focused feed**, review the changes and tap **Apply**. Existing settings are kept on upgrade.

**Fully close and reopen the app after changing settings.** Refreshing the feed isn't a restart. In LiveContainer, stop and relaunch the guest. Use YouTube's own PiP setting; Background audio is a separate QuietTube option.

## Something went wrong?

| What you see | What to do |
| --- | --- |
| No Run workflow button | Check that you're in your fork and have enabled Actions. |
| Job skipped | Use a fork and complete the acknowledgement if you have the required rights. |
| Download rejected | Check that the link downloads the IPA directly, without signing in. Check the host's availability and file-size limits. |
| Hash or compatibility error | The IPA isn't the exact supported copy, even if its filename/version looks right. Don't bypass the check. |
| Mixed-source error | Replace the entire repository contents with the complete release package, including hidden `.github`. Start a new run after committing. |
| Build or publishing error | Open the red failed step. Report that error and the source commit—not your private URL or account details. Repository/organization permissions may block release creation. |
| A draft release appeared | Upload or publication may have failed. Inspect it before rebuilding; don't assume the IPA is complete. |
| Old settings after installation | Check the build you downloaded and the app you're launching. Fully close and reopen it. |
| Playback or sign-in trouble | Try the known-tested setup or restore your working copy. Other installers are not confirmed compatible. |

For an app issue, review **Advanced → Troubleshooting → View support report** before sharing it. To pause QuietTube, turn off its master switch and reopen the app. Your individual preferences are kept.

<details>
<summary>Technical details, checksums and offline packaging</summary>

The exact accepted input SHA256 is:

```text
d0f6f5c9d27f7fea8f040ae59c425b3a8222f67d891937374b21ef8937deba11
```

HTTPS links and redirects must point to public network destinations on port 443. Downloads are bounded to 2 GiB and five minutes; the file host can impose a lower limit. Catbox's listed limit is 200 MB. HTML responses, incomplete downloads and hash mismatches are rejected. DNS checks are defense-in-depth, not protection against every network attack.

The packager also checks app ID/version, ARM64 structure, encryption and duplicate injection. The release contains `BUILD-INFO.json` and `SHA256SUMS` with the source commit and output hash. Releases are created as drafts and published only after upload succeeds; each generated build is marked prerelease until separately device-tested. Temporary runner files are removed afterward, but public releases and GitHub records remain.

Advanced users can build the library on macOS with `bash scripts/build.sh` and package locally using Python 3.11+:

```sh
python3 scripts/package.py "/path/to/authorized-base.ipa" "artifacts/QuietTube.dylib" "artifacts/QuietTube-1.0.0-local.ipa"
```

On Windows, the Python packaging step can use `py -3` with a matching compiled library. The normal Actions flow doesn't need these local tools.

</details>

**A file host, fork or permission checkbox is not a legal guarantee.** Only use and share files you have the rights to use and share. [Privacy](PRIVACY.md) · [Settings](SETTINGS.md)
