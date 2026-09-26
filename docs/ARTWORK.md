# Artwork

The printed-label design uses flat fills and plain type. No gradients, glow, shadows, fake app windows or YouTube logo copy. The extra space on the right of the banner is intentional.

| Color | Hex |
| --- | --- |
| Warm paper | `#F1EBDD` |
| Charcoal | `#20201E` |
| Vermilion | `#C64936` |

## Files

- [Editable banner SVG](assets/banner.svg) — 1280 × 400, used by the README.
- [Banner PNG](assets/banner.png) — same dimensions; fixed rendering for places that need a raster file.
- [Editable project mark SVG](assets/mark.svg) — 192 × 192.
- [Project mark PNG](assets/mark.png) — same dimensions.

The mark is optional repository artwork, not an in-app or IPA icon change. The build does not inject it into YouTube.

The SVGs keep text editable. Their font stack is Arial, Helvetica, Liberation Sans, then the system sans-serif. Rendering can vary with installed fonts; use the PNG for a fixed appearance. No font files are bundled.

Keep the name readable at thumbnail size. Don’t add a release version, test verdict or installer badge to the banner; those belong in the docs and go stale.

This is original, AI-assisted artwork, distributed with the project under its MIT license. It does not grant rights to YouTube’s branding. The real `settings.png` and `presets.png` screenshots are unchanged RC1 images, not part of this redraw. [Credits](../Notices/REFERENCES.md).
