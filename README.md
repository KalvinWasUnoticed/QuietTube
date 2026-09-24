<p align="center">
  <img src="docs/assets/banner.svg" width="100%" alt="QuietTube — Less noise. More video. A simpler way to watch, still the native app.">
</p>

<p align="center">
  <strong>An annoyance-free idea. A quieter way to watch.</strong><br>
  Native YouTube customization for iOS, built around the video—not everything surrounding it.
</p>

<p align="center">
  <a href="https://github.com/KalvinWasUnoticed/QuietTube/fork"><strong>Fork & build ↗</strong></a>
  &nbsp; · &nbsp; <a href="docs/INSTALL.md">Installation guide</a>
  &nbsp; · &nbsp; <a href="https://github.com/KalvinWasUnoticed/QuietTube/issues">Get help</a>
</p>

> **Source-first release.** Actions builds **QuietTube's library only**. No YouTube app, base-app download or prebuilt IPA is provided. Local packaging requires a computer, Python 3.11+ and your own authorized, exactly compatible base. [Read the requirements first →](docs/INSTALL.md#before-you-start)

## Why QuietTube?

QuietTube started with a simple frustration: opening YouTube to watch a video, then dealing with ads, promotional shelves and recommendations you never asked for.

The goal isn't to add another screen full of features. It's to make watching feel simple again: fewer interruptions, a calmer feed and controls that stay out of the way. The familiar native player stays. You choose what disappears.

## Keep the video. Lose the clutter.

| A little less… | A little more… |
| :--- | :--- |
| **Ad interruption** | Video-ad protection and filtering for recognized feed ads, including the tested post-minimize insertion path. |
| **Feed noise** | Optional hiding of Shorts shelves, Mixes, Watch it again, topic suggestions, Playables, promotional shelves and large portrait cards. |
| **Unwanted next videos** | A switch to stop supported automatic next-video actions. |
| **Settings friction** | Two preview-before-Apply presets, automatic prerequisite handling and restart notices without confirmation dialogs. |
| **Unnecessary reinvention** | Background audio, YouTube's native PiP setting and the classic header logo. |

These are scoped rules, not a promise to remove every ad or every matching surface. Shorts-tab removal, downloads and SponsorBlock are **not** included. [Coverage & limitations →](docs/SETTINGS.md)

## Your settings, not another dashboard

<p align="center">
  <a href="docs/assets/settings.png"><img src="docs/assets/settings.png" width="300" alt="Quiet controls home: master switch, Presets, Ads, Feed, Playback, Appearance and Advanced."></a>
  &nbsp;&nbsp;
  <a href="docs/assets/presets.png"><img src="docs/assets/presets.png" width="300" alt="Preset chooser with Ads and essentials and Focused feed."></a>
</p>
<p align="center"><sub>Real screenshots supplied from the tested RC1 settings build. Cropped/resized only; the layout is retained in 1.0.0. Right: preset chooser, not the Apply preview.</sub></p>

**Ads & essentials** enables ad protection and the classic logo, with detailed logging off. **Focused feed** adds the available feed-cleanup options. Both show what will change before you apply them and leave background-audio/next-video preferences alone.

Find everything at **You → Settings → General → Quiet controls**. Existing preferences are kept on upgrade. Fresh installs opt in. Changes apply after fully stopping and reopening the LiveContainer guest.

## Build it on your fork

1. **Fork** this repository into your GitHub account.
2. In **your fork**, open **Actions** and enable workflows if prompted.
3. Select **Build QuietTube library → Run workflow**. No Apple credentials or base-app URL are requested.
4. Download the **library artifact ZIP** from the successful run's Summary. It is **not an IPA**.
5. Follow the [local packaging and LiveContainer guide](docs/INSTALL.md) using your own authorized compatible base.

The complete guide also links the official SideStore setup instructions. The cloud build needs no local Xcode; the local packaging step still needs a computer with Python. Nothing runs automatically to build an app when someone forks the repository.

## Tested, with boundaries

| Component | Reported test environment |
| :--- | :--- |
| Device | **iPhone 14** |
| iOS | **26.5** |
| LiveContainer | **3.8.0**, installed through SideStore |
| YouTube base | **21.38.2**, exact SHA256 checked by the local packager |
| Confirmed by the maintainer | Ad blocking, Google sign-in, native PiP, background audio and the redesigned settings |

That evidence comes from the working 0.13.5 runtime and RC1 settings build retained for 1.0.0. It is not a broad compatibility matrix or a fresh test of every 1.0.0 artifact. The library targets iOS 17+ / arm64; other devices, app binaries and future server changes are not validated. [Validation & development →](CONTRIBUTING.md)

## Small by design

No automatic QuietTube diagnostic upload, activation service or added analytics endpoint. Optional local support reports are available under **Advanced → Troubleshooting**. Review them before sharing. YouTube and LiveContainer have their own data practices. [Privacy →](docs/PRIVACY.md)

For problems, [open an issue](https://github.com/KalvinWasUnoticed/QuietTube/issues/new/choose) with your version, device and steps to reproduce—never credentials or app binaries. Keep your known-working local build for rollback.

---

Made by **[KalvinWasUnoticed](https://github.com/KalvinWasUnoticed)** · [MIT source license](LICENSE) · [Credits & third-party notices](Notices/REFERENCES.md) · [Changelog](CHANGELOG.md)

<sub>QuietTube is unofficial and is not affiliated with or endorsed by YouTube or Google. YouTube and Google are their owners' trademarks. The source license does not license their app, services or branding. Source-only distribution reduces some risks; it does not guarantee immunity from legal claims or takedowns.</sub>
