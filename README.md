# QuietTube 0.10 — player test 0: observation only

**This source package does not block in-video ads.** It is the agreed observation stage before trying blocking solutions one at a time. The release workflow builds an IPA for the same pinned YouTube 21.38.2 base; no compiled IPA is included here.

## What changed

New **Playback → Observe player ad coordinator** switch, off by default. It adds one signature-checked hook candidate: `YTLocalPlaybackController / createAdsPlaybackCoordinator`. With the probe enabled, it counts calls and object/nil results, calls the original exactly once, and returns the same object. Native exceptions are not swallowed; counter exceptions alone are isolated. No payloads or objects are described or stored by the probe.

The selector comes from reviewed public YouTube-X source; availability/ABI are checked on device, not assumed. It has NOT been statically verified against the supplied executable for this release. An unavailable or mismatched selector is skipped. A non-nil coordinator does not prove an ad played or that suppressing it is safe. An installed hook does not prove it ran.

**Player-ad blocking — paused** remains disabled. The new switch is observation, not a hidden ad-removal mode. No player response arrays, requests, client identity, login signals, ad beacons, retries, seeks or fake ad-completion events are altered. Undetectability and zero errors are not promised. Even observation hooks add runtime overhead and require device testing.

## Preserved baseline

Your 0.9.1 playback-with-ads baseline is confirmed stable and feed cleanup is working by your report. All existing feed rules (including Mix RD, inline Shorts and Watch again), logo implementation, settings navigation, background audio, native PiP behavior, playback error observer and preference migration are preserved. Hash checks cover 11 prior source/build files after removing only the probe integration and normalizing version/headline. Full review is in AUDIT.md.

## Build and download

1. Extract `QuietTube-v0.10.zip`. Replace repository files with the contents of `QuietTube-v0.10`, including hidden `.github/workflows/build.yml`, the new `Sources/QTPlayerProbe.m`, and tests/baseline records.
2. Use a private repository where possible. Run **Actions → Build QuietTube IPA → Run workflow**. Public repositories require explicit publication approval; release assets would expose the modified IPA.
3. After success use **Summary → DOWNLOAD IPA — QuietTube 0.10**. The asset is `QuietTube-0.10-21.38.2.ipa`, not an outer artifact ZIP. GitHub's automatic source ZIP/TAR links are not the IPA. Private downloads require an authorized GitHub login.
4. Import into LiveContainer, preserve the same data container and fully restart the guest. Keep 0.9.1 available for rollback. Do not inject the tweak again.

## Run the first test

Settings path: **You → Settings → General → Quiet controls → Playback**.

1. Leave existing working flags unchanged. First check 0.10 with **Observe player ad coordinator OFF**: an ad-bearing normal video should play as before. Player-ad blocking remains paused.
2. Enable **Observe player ad coordinator**, fully stop/relaunch the guest, and verify diagnostics says `PLAYER TEST 0: observation enabled` and `playerProbe = on` under ACTIVE THIS LAUNCH. Refreshing the feed is not a process restart.
3. Play two normal videos, preferably one where a preroll occurs and one long enough for a midroll opportunity. Watch at least five minutes beyond the ad-to-content transition. Ad delivery varies, so absence of an ad on a repeat is not evidence of blocking.
4. If stable, briefly seek, background/lock the phone, and try native PiP. Check the feed and logo remain normal.
5. Share the hook-status line, the three new probe counters, any `playback error … code …` lines, and a short description of what you actually saw. See TEST-PLAN.md. The existing feed-template capture is not needed for this player test; it can be turned off and the guest restarted if desired.

If playback fails, stop the test. Disable the probe and fully restart; if necessary revert to 0.9.1 in the same container. Do not repeatedly retry to mask the failure. Capture the error screen/diagnostics if available. Native crashes may need a separately reviewed crash report; this probe cannot guarantee capture before a crash.

## Validation / limitations

39 Python tests passed (8 packaging, 6 release mocks, 25 source/ABI/scope checks). C tests passed under ASan/UBSan: 79 classifier fixtures + 5,000 random-byte iterations and 20 scanner fixtures + 5,000 random-byte iterations. Build/release shell syntax, workflow YAML and archive integrity checked.

**No Apple SDK compilation, actual GitHub release upload or 0.10 device test was performed here.** Source tests do not execute the native hook or prove unchanged ARC/runtime behavior. GitHub will compile it. Probe data will determine whether this candidate merits a separate default-off blocking experiment; no blocking solution has yet been demonstrated.
