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

## 0.8 Mix and inline Shorts candidates

Retained `content.mm` research from https://github.com/itzzace/ytkace (reviewed commit 97456b0d63e37b9847b3fb7e3829a10ab9310d86): hasAutomixPreviewVideoRenderer, hasAutomixPlaylistVideoRenderer, hasRadioRenderer, hasPivotRadioRenderer and Mix identifier strings radioautomixplaylistid, radioplaylistmixplaylistid, radio_playlist_mix. Only selected names inform the independent signature-checked implementation. Broader feed_nudge and title matching not adopted. Existing MIT notice retained.

Inline overlay / Shorts-icon combination comes directly from the user's 0.7 capture group 11, not an upstream geometry detector. No claim that the captured group has been uniquely mapped to the screenshot.

## 0.9 RD playlist destination evidence

[1](https://github.com/MorpheApp/morphe-patches/pull/1835) describes changing Android Mix detection to ?list=RD and &list=RD instead of an unstable Mix8 marker. Used as a behavioral/reference observation only; no upstream implementation code copied. QuietTube's bounded C query scanner and native signature-checked navigation-endpoint check are independently implemented. Not proof of the user's iOS screenshot payload.

## 0.9.1 Watch it again candidate

English label comes from the user's supplied IMG_2400 screenshot; horizontal_shelf.eml-fe appears in the 0.9 unmatched capture. The capture is not uniquely mapped to the screenshot and does not prove the title's encoding. Native shelf-title checks and the bounded exact string-field candidate scanner are independently implemented; no external code added for this feature.
