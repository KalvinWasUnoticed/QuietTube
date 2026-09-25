# Publishing and maintenance

## Distribution policy

The repository supplies QuietTube source, not a YouTube base app link. Users fork it and manually provide an authorized decrypted 21.38.2 direct HTTPS IPA link. The workflow downloads that input, checks the exact pinned hash, compiles/packages and releases the output **in the invoking fork**, never the upstream repository. It requires explicit rights/publication acknowledgement. Public forks create publicly downloadable releases.

This arrangement is **not a DMCA guarantee or legal clearance**. User-supplied input and fork-based publication do not establish permission to obtain, modify or distribute an app. Source functionality, circumvention allegations, trademarks, service terms and links may raise separate issues. Consult a qualified professional rather than making legal assurances. See [GitHub's DMCA policy](https://docs.github.com/en/site-policy/content-removal-policies/dmca-takedown-policy).

## Replace the tree, not isolated workflow files

Back up work. Replace the old tracked contents with this complete package at the repository root, including hidden `.github`. Preserve the repository and local `.git` directory. The manifest rejects mixed sources and known obsolete files. It is a consistency guard, not an authenticity signature.

Actions should list **Build QuietTube IPA** and **Source checks**. Source checks never download or publish apps; the IPA workflow is manual and fork/acknowledgement gated. Do not grant a personal token or store Apple credentials for it.

## Existing remote content is separate

Replacing HEAD does not remove earlier content. Review old IPA release assets, artifacts, Actions runs/logs, tags, branches, wiki/issues and historic hosted-base links. Delete material you lack rights to distribute and remove obsolete links. A deletion commit leaves history accessible. If necessary, coordinate a history rewrite or clean-history repository with appropriate advice, backups and collaborators. Force pushes cannot erase third-party clones, forks or every cache. Revoke any exposed credentials.

No GitHub repository, release, artifact or history was modified during preparation of this package. The owner must review and perform remote cleanup. Keep LICENSE and required attribution; they are not disposable residue.

## Validate before promoting

- Run the source-integrity check, Python suite, four C sanitizer suites and shell checks.
- Run the new workflow in an authorized fork with the actual pinned base and acknowledgement. A skipped job is not a successful build.
- Confirm native compilation, packaging, upload and publication in that fork. Check the direct link, release source commit and IPA SHA256. If upload/publication fails, inspect any draft release; start a new run after correcting files.
- Install that exact IPA using the installation method being evaluated, preserving data/rollback. LiveContainer is the only reported tested method; test alternatives before claiming support. Confirm the 1.0.2 footer, sign-in, player/feed behavior, native PiP/background, settings/presets, restart status, light/dark and large text. For 1.0.2, also test persistence across repeated launches and verify fresh-install defaults without overriding existing manual off values. Confirm the new Foundation test passes on the macOS runner.
- Only then announce a tested release. The automated per-run releases remain prereleases; source packaging alone is not a stable-device verdict.
- Never advertise “DMCA-proof,” “undetectable,” “all ads blocked” or official affiliation.

## Files retained

Sources are the active implementation; scripts handle verification/tests/build/download/packaging/publication; tests/fixtures protect ABI/runtime and distribution behavior; `.github` holds workflows/issues; docs/assets support the README/tutorial; LICENSE/Notices retain attribution. VERSION and the manifest identify the complete source release. Every retained category has an active purpose.

Retired stubs, development diaries, raw disassembly, obsolete baselines/tests and the old shell IPA publisher are removed. Current active metadata is consolidated in two fixtures. Do not restore built-in base-app URLs or silently loosen the exact-input checks.

## Copy and compatibility

Present QuietTube as an iOS customization, not a LiveContainer-exclusive app. Keep LiveContainer in the tested-environment table. Do not turn untested installation options into a universal compatibility claim. The beginner guide recommends Catbox only as a user-selected file host, not as a source of YouTube downloads. The package still removes app extensions and needs signing/preparation; behavior of other installers and sign-in/entitlements has not been validated.
