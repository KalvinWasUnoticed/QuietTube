<p align="center">
  <img src="docs/assets/banner.svg" width="100%" alt="QuietTube — Less noise. More video.">
</p>

<p align="center">
  <strong>YouTube, without so much getting in the way.</strong><br>
  Less clutter. Fewer interruptions. The native player you already know.
</p>

<p align="center">
  <a href="https://github.com/KalvinWasUnoticed/QuietTube/fork"><strong>Fork & build ↗</strong></a>
  &nbsp; · &nbsp; <a href="docs/INSTALL.md">Easy setup guide</a>
  &nbsp; · &nbsp; <a href="https://github.com/KalvinWasUnoticed/QuietTube/issues">Get help</a>
</p>

## Just watch the video

QuietTube started with a simple annoyance: opening YouTube to watch something, then dealing with ads, promotional shelves and a feed full of distractions.

It keeps the familiar app and lets you remove the parts you don't want. No replacement player. No extra dashboard.

| Less of this | More of this |
| :--- | :--- |
| **Ads** | Video-ad protection and filtering for recognized sponsored feed items. |
| **Feed clutter** | Options to hide Shorts shelves, Mixes, Watch it again, topics, Playables and promotional cards. |
| **Unwanted autoplay** | Control over supported automatic next-video actions. |
| **Settings hassle** | Two presets, a preview before Apply, and restart notices that don't interrupt you. |

Background audio and the classic logo are included. PiP uses YouTube's own setting. Coverage isn't universal; downloads, SponsorBlock and Shorts-tab removal are not included. [Settings and limits →](docs/SETTINGS.md)

## Build your copy

**Upload your IPA → copy the link → run Actions → download the result.**

1. Have your own compatible **decrypted YouTube 21.38.2 IPA** ready. We don't provide one.
2. Upload it to [Catbox](https://catbox.moe/) or another file host that gives a direct HTTPS download link. Only upload files you have permission to share.
3. **Fork this repository.** In your fork, open **Actions → Build QuietTube IPA → Run workflow**.
4. Paste the file link, read the permission/publication notice and start the build.
5. When it finishes, choose **Summary → DOWNLOAD IPA**, or open your fork's **Releases**. Install the result with your preferred IPA installer.

[Step-by-step guide, including Catbox and installation →](docs/INSTALL.md)

> The build automatically checks that your IPA is the exact supported file. A different copy can be rejected even if it says 21.38.2. Catbox currently accepts files up to 200 MB; use another direct-link host for larger files. A public fork publishes a public download.

## Set it once. Get on with watching.

<p align="center">
  <a href="docs/assets/settings.png"><img src="docs/assets/settings.png" width="280" alt="Quiet controls home with Presets, Ads, Feed, Playback, Appearance and Advanced."></a>
  &nbsp;&nbsp;
  <a href="docs/assets/presets.png"><img src="docs/assets/presets.png" width="280" alt="The Ads and essentials and Focused feed preset choices."></a>
</p>
<p align="center"><sub>Real screenshots from the tested RC1 build. Same settings layout; current restart wording is installer-neutral. Images are cropped/resized, not edited UI mockups.</sub></p>

Open **You → Settings → General → Quiet controls**.

- **Ads & essentials:** ad protection and the classic logo, with detailed logging off.
- **Focused feed:** the essentials plus the available feed-cleanup options.

Both preview the changes before applying and leave your background-audio/next-video choices alone. On a fresh installation, QuietTube, video-ad blocking and feed-ad blocking start **on**. Existing on/off choices survive updates and restarts. Fully close and reopen the app after making changes.

**Updating from 1.0.0?** If video-ad blocking was already switched off by the old safety latch, turn it on once after updating, then reopen the app. We won’t override an existing off setting because it could be your own choice. A playback error can temporarily pause protection for that session; it no longer changes your saved toggle.

## Tested, not guessed

**iPhone 14 · iOS 26.5 · LiveContainer 3.8.0 · YouTube 21.38.2**

Ad blocking, Google sign-in, native PiP, background audio and the settings were confirmed in this setup. LiveContainer was the **test environment**, not a design requirement. Other sideloading methods have not been verified; signing, installation and sign-in behavior can vary. The package needs your installer's signing/preparation and does not include app extensions.

The player/feed implementation is retained from the working development builds. Version 1.1.0 adds manual local diagnostic sessions while retaining the preference fix. Apple compilation, the new native tests and each new output still need validation. No promise of every ad blocked or compatibility with every installer.

---

Made by **[KalvinWasUnoticed](https://github.com/KalvinWasUnoticed)** · [Privacy](docs/PRIVACY.md) · [MIT license](LICENSE) · [Credits](Notices/REFERENCES.md) · [Changelog](CHANGELOG.md)

<sub>Unofficial. Not affiliated with YouTube or Google. Use and share only files you have the rights to use and share. A fork, an upload service or a disclaimer does not guarantee protection from copyright claims.</sub>

Audit scope and test evidence: [1.1.0 audit](docs/AUDIT-1.1.0.md).

**Need to capture a playback/feed problem?** Start a manual session in Advanced → Troubleshooting, reproduce it briefly, then stop and export. Local files are bounded and recording stops on relaunch. [What it captures and how to clear it →](docs/DIAGNOSTICS.md)

## Download just the tweak

The IPA build now also publishes **QuietTube.dylib** separately. To release only the library—without downloading or distributing a YouTube IPA—run **Actions → Build QuietTube dylib only** in the original repository or a fork. Choose prerelease or regular release on each run. [Release flow guide →](docs/RELEASE-FLOWS.md)
