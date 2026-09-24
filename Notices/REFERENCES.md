# References and attribution

QuietTube 0.1 is a small custom runtime-hook implementation. Private class/selector names and integration approaches were researched using:

- **YTKACE**, MIT, copyright 2026 YTKACE contributors. Reviewed commit `97456b0d63e37b9847b3fb7e3829a10ab9310d86` at https://github.com/itzzace/ytkace . Native settings factory/section integration, pivot identifier traversal, selected feature hook points and ad-renderer markers informed this implementation. See `YTKACE-MIT.txt`.
- **YouTube-X**, MIT, copyright 2022–2026 PoomSmart. Reviewed commit `48b901532f9e12152684f3326d4250efcdea61e5` at https://github.com/PoomSmart/YouTube-X . Player-response ad-array hook points and explicit ad-renderer metadata informed this implementation. See `YouTube-X-MIT.txt`.
- **YouPiP**, MIT, copyright 2018–2020 SpicaT and 2020–2026 PoomSmart, https://github.com/PoomSmart/YouPiP . Reviewed main-branch source on 23 September 2026 for native PiP eligibility methods. Its full player/bootstrap/overlay implementation is not bundled. See `YouPiP-LICENSE.txt`.

Attribution is included conservatively for interface patterns and adapted integration ideas; this project does not claim novel discovery of those techniques. None of these projects endorses or has tested QuietTube. No upstream binary tweaks are downloaded by the workflow. These references are not runtime network dependencies.

The YTPlaybackFix project was reviewed for comparison. Its automatic retry, client rewriting and network interception code are not included. No YouMod GPL code is included.

0.4 also consulted YTKACE `Tweak/Features/Interface/ContentVisibilityHooks.mm` for Shorts/Playables renderer and element-template families, and YouTube-X `Tweak.x` for selected ad/promo element families. QuietTube's bounded C token matcher and opt-in integration are custom code. The references do not establish compatibility with any particular server-provided layout. Broad whole-model description matching and arbitrary whole-response serialization are not included.

0.6 research observations (no Morphe implementation code copied into this project):
- `chips_shelf` is identified as an Explore Topics shelf component in Morphe's Android `LayoutComponentsFilter.java`.
- `inline_shorts`, video-lockup/card names, and portrait-thumbnail filename families are documented in its `ShortsFilter.java`.
- Source links: https://github.com/MorpheApp/morphe-patches/blob/main/extensions/youtube/src/main/java/app/morphe/extension/youtube/patches/components/LayoutComponentsFilter.java and https://github.com/MorpheApp/morphe-patches/blob/main/extensions/youtube/src/main/java/app/morphe/extension/youtube/patches/components/ShortsFilter.java . These are cross-platform identifier observations, not verification for iOS. The native matcher remains the custom bounded C implementation in this project; no Android patch/library is bundled.

Logo class ownership and method encodings were subsequently parsed from the hash-verified supplied YouTube executable (BASE-LOGO-ABI.json). Static metadata does not establish runtime invocation or successful UI behavior; the implementation still uses runtime checks and records skipped hooks. The fallback wordmark drawing is local UIKit text rendering.

## 0.7 display-ad candidate identifiers

Retained research snapshot of https://github.com/dayanch96/YTLite (`ytlite.x`, ad-name array near line 41) includes text_image_button_layout, square_image_layout, carousel_footered_layout, product_carousel, carousel_headered_layout and landscape_image_wide_button_layout. Only observed identifier strings inform the independently implemented classifier; no implementation code was copied for this addition. Snapshot commit was not recorded, so these are reference observations, not claims about the current upstream or proof of the supplied screenshot's renderer.
