# Fork → provide your base → build → download IPA

[← QuietTube](../README.md)

The workflow builds in **your fork** and publishes the completed `.ipa` to **your fork's Releases**. It does not require local Xcode or local Python. The original QuietTube repository does not provide a YouTube base download.

## Before you start

- A GitHub account and a fork of [QuietTube](https://github.com/KalvinWasUnoticed/QuietTube/fork).
- Working SideStore and LiveContainer on your iPhone. Confirmed test setup: **iPhone 14 / iOS 26.5 / LiveContainer 3.8.0**.
- An authorized, decrypted **YouTube 21.38.2** base IPA and a public-network **direct HTTPS download link** to that file. It must not require a login, cookie, browser confirmation or HTML download page. HTTPS redirects are allowed only to public HTTPS destinations on the standard port.
- The necessary rights to obtain, modify and publish that app. A public fork produces public release assets. The acknowledgement is not independent legal clearance, and this flow is not a DMCA guarantee.

The exact supported input SHA256 is:

```text
d0f6f5c9d27f7fea8f040ae59c425b3a8222f67d891937374b21ef8937deba11
```

**Version number alone is not sufficient.** A different repackaging of 21.38.2 can have a different hash and will be rejected. The protection is retained to avoid silently running private hooks against a different app binary. Do not change the hash to force an unverified input through. This project supplies no base download or decryption instructions.

Workflow inputs are not secrets. Do not include embedded credentials or sensitive long-lived tokens in the URL. URLs may remain in workflow/event records even though the download script masks its own logs. Files over 2 GiB, non-HTTPS/private-network destinations, incomplete downloads, HTML responses and hash mismatches are rejected. DNS checks are defense-in-depth, not a sandbox against every DNS/network attack.

## 1. Prepare SideStore and LiveContainer

Already have them working? Skip to step 2.

1. Follow official SideStore [prerequisites](https://docs.sidestore.io/docs/installation/prerequisites) and [installation](https://docs.sidestore.io/docs/installation/install). Complete its device trust, Developer Mode where applicable, VPN and refresh setup.
2. Follow [LiveContainer's installation guide](https://livecontainer.github.io/docs/installation). The tested route uses standalone LiveContainer installed through SideStore.
3. Open LiveContainer once and confirm it runs. Keep Apple credentials in the official setup tools—QuietTube Actions never requests them.

Their official instructions govern their setup and may change over time. Keep your working guest/data container for rollback.

## 2. Fork and build

1. On [QuietTube](https://github.com/KalvinWasUnoticed/QuietTube), choose **Fork → Create fork**.
2. Open **your fork → Actions**. Enable workflows if GitHub prompts you.
3. Select **Build QuietTube IPA**, then **Run workflow** on your intended branch.
4. Paste the direct HTTPS file link into **base_ipa_url**.
5. Read and check **acknowledge_rights** only if you have the necessary rights and understand the publication visibility.
6. Click **Run workflow**. The build job is skipped outside a fork or without the acknowledgement. No IPA is produced in that case.

The job verifies release-source consistency and regression tests, downloads/verifies your base, compiles QuietTube with the Apple SDK, packages the IPA and publishes to the repository that ran it. It uses GitHub's supplied token; no personal access token or Apple account is needed. Organization restrictions can still prohibit workflow write permissions or release creation.

A fresh run checks out its source commit. After changing files, start a **new run**, not a rerun tied to an old commit.

## 3. Download your IPA

1. Open the successful run's **Summary → DOWNLOAD IPA — QuietTube 1.0.0**.
2. Alternatively open **your fork → Releases**, then the release named **QuietTube 1.0.0 — build …**.
3. Download **QuietTube-1.0.0-21.38.2.ipa**. This is the actual IPA, not an artifact ZIP.
4. The same release contains **BUILD-INFO.json** (source repository, commit, run and output SHA256) and **SHA256SUMS**. Check these if identifying or verifying a download. The Summary also shows the hash.

The tag includes the run ID and attempt, so an older release is not silently overwritten. The publisher uploads as a draft, then publishes only after upload succeeds. Failed publication can leave a draft requiring cleanup, but the workflow does not write a success link. All generated releases are marked **prerelease** because successful packaging is not device testing of that particular artifact.

For a private repository with access, sign in to GitHub before downloading. An ordinary fork of a public repository is generally public: do not assume that Actions inputs or release assets are private. The checked-out repository credentials are not persisted, and the release token is passed only to the publishing step. Temporary runner files are removed after the job; published assets remain until deleted by the fork owner.

## 4. Import and enable

1. Save the IPA to Files on your iPhone.
2. Open LiveContainer, tap **+**, and select the IPA. Let LiveContainer sign/prepare the guest. Do not inject QuietTube a second time.
3. When updating, preserve the guest's existing data/container and your known-working backup. Do not delete account data to troubleshoot a version mismatch.
4. Fully stop the guest, then launch the intended updated copy.
5. Open **You → Settings → General → Quiet controls**. The footer should show **1.0.0**.
6. New users can preview and Apply **Ads & essentials** or **Focused feed**. Existing preferences are preserved on upgrade; no preset is silently applied.
7. Fully restart the guest after changing settings. Refreshing Home is not a restart.

Use YouTube's native PiP setting. QuietTube has a separate Background audio option; presets intentionally leave it and the next-video preference alone.

## Troubleshooting

| Symptom | What to check |
| --- | --- |
| Build job skipped | Run in your fork and enable the acknowledgement if you have the necessary rights. The upstream repository cannot run this publishing job. |
| No Run workflow button | You are in your fork, Actions is enabled, and the selected branch has the current workflow. |
| Mixed source error | Replace the entire release tree, including hidden `.github` and the manifest; remove listed obsolete files. Do not regenerate hashes to hide old code. |
| Download rejected | Direct public HTTPS file, no login, exact input SHA256, size/time limits. The error intentionally avoids echoing your URL. |
| Hash/encryption/version error | Wrong or incompatible input. The repository does not provide a replacement; do not bypass validation. |
| Compile failure | Report the compiler error and source commit, not account details or your private download URL. |
| Publish permission failure | Check repository/organization Actions permissions. The build job requests `contents: write`. Inspect Releases for an incomplete draft before starting a new run. |
| Old UI or footer | Check the run/commit, downloaded IPA and selected LiveContainer guest; fully stop/relaunch. |
| Playback/feed regression | Review the short support report, restart and restore your known-working build if necessary. |

To pause QuietTube without clearing preferences, turn off **Enable QuietTube** and restart. [Settings and limits →](SETTINGS.md)

## Optional offline packaging

Advanced users can still compile on macOS with `bash scripts/build.sh`, or use their own matching compiled library. Python 3.11+ can package without uploading the base:

```sh
python3 scripts/package.py "/path/to/authorized-base.ipa" "artifacts/QuietTube.dylib" "artifacts/QuietTube-1.0.0-local.ipa"
```

Windows users can run the Python packaging step with `py -3` and a matching compiled library. It has the same strict input checks. The cloud flow above is the primary supported tutorial; it does not need these local tools.
