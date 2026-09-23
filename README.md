# QuietTube — experimental native YouTube tweak

**Target:** your inspected YouTube **21.38.2** IPA, iPhone 14 / iOS 26.5, **LiveContainer 3.8.0 in normal launch mode**.

**This ZIP is source code and a build workflow, not a compiled IPA.** GitHub Actions compiles the tweak on macOS, downloads the exact inspected base IPA, checks its SHA-256, and produces `QuietTube-21.38.2-experimental.ipa` for import into LiveContainer.

**Status: prototype 0.1.** The packaging tests and a load-command injection dry run on the supplied executable passed. The Objective-C code has NOT been compiled in the authoring environment, and this modified app has NOT been device-tested. The first GitHub build is also the first Apple-SDK compilation test. A successful build does not prove ad blocking or uninterrupted playback.

## Why this first experiment is different from a large mod bundle

The supplied clean IPA played two videos beyond five minutes in your LiveContainer environment. That establishes a baseline, not the exact cause of failures in previous modified builds.

This implementation changes only selected behavior:

- Player-ad filtering intercepts explicit `YTIPlayerResponse` ad-array getters.
- It preserves request context, client identity, signal generation, and authentication behavior.
- Feed/companion filtering and UI cleanup have separate flags from player-ad filtering.
- It does not rewrite playback requests, forge Premium status, install a proxy, add a downloader, or continually retry playback errors.
- It observes numeric playback error codes without hiding the native error or recording error descriptions, request URLs, cookies, or account tokens.

This is an original small implementation informed by the credited public interfaces and projects; the underlying idea of filtering ad arrays is NOT claimed as a novel discovery. It may still cause the same 10–20-second failure. It is not a demonstrated anti-detection bypass, and the server may use ad paths these hooks do not cover.

## Build your IPA on GitHub

### 1. Create and populate a repository

Create an empty GitHub repository. Prefer private if you do not want the input URL and artifacts exposed to others; private macOS Actions jobs may consume paid minutes. Check your account's Actions allowance/billing first.

Extract this ZIP, then upload the **contents of `QuietTube-prototype`** to the repository root. Your repository root must contain:

```
.github/workflows/build.yml
Sources/
scripts/
tests/
Notices/
README.md
```

**The `.github` folder is hidden on some computers.** Enable hidden files. If GitHub's upload flow omits it, use **Add file → Create new file**, name it `.github/workflows/build.yml`, paste the contents of the supplied workflow, and commit.

No Apple ID, certificate, Google credentials, GitHub secrets, or third-party activation key is required for the build. Do not commit the base IPA or personal account data. The build URL points to the file you supplied; keep access limited to people you authorize to use it. The URL is not an endorsement of the host or proof of authenticity.

### 2. Run the build

1. Open **Actions → Build QuietTube IPA**.
2. Select **Run workflow** and confirm.
3. Wait for success. If compilation fails, open **Compile the tweak** and share the error text; do not expect an IPA from a failed run.
4. Open the successful run's summary.
5. Download **QuietTube-21.38.2-experimental-IPA** under Artifacts.
6. Extract that artifact ZIP to obtain **QuietTube-21.38.2-experimental.ipa**.

Do not rename the artifact ZIP to `.ipa`. The actual IPA is inside it.

The workflow also produces a separate `QuietTube-dylib-debugging-only` artifact. You do **not** need it when importing the packaged IPA. Do not add it as an external tweak on top of the packaged IPA, or you may load the modification twice.

The base download is SHA-256 pinned. If Catbox removes or changes the file, the build fails instead of substituting an unverified IPA. Retain your own original copy. Do not change the expected hash without deliberately reinspecting the replacement file.

### 3. Install in LiveContainer

1. Preserve your clean installation and data. If LiveContainer offers a separate app/data-container import, use it. Do not approve a destructive replacement without a backup.
2. Disable other global/app-specific YouTube tweaks for this test.
3. Import `QuietTube-21.38.2-experimental.ipa` with LiveContainer's app import **+** action.
4. Allow LiveContainer to sign the guest app as required by your setup.
5. Launch in **normal mode**, not Multitask, for the first test.
6. Sign in using the normal YouTube interface.

The package contains a compiled, ad-hoc-signed dylib and a modified app executable with invalidated old signatures. It is deliberately **not a standalone Apple-signed installation package**. LiveContainer must perform its signing/preparation. You still refresh your LiveContainer installation via SideStore as required by your free-account setup.

The packager removes app extensions (`PlugIns`) and stale provisioning/bundle signature files. Widgets and native YouTube share extensions are not part of this prototype. It leaves the main app's bundle identifier and version unchanged to avoid unnecessary login changes.

## Where the switches are

**You → Settings → General → Quiet controls** (a row appended to General).

Inside:

- **Enable modifications** — master switch.
- **Distractions** — UI and feed cleanup.
- **Playback** — player ads, background audio, PiP, autoplay, previews.
- **Advanced** — diagnostics, UI-only mode, and reset.

There is no new tab, floating button, player badge, startup alert, or added home screen. The entry stays available with the master switch off. Restart the guest app after changing flags to rebuild cached UI/player objects.

If the entry does not appear, settings integration is not working for this runtime. Do not assume the switches are accessible elsewhere: revert to the preserved clean app and report this as a compatibility failure.

## Flags and limits

| Control | Default | Implementation / limit |
|---|---|---|
| Player-ad blocking | On | Explicit player-response ad arrays; experimental, no anti-detection guarantee |
| Feed / companion ads | Hide | Explicit ad fields and selected element markers; not every ad surface is covered |
| Promotional prompts | Hide | Selected promo controllers; no blanket suppression of errors or consent |
| Shorts tab | Hide | Native pivot identifiers; only applies when recognized |
| Shorts shelves | Hide | Known reel/Shorts renderers and element markers |
| Home recommendations | Hide | Hides content collection only when the Home browse ID is recognized; header/navigation retained |
| Related videos | Hide | Native visible-section limiting plus selected related-element filtering; version-sensitive |
| End-screen suggestions | Hide | Known view getter/class/identifiers; may miss redesigned elements |
| Comment previews | Show | Optional preview filtering, not a comprehensive comment-access block |
| Community posts | Hide | Known post renderers and element markers |
| Create tab | Hide | Recognized pivot identifiers |
| Notification bell | Hide | Native button getter and accessibility identifiers |
| Cast button | Show | Optional visibility only; does not disable discovery |
| Autoplay next video | Stop | Selected autonav getters and transition methods; playlist behavior needs testing |
| Feed previews | Stop | Candidate getter hooks; if unavailable, turn off Playback in feeds in YouTube's own settings |
| Background audio | On | Native background-eligibility hooks; LiveContainer operation unverified |
| Picture in Picture | On | Native PiP-eligibility hooks, not a replacement player or a forced activation loop |
| Shorts links in regular player | Off | **Deferred: no switch/implementation in 0.1**, rather than a nonfunctional toggle |

Features only attach when the expected method and ABI-compatible signature are found. No fabricated methods are added to make unsupported features appear available. Diagnostics say **unavailable**, **signature mismatch**, or **installed (behavior unverified)** for every attempted hook. Even an installed hook can be irrelevant to a server-selected UI/player path.

### Coverage is intentionally not described as complete

You may still see feed ads, companion ads, empty spaces, Shorts, Home content, or previews in the first build. This is a testable starting point for the exact IPA, not a repackaged full-featured mod advertised as finished.

## First device test

The clean control already passed. Now:

1. Confirm Quiet controls is reachable.
2. With selected defaults, play the same two videos beyond five minutes. Observe whether player ads are absent and playback remains uninterrupted.
3. If the 10–20-second error returns, **do not repeatedly tap Retry as a workaround**. In Quiet controls → Playback, disable **Block player ads**, restart the guest app, and test again.
4. If it still fails, use **Advanced → UI-only test mode**, restart and repeat. This turns off all Playback switches, preserving UI cleanup.
5. If necessary turn off **Enable modifications**, restart, and compare. If it crashes before settings or cannot open, return to your preserved clean app.
6. After stable foreground playback, test lock-screen audio and PiP separately. Ensure automatic PiP is enabled in iOS and YouTube. Report failures rather than assuming eligibility hooks are enough.

Report:

- Which switches were on, and whether you restarted after changing them.
- Whether ads appeared and at which surface.
- Whether the same error returned, and approximately when.
- Diagnostic text from Advanced → View diagnostics (select and copy).
- Whether the settings entry, PiP, or background audio worked.

Diagnostics stay in memory for the current process; no telemetry is sent. They contain flags, hook names/statuses, counters and numeric error codes, not watch history or account credentials. A hook invocation count is **not** a count of unique ads blocked.

## Verification actually performed

See `VALIDATION.json`:

- Eight Python packaging unit tests passed locally.
- The actual supplied main executable accepted the new load command within verified zero header padding; command count 137 → 138, file length unchanged. Patched test bytes were discarded.
- The actual base IPA hash was verified.
- Objective-C compilation: **not run here** (Linux authoring environment, no Apple SDK).
- LiveContainer signing/launch/playback test of modified build: **not run**.

## Local build on a Mac

With Xcode and Python 3.11+:

```sh
bash scripts/build.sh
python3 -m unittest discover -s tests -v
python3 scripts/package.py /path/to/original.ipa artifacts/QuietTube.dylib artifacts/QuietTube-21.38.2-experimental.ipa
```

## Source and licensing

The source builds using Apple's Foundation/UIKit and Objective-C runtime; no bundled hooking framework, telemetry SDK, stream extractor, or external playback server. Compile inputs are the checked-in source, not a floating upstream tweak download.

`Notices/REFERENCES.md` records the inspected references and third-party attribution. Full license notices are included in this source archive and copied into the generated app. YouTube itself is proprietary and is not included in this source archive; rights to this tweak do not grant rights to redistribute YouTube.
