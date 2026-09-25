# Manual diagnostic sessions (1.1.0)

## Capture a problem

1. Use the supported YouTube **21.38.2** build. QuietTube's master switch must already be active; enabling it requires a full restart as before.
2. Open **You → Settings → General → Quiet controls → Advanced → Troubleshooting**.
3. Tap **Start diagnostic session**, then return to the video/feed and reproduce the issue briefly. No restart is needed for starting this session. Ordinary blocking/preferences are not changed.
4. Return and tap **Stop diagnostic session**. Already-admitted writes drain; new recording stops immediately.
5. Tap **Export diagnostic history**. This opens the system share sheet with report **text**, including the current support snapshot. Copy/save/share through a destination you trust. Review the identifiers and timestamps before posting an issue.
6. Tap **Clear diagnostic history** when finished. It stops recording and queues deletion after preceding writes. The notice asks you to check an export for storage failures, because filesystem deletion can fail. This is not secure erasure and cannot delete copies you shared elsewhere.

Sessions always start **off after a process relaunch**. This is temporary diagnostic state, not a saved setting that turns itself off. Existing saved ON/OFF choices remain unchanged. Files normally survive reopening; you can export the previous session without starting another one. iOS may evict cache files, and uninstall/data reset/new containers can remove them.

The old **Record feed activity**, **Record template clues**, **Prepare a support test** and report pages are retained. They are separate legacy tools with their existing saved preferences. The new session does not automatically enable those switches. Export includes their current in-memory snapshot if you separately used them. Clearing the new disk history does **not** clear those old reports; the existing Clear template capture action is separate.

## What it observes

- Playback errors reaching the existing supported native error handler: numeric codes and a short domain-category enum, with at most three underlying errors. No localized descriptions or arbitrary userInfo dump.
- Player factory/no-op/fallback and safety-pause events **when the existing player profile is installed and invoked**. It is not an independent monitor of every player implementation.
- Existing watch-collapse/layout callbacks, feed mutation operations, initial presentation inputs, scoped insertion inputs and successful return boundaries, where the known ABI-checked hooks are available.
- Sampled internal renderer/class and template-name clues, explicit adLoggingData presence, payload byte size and existing classification mask. A Playables renderer or a new template may become visible here. Unknown/unmatched material is observed without becoming a new blocking rule.
- Foreground/background, memory-warning and termination notifications received while recording. iOS does not guarantee a termination notification or a final disk flush.
- Hook attempts made during recording. The current support snapshot supplies hook status, active/saved flags, YouTube/iOS versions and existing counters.

**Not captured:** every app event, network packets/responses, authentication fields, cookies/passwords, explicit video/account-ID fields, a viewing-history database, decoded remote experiments/config values, crash stacks, or a complete play/pause/buffering timeline. Renderer/template clues can reveal a new surface, but this is not a server-configuration diff tool. It cannot guarantee every new Playables/ad format is discovered.

## Limits and meaning

- Three recognized JSON-lines cache files, **256 KiB each**: at most **768 KiB of retained event files**. Atomic cleanup may temporarily create one additional file of up to 256 KiB; exported text and in-memory buffers are additional bounded working data.
- A **7-day record window**, enforced during startup, start/export and periodic active writes. An app that is closed or idle cannot erase files on a wall-clock schedule; stale records are removed on the next cleanup. Clock changes can affect expiry.
- At most **64 queued write tasks**; ordinary events reserve eight queue positions and six rate positions for errors/safety pauses. Up to **30 data events per second within a continuous session** (ordinary events capped at 24). Start/stop metadata is additional; restarting a manual session resets its rate window. Overload drops are counted, not silently described as complete capture.
- Shared budget of **four discovery admissions/second per session** for graph walks/payload samples. Each graph walk visits at most 12 nodes, depth three, three entries per array, and only a closed list of existing signature-checked getters. Payloads over 256 KiB are not scanned; at most four template names are emitted per sampled element. Class-name fields retain only valid YT/ML-prefixed identifiers; other class families and unnamed/new template formats may be missed.
- Observation does not seek, retry playback, modify feed objects, suppress native exceptions, change saved preferences or create new blocking rules. Starting a session retries the existing idempotent feature installers with the same launch flags; unavailable private methods remain unavailable.
- File I/O is serialized off the UI thread. Sampling itself happens at the native callback and has some overhead; iPhone performance remains to be measured.
- Storage failures, rate/queue drops, unavailable hooks, sampling and abruptly ending the process can all leave missing evidence. **An absent event is not proof that it did not happen.** A nearby template is not proof it caused an error or is an ad.

## Privacy

Logs are local to the app cache, with restrictive permissions, backup exclusion requested and iOS file protection applied to event files. This is not separate encrypted storage or an anonymity guarantee. There is no automatic upload.

Only an allowlisted numeric/identifier schema is written. Export revalidates cached records; unknown fields and malformed/expired lines are discarded. The template scanner is lexical, not a privacy-proof protobuf decoder: identifier-shaped text may contain opaque or sensitive clues. **Review before sharing.** Do not post tokens, account details or unreviewed captures. Use a short reproduction rather than leaving recording on all day.
