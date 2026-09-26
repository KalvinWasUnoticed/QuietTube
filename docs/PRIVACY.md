# Privacy and support data

QuietTube adds no analytics endpoint, activation server or automatic diagnostic upload. That says nothing about the network/data practices of YouTube, Google sign-in, your installer, GitHub or a file host.

## What reports contain

Reports can include settings flags, internal class/template names, relative event times, wall-clock timestamps and error categories/codes. The logger does not intentionally print raw payloads, explicit video-ID fields, credentials or signed-URL fields.

Template matching is not a privacy-proof parser. Names that look like identifiers can still contain sensitive clues. **Review a report before sharing it.**

Detailed activity/template capture is optional. The presets turn those older capture switches off; Prepare a support test turns its prerequisites on. Updates preserve saved choices. The manual recording session has separate Start/Stop actions.

## Where data stays

| Data | Lifetime |
| --- | --- |
| Preferences | Local app storage; ordinary restarts and updates keep them. A data reset, removal or new app/container identity can lose them. No cloud settings backup. |
| Older event rings/template capture | Memory only; reset on process restart. Clear template capture removes that capture, not every counter. |
| Manual event history | Three private cache files of 256 KiB each. Seven-day expiry is applied on cleanup, not while a closed app is unable to run. iOS can evict them. |
| Exported reports/screenshots | Wherever you save or share them. Clearing QuietTube’s files cannot remove those copies. |

Manual recording starts off each process launch. Export includes recent disk events and the current support snapshot. Clear diagnostic history stops new recording and queues file deletion after earlier writes; it does not clear the older memory-only reports. Check failure counts rather than assume a failed filesystem operation succeeded.

[Recording, expiry and sampling limits](DIAGNOSTICS.md).

## Builds and public releases

The IPA workflow downloads the URL you supply on GitHub’s runner, validates the exact input and publishes the result in your fork. It also attaches the compiled dylib. A public fork produces public release assets.

The dylib-only workflow downloads no base app and releases no YouTube IPA. It publishes the library, notices, checksums and build metadata in the original repository or a fork, with that repository’s visibility.

Both clean up temporary outputs. That does **not** delete releases, past runs, GitHub logs, workflow metadata or repository history.

The base URL is a workflow input, **not a GitHub secret**. The downloader masks its own output and avoids URL-bearing exception messages, but GitHub may retain the input. Do not put passwords or sensitive long-lived tokens in it. These workflows do not request Apple credentials or signing certificates.

## File hosts

Uploading to [Catbox](https://catbox.moe/legal.php) means sending a file to a third party. Anyone with the resulting link may be able to download it; anonymous uploads are not private storage. Upload only what you have permission to share. QuietTube neither manages nor removes those uploads.

## If you exposed something sensitive

Remove it and revoke affected credentials or tokens where applicable. Use GitHub’s removal/reporting process where needed; don’t repost the material while asking for help. Issues should not contain app binaries, account identifiers, passwords, cookies, tokens or unreviewed full captures.
