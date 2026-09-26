# Capture a playback or feed problem

Recording is manual. It helps collect clues; it does not fix an error or decide that an unfamiliar item is an ad.

## Record a short session

1. Use the supported YouTube **21.38.2** build. QuietTube’s master switch must already be active; changing that switch still requires a restart.
2. Open **You → Settings → General → Quiet controls → Advanced → Troubleshooting**.
3. Tap **Start diagnostic session**, go back to the video/feed and reproduce the problem. Starting this session needs no restart and does not change saved blocking preferences.
4. Tap **Stop diagnostic session**. New recording stops immediately. Records already in the write queue finish writing.
5. Tap **Export diagnostic history**. The share sheet receives report text, including the current support snapshot—not a ZIP of the internal files. Review it before copying, saving or posting it.
6. Use **Clear diagnostic history** when finished. Check an export for storage failures if deletion is in doubt.

A full relaunch stops recording. You can export the previous files without starting again, unless they expired, were cleared or iOS removed the cache.

## The controls are separate

| Control | What it affects |
| --- | --- |
| Start / Stop diagnostic session | Temporary recording state. Off on every process launch. Does not change ordinary preferences. |
| Export diagnostic history | Recent disk events plus the current support snapshot. If you used the older capture tools, their current in-memory data can appear in that snapshot. |
| Clear diagnostic history | Stops the manual session and queues deletion of its event files after earlier writes. Does not clear older in-memory reports or exported copies. |
| Record feed activity / Record template clues | Older capture tools with saved switches and their original restart rules. Starting a manual session does not turn these on. |
| Prepare a support test | Saves the existing diagnostic prerequisites for the next launch. It is an explicit settings change. |
| Clear template capture | Clears the older template capture, not all counters or disk history. |

## What you can see

- Errors reaching the supported native playback-error handler: numeric codes, a short domain category and at most three underlying errors. No localized description or arbitrary `userInfo` dump.
- Player factory/no-op/fallback and safety-pause events when the existing player-profile hook is installed and invoked.
- Known watch-collapse/layout callbacks, feed mutations, presentation inputs, scoped insertion inputs and successful return boundaries. Missing or incompatible private methods remain unmonitored.
- Sampled renderer/template names, explicit `adLoggingData` presence, payload size and the existing classifier’s mask. This can expose Playables or unfamiliar feed elements. It does not add blocking rules.
- Foreground/background, memory-warning and termination notifications received during recording. iOS does not promise a termination notification or a final flush.
- Hook attempts during recording. The support snapshot adds current hook status, active/saved flags, YouTube/iOS versions and counters.

This is not an all-events recorder. It does not capture network traffic, authentication fields, passwords/cookies, explicit account/video-ID fields, a viewing-history database, remote experiment values, crash stacks or a complete play/pause/buffering timeline. It is not a server-config diff tool.

## Storage and deletion

| Limit | Detail |
| --- | --- |
| Retained files | Three JSON-lines cache files, **256 KiB each**, up to **768 KiB** of retained events. |
| Temporary space | Atomic cleanup can add one temporary file of up to 256 KiB. Exported text and working buffers use additional limited memory/storage. |
| Retention | A **seven-day record window**, checked at startup, session start/export and periodic active writes. |
| While closed or idle | Cleanup is not a scheduled background eraser. Stale records remain until the next cleanup. Clock changes affect expiry. |
| Cache loss | iOS can evict these files. App removal, data resets and new containers can also lose them. |

Disk I/O runs on a serial queue, off the UI thread. Temporarily unreadable files are kept rather than treated as empty. Export rechecks record age and allowed fields, and drops malformed or incomplete lines.

Clear stops new recording before deletion is queued, so earlier writes finish before their files are removed. A later explicit Start begins another session. Filesystem operations can fail; the report includes storage-failure counts. Clearing is not secure erasure and cannot remove reports you already shared.

## Sampling and dropped events

- At most **64 queued write tasks**. Ordinary events leave eight queue places for errors/safety pauses.
- Up to **30 data events/second** during a continuous session. Ordinary events stop at 24, leaving six rate positions for errors/safety pauses. Start/stop records are extra; a new manual session resets the rate window.
- A shared budget of **four discovery admissions/second per session** for graph walks and payload samples.
- Each walk visits at most **12 nodes**, depth **three**, with at most **three entries per array**, through a closed list of signature-checked getters.
- Payloads over **256 KiB** are not scanned. A sampled element emits at most **four template names**. Class fields retain valid **YT/ML-prefixed** identifiers; other class families and unnamed formats can be missed.

Queue/rate drops are counted. An absent event can mean an unavailable hook, a sampling limit, an I/O failure or an abrupt exit—not that nothing happened. A nearby template does not establish the cause of an error.

Sampling still runs at the native callback and has a cost. Device frame/battery impact has not been measured here. Keep sessions short.

## What recording does not change

Observation does not seek, retry playback, edit feed objects, suppress native exceptions or alter saved choices. Start retries the existing idempotent installers with the same launch flags. The supported-version guard still applies. Stopping recording leaves installed observation wrappers in place, but the manual recorder stops accepting events.

## Before sharing

The files are in the app cache. Permissions are restricted, backup exclusion is requested, and iOS file protection is applied. This is not a separate encrypted vault or a promise of anonymity. No automatic upload is added.

Only allowed numeric fields and identifiers are written. But template scanning is lexical, not a privacy-proof protobuf decoder: identifier-shaped text can contain sensitive clues. Review the report. Don’t attach tokens, account details or unreviewed captures to an issue. [Data handling](PRIVACY.md).
