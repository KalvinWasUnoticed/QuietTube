# Credits and third-party notices

QuietTube is maintained by [KalvinWasUnoticed](https://github.com/KalvinWasUnoticed). Its own source is distributed under the root MIT license. Existing third-party attribution is retained conservatively for researched interface patterns and adapted integration ideas; none of these projects endorses QuietTube.

## Technical references

- **[YTKACE](https://github.com/itzzace/ytkace)** — MIT, copyright 2026 YTKACE contributors. Reviewed commit `97456b0d63e37b9847b3fb7e3829a10ab9310d86`. Native settings integration, feature hook points, navigation traversal and renderer markers informed this implementation. See `YTKACE-MIT.txt`.
- **[YouTube-X](https://github.com/PoomSmart/YouTube-X)** — MIT, copyright 2022–2026 PoomSmart. Reviewed commit `48b901532f9e12152684f3326d4250efcdea61e5`. Explicit ad-renderer metadata and selected element families informed research. Early response-array experiments are not active player hooks in this release. See `YouTube-X-MIT.txt`.
- **[YouPiP](https://github.com/PoomSmart/YouPiP)** — MIT, copyright 2018–2020 SpicaT and 2020–2026 PoomSmart. Native PiP eligibility research informed development; its player/bootstrap/overlay implementation is not bundled. The final app uses YouTube's native PiP setting. See `YouPiP-LICENSE.txt`.
- **[Morphe patches](https://github.com/MorpheApp/morphe-patches)** — cross-platform identifier observations for chips, portrait/Shorts layouts and radio-playlist destinations were consulted. No Android patch implementation/library is bundled. Relevant Mix discussion: [PR 1835](https://github.com/MorpheApp/morphe-patches/pull/1835). These observations alone do not prove iOS renderer identity.

Player construction and scoped feed-insertion boundaries were also inspected in the exact supported native binary. Only active API metadata needed by regression checks remains under tests/fixtures; the app binary, raw payloads and disassembly dumps are not distributed here. These compatibility observations are not a claim of permission to redistribute the original app.

## Presentation references

[YTLite / YouTube Plus](https://github.com/dayanch96/YTLite), [YTKACE](https://github.com/itzzace/ytkace) and [MaxTube](https://github.com/Mark02-2012/MaxTube) informed the idea of concise feature sections, real screenshots and a separate build guide. No repository artwork or README layout was copied. The QuietTube banner is original vector artwork. Screenshots were supplied by the maintainer, cropped/resized without changing UI content, and show the preceding RC1 settings build.

Pinterest inspiration was requested, but its direct search page was access-blocked during preparation; no Pinterest images or layouts were obtained or reused.

The workflow compiles QuietTube from source; no upstream binary tweak is downloaded. The base app is supplied by the person running the workflow, not by this repository. YTPlaybackFix was reviewed for comparison; its client rewriting/retry/network implementation is not included. No YouMod GPL implementation is included. Do not infer extra features or licensing permissions from these references.

YouTube/Google and other product names belong to their respective owners. QuietTube is independent and unaffiliated. The MIT license covers the QuietTube source, not YouTube's binary, service or trademarks.
