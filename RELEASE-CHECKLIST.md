# Public release gates

Status: preparation only. No repository, release or binary has been uploaded here.

## Ready in this candidate
- Clear settings/preset preview and privacy/support copy.
- Existing settings/defaults retained, no forced reset or activation.
- Runtime preservation tests, pure-C checks and mock release-link tests.
- Read-only source CI: no base download, signing, packaging or publication.
- Existing IPA workflow retains an explicit public-publication approval gate, direct IPA Summary link and prerelease label.
- MIT source license and prior third-party notices retained; unofficial branding disclaimer.

## Blocking general availability
- [ ] Successful Apple SDK compile on macOS; no source test substitutes for this.
- [ ] Device UI acceptance: light/dark, Dynamic Type, back/Done, fast toggles, preset preview/Apply, persistent restart status, long descriptions.
- [ ] Upgrade 0.13.5 with no preference changes: playback, feed/minimize blocking, Google sign-in, native PiP/background and accepted cleanup remain functional.
- [ ] Preset opt-in test, with detailed logging off: feed/player protection still functional.
- [ ] Restart and safety-stop behavior, reported without implying auto-repair.
- [ ] Confirm owner/repository name, maintainer contact, support policy and wider compatibility evidence. No invented official website or affiliation.
- [ ] Review provenance/third-party license attribution; confirm all required notices and authorship. Retaining notices is not a completed legal review.
- [ ] Establish lawful authority before distributing YouTube-containing IPAs. QuietTube's MIT license does not supply this. Prefer source-only publishing; explicit workflow approval is not legal clearance.
- [ ] Review GitHub/platform rules, base-host reliability, trademark presentation and whether distribution should instead require a user-provided authorized base.
- [ ] Once authorized and tested: publish a tagged release candidate first, record source commit and built artifact SHA256, installation/rollback notes, known limitations. Never mark stable merely because CI passed.

Suggested public source description: “Unofficial native YouTube customization for a pinned app version in LiveContainer. Source available; limited device validation.” Avoid “undetectable,” “all ads blocked” or “official YouTube.”

Optional later hardening, not silently implemented: maintainer-approved dependency commit pinning, user-supplied base build inputs, wider device matrix, private security-reporting channel. No new player hooks are needed for the settings release.
