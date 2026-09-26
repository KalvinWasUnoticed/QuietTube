# Credits and notices

[KalvinWasUnoticed](https://github.com/KalvinWasUnoticed) maintains QuietTube, built with AI help. Its own source uses the root MIT license. The projects below informed research and integration work; none endorses QuietTube.

## Technical references

- **[YTKACE](https://github.com/itzzace/ytkace)** — MIT, copyright 2026 YTKACE contributors. Reviewed commit `97456b0d63e37b9847b3fb7e3829a10ab9310d86`. Its native settings integration, feature hook points, navigation traversal and renderer markers informed this implementation. License: `YTKACE-MIT.txt`.
- **[YouTube-X](https://github.com/PoomSmart/YouTube-X)** — MIT, copyright 2022–2026 PoomSmart. Reviewed commit `48b901532f9e12152684f3326d4250efcdea61e5`. Explicit ad-renderer metadata and selected element families informed research. The early response-array experiments are not active player hooks here. License: `YouTube-X-MIT.txt`.
- **[YouPiP](https://github.com/PoomSmart/YouPiP)** — MIT, copyright 2018–2020 SpicaT and 2020–2026 PoomSmart. Its native PiP eligibility work was researched; its player/bootstrap/overlay implementation is not bundled. QuietTube uses YouTube’s native PiP setting. License: `YouPiP-LICENSE.txt`.
- **[Morphe patches](https://github.com/MorpheApp/morphe-patches)** — consulted for cross-platform identifiers related to chips, portrait/Shorts layouts and radio-playlist destinations, including [Mix PR 1835](https://github.com/MorpheApp/morphe-patches/pull/1835). No Android patch implementation/library is bundled. Those observations alone do not identify an iOS renderer.

The player constructor and scoped feed-insertion boundaries were also inspected in the exact supported native binary. Tests retain the active API metadata, not the app binary, raw payloads or disassembly. Inspection does not grant redistribution rights to that app.

YTPlaybackFix was reviewed for comparison. Its client-rewriting, retry and network implementation is not included. No YouMod GPL implementation is included. A project appearing in this list does not mean its features or licensing permissions transfer here.

## Presentation

[YTLite / YouTube Plus](https://github.com/dayanch96/YTLite), [YTKACE](https://github.com/itzzace/ytkace) and [MaxTube](https://github.com/Mark02-2012/MaxTube) informed the use of short feature descriptions, real screenshots and a separate build guide. Their artwork and README layouts were not copied.

The QuietTube banner and mark are original, AI-assisted vector artwork. [Artwork files and palette](../docs/ARTWORK.md). The maintainer supplied the screenshots; they are cropped/resized views of the earlier RC1 settings build, without changed UI content. No Pinterest artwork or layouts were obtained or reused.

The workflows compile QuietTube from source; they do not download an upstream tweak binary. IPA mode uses the base app supplied by the caller. Dylib-only mode takes no base app.

QuietTube is independent and unaffiliated with YouTube or Google. Product names and trademarks belong to their owners. The MIT license covers QuietTube’s source, not YouTube’s binary, service or trademarks. Keep the accompanying license files intact.
