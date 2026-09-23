# References and attribution

QuietTube 0.1 is a small custom runtime-hook implementation. Private class/selector names and integration approaches were researched using:

- **YTKACE**, MIT, copyright 2026 YTKACE contributors. Reviewed commit `97456b0d63e37b9847b3fb7e3829a10ab9310d86` at https://github.com/itzzace/ytkace . Native settings factory/section integration, pivot identifier traversal, selected feature hook points and ad-renderer markers informed this implementation. See `YTKACE-MIT.txt`.
- **YouTube-X**, MIT, copyright 2022–2026 PoomSmart. Reviewed commit `48b901532f9e12152684f3326d4250efcdea61e5` at https://github.com/PoomSmart/YouTube-X . Player-response ad-array hook points and explicit ad-renderer metadata informed this implementation. See `YouTube-X-MIT.txt`.
- **YouPiP**, MIT, copyright 2018–2020 SpicaT and 2020–2026 PoomSmart, https://github.com/PoomSmart/YouPiP . Reviewed main-branch source on 23 September 2026 for native PiP eligibility methods. Its full player/bootstrap/overlay implementation is not bundled. See `YouPiP-LICENSE.txt`.

Attribution is included conservatively for interface patterns and adapted integration ideas; this project does not claim novel discovery of those techniques. None of these projects endorses or has tested QuietTube. No upstream binary tweaks are downloaded by the workflow. These references are not runtime network dependencies.

The YTPlaybackFix project was reviewed for comparison. Its automatic retry, client rewriting and network interception code are not included. No YouMod GPL code is included.
