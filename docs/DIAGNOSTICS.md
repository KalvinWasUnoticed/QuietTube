# Capture a playback or feed problem

Recording is manual and local. It helps collect clues; it does not fix an error or decide that an unfamiliar item is an ad.

## The 3 buttons (Troubleshooting)

Open **You → Settings → General → Quiet controls → Advanced → Troubleshooting**. You will see only three rows:

| Button | What it does |
| --- | --- |
| **Enhanced logging** | One master toggle. **On** = `● Collecting` — captures during normal daily use. **Off** = `○ Off`. Shows its state in the row and in the footer. Leave it on and use YouTube normally; when you see an intrusive shelf or an ad slips through, export right away — no need to turn it on and then try to reproduce. |
| **Export logs** | Copies the last 3 sessions + current support snapshot to the share sheet (text, not a ZIP). Review before sharing. |
| **Clear logs** | Deletes the 3 local files. Does not turn the master off. |

The master is persistent: if you turn it on, it auto-resumes after relaunch until you turn it off or use *Disable all options*. A full relaunch does **not** clear the files — you can export after a restart without starting a new session, unless iOS evicted the cache or the 7-day window expired.

All other old toggles (`Record feed activity`, `Record template clues`, `Prepare a support test`, `View support report`, `Clear template capture`) are now merged into this one master. When the master is on, it also captures unmatched template clues and feed insertion details that previously required those separate switches.

## How to use it for daily spikes

1. Use the supported YouTube **21.38.2** build. QuietTube’s main `Enable QuietTube` must be on (that one still needs a restart).
2. Turn **Enhanced logging** on. The footer will show `● Enhanced logging: collecting locally (3 × 256 KiB, 7-day, no upload)`.
3. Use YouTube normally. When you see a distracting feed item or an in-player ad that wasn't blocked, **immediately** tap **Export logs** and save/share the text. You don't need to start a dedicated test session first.
4. Clear with **Clear logs** when you're done. The master stays as you set it.

If you turned it on and nothing appears in Export, check that the master still shows `● Collecting` — the app may have restarted and the toggle may have been turned off by *Disable all* or a container reset.

## What you can see

- Errors reaching the supported native playback-error handler: numeric codes, a short domain category and at most three underlying errors. No localized description or arbitrary `userInfo` dump.
- Player factory/no-op/fallback and safety-pause events when the existing player-profile hook is installed and invoked (helps when in-player blocking stops).
- Known watch-collapse/layout callbacks, feed mutations, presentation inputs, scoped insertion inputs and successful return boundaries (helps when a new intrusive shelf appears). Missing or incompatible private methods remain unmonitored.
- Sampled renderer/template names, explicit `adLoggingData` presence, payload size and the existing classifier’s mask — now captured automatically when the master is on. This can expose Playables, promo shelves or unfamiliar feed elements without needing a separate *Record template clues* switch. It does not add blocking rules.
- Foreground/background, memory-warning and termination notifications received while collecting. iOS does not promise a termination notification or a final flush.
- Hook attempts while collecting. The support snapshot adds current hook status, active/saved flags, YouTube/iOS versions and counters.

This is not an all-events recorder. It does not capture network traffic, authentication fields, passwords/cookies, explicit account/video-ID fields, a viewing-history database, remote experiment values, crash stacks or a complete play/pause/buffering timeline.

## Storage and deletion

| Limit | Detail |
| --- | --- |
| Retained files | Three JSON-lines cache files, **256 KiB each**, up to **768 KiB** of retained events. Auto-rotates: oldest file (events-2) is dropped when the newest fills. |
| Temporary space | Atomic cleanup can add one temporary file of up to 256 KiB. Exported text and working buffers use additional limited memory/storage. |
| Retention | A **seven-day record window**, checked at startup, session start/export and periodic active writes. |
| While closed or idle | Cleanup is not a scheduled background eraser. Stale records remain until the next cleanup. Clock changes affect expiry. |
| Cache loss | iOS can evict these files. App removal, data resets and new containers can also lose them. |

Disk I/O runs on a serial queue, off the UI thread. Temporarily unreadable files are kept rather than treated as empty. Export rechecks record age and allowed fields, and drops malformed or incomplete lines.

Toggling the master off stops new admission immediately; queued writes still finish. Toggling it on again starts a fresh `start` event. Clearing stops admission briefly, deletes the three files, and if the master is still on, resumes collecting with a new `start` event. Filesystem operations can fail; the report includes storage-failure counts. Clearing is not secure erasure and cannot remove reports you already shared.

## Sampling and dropped events

- At most **64 queued write tasks**. Ordinary events leave eight queue places for errors/safety pauses.
- Up to **30 data events/second** while collecting. Ordinary events stop at 24, leaving six rate positions for errors/safety pauses. Start/stop records are extra; toggling the master resets the rate window.
- A shared budget of **four discovery admissions/second** for graph walks and payload samples — shared across feed boundary walks and element inspections.
- Each walk visits at most **12 nodes**, depth **three**, with at most **three entries per array**, through a closed list of signature-checked getters.
- Payloads over **256 KiB** are not scanned. A sampled element emits at most **four template names**. Class fields retain valid **YT/ML-prefixed** identifiers; other class families and unnamed formats can be missed.

Queue/rate drops are counted. An absent event can mean the master was off, an unavailable hook, a sampling limit, an I/O failure or an abrupt exit — not that nothing happened. A nearby template does not establish the cause of an error.

Sampling still runs at the native callback and has a cost. Keep the master on only when you are actively investigating; turn it off when you don't need logs.

## What collecting does not change

Observation does not seek, retry playback, edit feed objects, suppress native exceptions or alter saved choices. Turning the master on retries the existing idempotent installers with the same launch flags (no extra restart needed). The supported-version guard still applies. Turning it off leaves installed observation wrappers in place, but the recorder stops accepting events.

## Before sharing

The files are in the app cache. Permissions are restricted, backup exclusion is requested, and iOS file protection is applied. This is not a separate encrypted vault or a promise of anonymity. No automatic upload is added.

Only allowed numeric fields and identifiers are written. But template scanning is lexical, not a privacy-proof protobuf decoder: identifier-shaped text can contain sensitive clues. Review the report. Don’t attach tokens, account details or unreviewed captures to an issue. [Data handling](PRIVACY.md).
