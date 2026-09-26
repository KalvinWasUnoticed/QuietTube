# 1.2.0 Enhanced Logger — Device Test Cases

Use this checklist on-device (iPhone 14 / iOS 26.5 / LiveContainer 3.8.0 tested; other envs may differ). All capture is **local, 3 × 256 KiB, 7-day, no upload** — review before sharing.

## The new UI (you should see this, not the old 10 toggles)

**You → Settings → General → Quiet controls → Advanced → Troubleshooting** should show **only 3 rows**:

1. **Enhanced logging** — single master switch. ON = `● Enhanced logging — Collecting` (also in footer: `● Enhanced logging: collecting locally (3 × 256 KiB, 7-day, no upload)`). OFF = `○ Enhanced logging — Off`.
2. **Export logs** — shares last 3 sessions + current support snapshot as text via share sheet. Use immediately when you see something odd.
3. **Clear logs** — deletes the 3 files (`events-0..2.jsonl`, 768 KiB total + 1 temp file during atomic cleanup). Master stays as-set.

Old rows merged away: `Record feed activity`, `Record template clues`, `Start/Stop diagnostic session`, `Clear diagnostic history`, `Prepare a support test`, `View support report`, `View full diagnostics`, `Clear template capture` — all now covered by the master.

If you still see the 10-row screen from your screenshots (6:44), you are on 1.1.0 — install `QuietTube-1.2.0-21.38.2.ipa`.

---

## Pre-flight

- YouTube **21.38.2**, QuietTube **Enable QuietTube = ON** (needs full close/reopen after that toggle).
- Footer on `Quiet controls` should read `1.2.0` after relaunch.

## Test Cases — Run with master ON, export as soon as you see odd behavior

### TC-1 — Master persists & shows collecting
1. Turn **Enhanced logging OFF** → footer shows `○ Enhanced logging off…` Row shows `○ Off`.
2. Turn **ON** → row shows `● Collecting`, footer shows `● Enhanced logging: collecting…` Tap switch and also tap the row — both toggle.
3. **Fully close and reopen YouTube** (swipe away) → reopen `Troubleshooting` → still `● Collecting` (auto-resumes). No need to toggle again.
4. Export → report top should contain `capture enabled this launch: yes (enhanced master on)` and a `start` event.

*Pass if:* state survives relaunch until you turn off or use *Disable all options*.

### TC-2 — Daily-use capture (the main fix)
1. With master **ON**, use YouTube normally for 15-30 min: scroll Home/Shorts/Subs, open a video, background the app, foreground, trigger a memory warning if possible (open many apps).
2. **Do NOT use** a dedicated test screen. When you see an intrusive shelf (e.g., `Promo Shelf`, `Playables`, large portrait card) or a **player ad slips through**, **immediately** tap **Export logs** (no need to disable/enable and reproduce).
3. In export, search for:
   - `feedBoundary`, `mutation`, `element`, `hook`, `lifecycle` (background/foreground/memory), `playbackError` / `player factory` / `no-op` / `safetyPause` / `fallback`
   - `template` / `ytElements` / `adLoggingData` presence, payload size, classifier mask (sampled, at most 12 nodes, depth 3, 3 entries/array, 4 template names, 256 KiB payload limit)
   - Counters: `events-0..2` rotation, `queueDrops`/`rateDrops` if limits hit (64 queue, 30/sec, 6 reserved for errors)

*Pass if:* export contains feedBoundary/mutation clues from normal scrolling, and any player fallback/safetyPause if you saw an ad slip.

### TC-3 — Export / Clear / Rotation
1. Master ON → generate some activity → Export → keep the text.
2. Tap **Clear logs** → notice `Logs cleared — master stays as set` → Export again → should be near-empty (only new `start`).
3. Keep master ON, repeat heavy scrolling until > 256 KiB would have accumulated → Export → verify oldest file dropped (events-2 evicted), total retained ≤ 768 KiB + temp file.
4. Wait 7 days or change device clock + relaunch → next Export/start should have expired old files cleaned.

*Pass if:* Clear deletes but master stays `● Collecting`; rotation keeps 3 files; 7-day expiry works.

### TC-4 — Stop vs. Off
1. Turn master **OFF** (toggle) → footer `○ Off` → use app 5 min → Export → **no new** feed/player clues should appear after the `stop` event.
2. Turn ON again → new `start` event, queue/rate windows reset, capture resumes.

*Pass if:* OFF truly stops admission (queued writes finish, but no new events).

### TC-5 — Negative / Privacy
1. Export → verify **no** `localizedDescription`, `absoluteString`, `HTTPBody`, `NSLog`, `[response description]`, passwords/cookies, videoId/playlistId, `userInfo` dump, network traffic, crash stacks.
2. Verify file location is app cache (`Library/Caches`), `NSURLIsExcludedFromBackupKey`, `NSFileProtectionCompleteUntilFirstUserAuthentication`.

---

## What to send me

After any failure (intrusive feed card, player ad not blocked):
1. Master **ON** the whole time → **Export logs immediately** → Save the share-sheet text (review it first — it can contain `YT/ML`-prefixed class/template ids).
2. Tell me:
   - YouTube version (must be 21.38.2), iOS/container, QuietTube `1.2.0`, master showed `● Collecting`?
   - What you saw (screenshot if possible, plus time stamp)
   - The exported text (or first 500 lines)
3. Then **Clear logs** if you want to start fresh.

## Automated tests I own (you don't need to run)

- `132 tests` pass locally (`python -m pytest` / `scripts/check.sh`): C-family delimiter balance, `verify_release` (85-file 1.2.0 manifest), bounded queue/rate (64/30, 8/6 reserved for errors), 3×256 KiB file rotation, 4-discovery/sec, 12-node/depth-3 walks, 7-day expiry, main-thread export (`CGRectMake`/`CoreGraphics` link), persistent master via `setObject:@(YES)` (not `setBool:`), 3-button UI (`toggleEnhancedLogging`/`exportDiagnostics`/`clearDiagnostics`, `diagnosticBusy`, `QTEnhancedStart/Stop`), `QTDPFileLimit=262144/QTDPFiles=3`.

Stability: disk I/O on serial queue (`DISPATCH_QUEUE_SERIAL`, no `dispatch_sync`), rate/queue drops counted (`QTDPAdmission`), malformed lines dropped on export, stale files cleaned at startup/export/periodic writes.

Keep master on only while investigating — sampling runs at native callbacks and has cost.
