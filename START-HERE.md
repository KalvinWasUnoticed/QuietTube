# Complete RC1 update — not a patch

This ZIP contains the full redesigned RC1 sources AND the packaging/publishing handoff fix. Its files are placed at archive root so they map directly to your repository root.

1. Extract everything. Upload/replace ALL included repository files, especially the complete Sources, scripts, tests and hidden .github folders, plus root JSON manifests. Do not upload only the workflow or release script. Do not put these files inside an extra QuietTube subfolder in the repository.
2. Confirm GitHub shows Sources/QTSettingsModel.m and Sources/QTSettingsModel.h. Sources/QTSettings.m must contain the Presets/Ads/Feed/Appearance pages and the 0.14.0-rc1 footer. The repository README must describe the settings release, not just the handoff patch.
3. Commit and start a NEW workflow run from that commit. The new “Verify complete RC1 sources” step must pass. It rejects old/missing source or build files before compilation.
4. Download from THAT run's Summary link. Import/replace the intended LiveContainer guest, preserving its data container. Fully stop the guest and relaunch it. Do not delete your account/app data to resolve a version mismatch.
5. Open Quiet controls. The root should show Enable QuietTube, Presets, Ads, Feed, Playback, Appearance and Advanced. The footer should say 0.14.0-rc1. Playback should contain Background audio and Stop the next video. Block video ads is now in Ads.

If the repository/verification step matches but the phone still displays the 0.13.5 footer, check the downloaded IPA/run and the specific LiveContainer guest being launched. Changing flags cannot load a different settings implementation. No need for another ad test until the correct UI is loaded.

Existing preferences are preserved; presets are optional. Player/feed runtime hashes remain unchanged from the earlier RC1 package, which preserves the 0.13.5 logic. This correction changes the distribution/validation handoff, not the blocking algorithms.

Old root AUDIT.md, BINARY-RESEARCH.md and PLAYER-ADS-RESEARCH.md may be removed; their history is under docs/history. Keep LICENSE and Notices.
