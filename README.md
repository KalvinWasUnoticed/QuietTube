<picture>
  <img src="docs/assets/banner.svg" width="100%" alt="QuietTube — a YouTube tweak for iOS.">
</picture>

An iOS tweak for YouTube **21.38.2**. It adds video-ad blocking and feed filters while keeping YouTube’s native player.

I built it with AI help because I wanted fewer ads and less junk in the feed. Shorts shelves, Mixes and Playables have separate switches. Some ad formats still get through.

Settings are under **You → Settings → General → Quiet controls**.

## Get it

| What you want | Where to go |
| --- | --- |
| Just `QuietTube.dylib` | [Releases](https://github.com/KalvinWasUnoticed/QuietTube/releases), or run **Build QuietTube dylib only** in this repo or a fork. No IPA URL needed. |
| An IPA with QuietTube included | Fork the repo, supply your compatible decrypted YouTube IPA, then run **Build QuietTube IPA**. It publishes the IPA and a separate dylib in your fork. |

The dylib is not an app you can install on its own. The IPA already contains it; don’t inject it twice.

[IPA build and install steps](docs/INSTALL.md) · [Both release workflows](docs/RELEASE-FLOWS.md)

The IPA workflow checks the **exact input hash**, not just the version number. It can reject a different copy of 21.38.2. You supply the base app and need the rights to upload, modify and share it. A public fork means a public release.

## What you can change

- Video ads and recognized sponsored feed items.
- Shorts shelves, Mixes, Watch it again, topic suggestions, Playables, promotional shelves and large portrait cards.
- Background audio, supported automatic next-video actions and seasonal logo artwork.
- Two presets with a preview before Apply.

PiP uses YouTube’s own setting. There’s no SponsorBlock, video downloader or Shorts-tab removal. [Settings and specific limits](docs/SETTINGS.md).

## Settings

<p>
  <a href="docs/assets/settings.png"><img src="docs/assets/settings.png" width="280" alt="Quiet controls home: Presets, Ads, Feed, Playback, Appearance and Advanced."></a>
  <a href="docs/assets/presets.png"><img src="docs/assets/presets.png" width="280" alt="The Ads and essentials and Focused feed preset choices."></a>
</p>

<sub>Real screenshots from the earlier RC1 build. These show the home and preset pages, not the newer diagnostic controls. Cropped and resized; no redrawn UI.</sub>

Fresh installs start with the master switch and video/feed ad blocking on. Updates keep saved choices. Close and reopen the app after changing switches; refreshing the feed doesn’t count.

Coming from 1.0.0 with video blocking unexpectedly off? [The upgrade note explains what happened](docs/SETTINGS.md#upgrading-from-100).

## Tested setup

**iPhone 14 · iOS 26.5 · LiveContainer 3.8.0 · YouTube 21.38.2**

Earlier builds were tested here for ad blocking, Google sign-in, native PiP, background audio and settings. LiveContainer is the reported test environment, not a design requirement. Other sideloading methods have not been verified. Signing and sign-in behavior can differ; the packaged IPA needs signing/preparation through your installer and has app extensions removed.

## Report a problem

Open an [issue](https://github.com/KalvinWasUnoticed/QuietTube/issues) with the version, device, installation method and what happened. For build failures, include the error from the failed step—not just “build failed.”

For playback or feed problems, turn on **Enhanced logging** in **Quiet controls → Advanced → Troubleshooting** — one master switch (on = `● Collecting`), plus **Export logs** and **Clear logs**. Leave it on during daily use; when you see an intrusive shelf or an ad slip through, tap **Export logs** right away — no need to reproduce in a separate test session. Files are 3 × 256 KiB, 7-day, no upload. Review before sharing. [Logger details](docs/DIAGNOSTICS.md).

---

[KalvinWasUnoticed](https://github.com/KalvinWasUnoticed) · [Credits](Notices/REFERENCES.md) · [Release notes](https://github.com/KalvinWasUnoticed/QuietTube/releases) · [Contributing](CONTRIBUTING.md) · [Privacy](docs/PRIVACY.md) · [MIT license](LICENSE)

Unofficial. Not affiliated with YouTube or Google. The MIT license covers QuietTube’s source, not YouTube’s app or trademarks. A fork, file host or disclaimer does not protect you from copyright claims.
