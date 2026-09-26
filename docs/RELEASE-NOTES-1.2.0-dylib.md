# QuietTube 1.2.0 — dylib only

**Just the library, no IPA in here.** I built QuietTube 1.2.0 from the same sources as the IPA fork — this is for you to drop into your own lawfully obtained YouTube 21.38.2. Don’t inject it into the 1.2.0 IPA I already made; it’s already inside. You’ll still need LiveContainer or something that can sign.

---

## From 1.1.0 to 1.2.0 — what moved and why

**Why I changed it:** 1.1.0 had 10 toggles under Troubleshooting (`Record feed activity`, `Record template clues`, `Start/Stop diagnostic session`, `Export/Clear history`, `Prepare support test`, `View support/full report`, `Clear template capture`). People got lost, and you had to remember to turn logging on *before* the bug happened. New shelves (Playables, promo) and the odd player ad that slipped through were hard to catch unless you were already recording. I wanted daily capture you can leave on without thinking.

**What I did:**

1. **10 → 3.** Troubleshooting now has:
   - **Enhanced logging** — one master (`● Collecting` / `○ Off`, footer mirrors it). It stays on across restarts until you turn it off or hit *Disable all options*. `setObject:@(YES)` so it survives, not `setBool:`.
   - **Export logs** — last 3 sessions + support snapshot as text, share sheet so you can review before sending.
   - **Clear logs** — wipes the 3 files, leaves the switch where it was.

2. **Capture while you just use the app.** With master ON I collect feed/player clues the whole time — lifecycle, playback errors, player factory/no-op/safety-pause/fallback, feed mutations, presentation inputs, insertion edges, sampled template names (`YT/ML`-prefixed, at most 4, 12 nodes/depth 3, 256 KiB cap), hook attempts. In 1.1.0 template clues needed a separate `inspectElements` restart — now they’re just there when master is ON. Leave it ON, tap **Export** when you see something odd. No more “reproduce with logging on.”

3. **Still bounded.** `3 × 256 KiB` rotation (768 KiB + 1 temp), 7-day expiry, queue 64 (8 for errors), 30/s (6 for errors), 4 discoveries/s, fields redacted, no auto-upload, `NSURLIsExcludedFromBackupKey` + `CompleteUntilFirstUserAuthentication`.

4. **Presets & UI:** `Ads & essentials` (8→9) and `Focused feed` (15→16) now turn master OFF. Footer shows `● Collecting`/`○ Off`. Docs updated (`DIAGNOSTICS.md`, `SETTINGS.md`, `PRIVACY.md`, `AUDIT-1.2.0.md`, `TEST-CASES-1.2.0.md`).

**What I didn’t touch:** No ad/feed rules, no logo, no YouTube 21.38.2 base, no player/feed insertion logic. Just diagnostics.

---

## Provenance

- `VERSION=1.2.0`, commit `6d3a3ca` or newer, 87 source files (`scripts/verify_release.py`)
- `132` Python + C suites (classifier 79+5000, scanner 20+5000, ad-state 32, insertion 26, mutation 100k, policy 20k/300k) — `scripts/check.sh` clean, `test_settings_native` 16:9 fixed, `macos-15` green after the `1.1.0→1.2.0` `IPA_PATH` fix
- Built on `macos-15` by `Build QuietTube dylib only` (`actions/checkout@11d59...`, `setup-python@a26af...`)

## Install (dylib only)

1. Grab `QuietTube.dylib` + `QuietTube-NOTICES.txt` + `SHA256SUMS` + `BUILD-INFO.json` from this release.
2. Inject into your own decrypted 21.38.2 with your installer (I use LiveContainer 3.8.0, not required). Follow your installer’s signing. Don’t double-inject.

Checksums and `BUILD-INFO.json` (`dylib_sha256`, `source_commit`) are attached. Compiling isn’t the same as “works on my phone.”
