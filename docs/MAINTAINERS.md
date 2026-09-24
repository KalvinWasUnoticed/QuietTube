# Publishing and maintaining the public repository

## Scope and legal limits

This tree is source-first. Its manual workflow builds only QuietTube and uploads only the library, build identity/hashes and license notices. It neither obtains YouTube nor creates/releases an IPA. The local packager has no downloader and requires a user-supplied, authorized exact base.

These measures reduce obvious redistribution exposure; **they cannot ensure that no claim or takedown will occur**. Source code, functionality, links, circumvention allegations, trademarks and service terms can raise separate issues. Disclaimers and an MIT license do not settle those questions. Obtain qualified legal advice before making legal assurances or distributing material whose rights are uncertain. See GitHub's [DMCA policy](https://docs.github.com/en/site-policy/content-removal-policies/dmca-takedown-policy).

## Replace the old tree cleanly

Back up your work. Replace the old tracked repository contents with this package at the repository root, including `.github`. Keep the repository itself and your local `.git` directory. Do not merge in obsolete source stubs or old publishing workflows.

The release guard checks current build/source files and rejects known retired files. Confirm that Actions lists **Build QuietTube library** and **Source checks**, not the old IPA publication workflow. Fork users enable Actions and manually run the library build themselves. Automatic source CI does not build/package an app.

## Clean existing GitHub content separately

Replacing HEAD does not clean prior publications or history. Before promotion:

- [ ] Review and remove old YouTube-containing IPA **release assets**, if any. Check all releases, not only the latest tag. Do not upload a replacement public IPA.
- [ ] Review old **Actions artifacts, runs/logs, tags and release descriptions** for bundled apps or hosted-base links. Remove obsolete distribution links. Removing a tracked file does not remove an artifact.
- [ ] Review **Git history**, other branches, wiki/issues/discussions and attached files for old hosted-base links, proprietary binaries or secrets. Choose with appropriate advice whether a clean-history source repository or a coordinated history rewrite is required. A normal deletion commit leaves older content accessible.
- [ ] If rewriting history, back up first, coordinate with collaborators and follow GitHub's guidance. Force pushes do not erase third-party clones, forks, caches or every external copy. Do not promise complete removal.
- [ ] Revoke exposed credentials if any; none are needed by the new workflow. Use GitHub support/removal processes where relevant.
- [ ] Retain LICENSE and required Notices; don't remove attribution as “unused files.”

No remote repository, release, artifact or Git history was modified during preparation of this package. Those actions need the owner's review and access.

## Final acceptance before announcing 1.0.0

- [ ] Source checks pass and the manifest matches the intended complete commit.
- [ ] A manual library build succeeds using the new pinned-action workflow; download its artifact and check build identity/hash.
- [ ] Locally package the authorized pinned base and test the exact final artifact. Confirm the 1.0.0 footer and unchanged preferences.
- [ ] Confirm player/feed behavior, sign-in, native PiP/background, preset preview/cancel/Apply, rapid toggles and restart status. Check light/dark and large text. Do not infer this from source hashes alone.
- [ ] Set repository About text and Issues support policy. Suggested description: “A quieter native YouTube experience for LiveContainer. Open-source customization; library-only builds.”
- [ ] Tag the reviewed commit `v1.0.0` and publish **source release notes only** if desired. GitHub's source archives are sufficient; do not attach a bundled app.
- [ ] State the exact tested environment and limits. Do not claim “DMCA-proof,” “undetectable,” “every ad blocked” or official affiliation.

## Why these files remain

| Location | Purpose |
| --- | --- |
| Sources | Active implementation and headers, all consumed by the build |
| scripts | Verification, checks, library build/provenance and offline local packaging |
| tests + fixtures | Active behavior/ABI/packaging guards and frozen runtime comparisons |
| .github | Library build, source CI and issue template |
| docs + assets | Referenced installation/settings/privacy/maintenance guides and README graphics |
| Notices + LICENSE | Attribution and license obligations |
| VERSION + release-manifest.json | Build identity and mixed-upload protection |
| README / CHANGELOG / CONTRIBUTING | User-facing entry point, release notes and maintenance rules |

Removed from the public tree: retired player stubs, old public-IPA release script/tests, superseded ABI/baseline files, development history docs, unused companion/feature-hook research, insertion disassembly dumps and RC patch instructions. Necessary active metadata/preservation checks are consolidated into two test fixtures. No hidden runtime rewrite accompanied this cleanup.
