# QuietTube 0.3 — native PiP cleanup and settings navigation

Source + GitHub IPA build workflow for the same inspected YouTube 21.38.2 base. **Not a compiled IPA. The 0.3 changes have not been compiled or device-tested in this environment.**

## Changes

- Removed Quiet controls' PiP switch AND all QuietTube PiP-eligibility hooks. Old saved `pip` preferences are ignored. Use YouTube's own PiP setting.
- Kept **Settings → General → Quiet controls** as the only entry.
- Quiet controls now opens a standard UIKit navigation sheet with its own navigation bar. **Done** returns to YouTube's General settings. Subpages use normal back chevrons in the sheet; a minimal back title reduces crowding.
- The sheet has a large detent and standard system-managed insets. No global navigation appearance or YouTube navigation-bar layout hooks are installed. This is a proposed fix for the clipped General back button, awaiting your device test.
- Feed filtering, Shorts filtering, background audio, and autoplay code are otherwise unchanged from 0.2. No player-ad blocking experiment is enabled or introduced.
- Your existing 0.2 flags are preserved if the same app data container is retained. Fresh installs start off; upgrading an old 0.1 container still receives the existing one-time recovery reset.

## Build and install

1. Keep your working 0.2 IPA as a rollback copy and preserve its app data.
2. Extract `QuietTube-v0.3.zip`. Upload the **contents** of `QuietTube-v0.3` to your existing repository root, replacing the old files. Include the hidden `.github/workflows/build.yml`.
3. Run **Actions → Build QuietTube IPA → Run workflow**.
4. Download the successful artifact **QuietTube-0.3-21.38.2-IPA**. Extract it to get `QuietTube-0.3-21.38.2.ipa`.
5. Import through LiveContainer as before and let it re-sign/prepare the guest. Do not install the debugging dylib on top of the packaged IPA.
6. Fully restart the guest process. Check the footer says **0.3**.

The workflow uses the same Catbox input and pinned SHA-256 as before, not a modified previous build. No Apple or Google credentials are required. Check macOS Actions allowances/billing; artifacts expire after seven days. If compilation fails, share the failed step rather than installing an old artifact by mistake.

## Short UI verification

- Open Quiet controls: its navigation controls should fit inside the screen/sheet.
- Open Distractions and Playback, go back, then tap Done. Done should return to General.
- Check that the PiP switch is gone and your other saved switches are retained when using the same data container.
- Confirm native YouTube PiP still works with YouTube's own setting enabled.
- Confirm feed loading/refresh and background audio still work.

If the sheet fails to open or a control is clipped, send a screenshot. The settings presentation integration still depends on the native settings controller being a visible UIViewController; unsupported presentation is counted in diagnostics rather than using an unsafe fallback.

## Current feature status

User-tested individually in 0.2: feed-ad filtering, Shorts-shelf filtering, background audio. Native YouTube PiP also passed the user's tests, without needing our PiP flag. These reports are not exhaustive validation of all videos, devices or layouts.

Player-ad blocking and Home hiding remain paused. Other original requested visibility features have not yet been restored. Video ads are expected. The autoplay experiment remains available but has not been reported tested.

`PLAYER-ADS-RESEARCH.md` compares reviewed techniques and proposes the next isolated player experiment. No new player-ad mutation, network interception, account modification, retry loop or signal suppression is bundled with this UI update.

## Verification and source

- Packaging unit tests and source regression tests run locally; see `VALIDATION.json`.
- Prior injection dry run applies to the unchanged packager and exact same base; it is not a playback test.
- 0.3 compilation/device testing: not performed here. GitHub must compile it and the iPhone must verify behavior.
- `Sources` contains all native code; build uses Apple's Foundation/UIKit/Objective-C runtime, without an external hook framework.
- Existing third-party notices remain in `Notices`; YouTube itself is proprietary and not contained in this source ZIP.

The guest package has invalidated old signatures and removed app extensions; it is intended for LiveContainer re-signing, not direct installation by opening it in Files.
