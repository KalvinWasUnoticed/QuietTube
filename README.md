# QuietTube 0.4 — opt-in extended feed formats

**Source + GitHub build workflow, not a compiled IPA.** Same inspected YouTube 21.38.2 base, LiveContainer normal launch. Preserve your 0.3 IPA as the working fallback. Objective-C compilation and 0.4 device behavior have not been tested here.

## Why this revision exists

Your 0.3 diagnostics showed `shorts = on`, 15 presentation-boundary calls and one filtered node, while a Shorts shelf remained visible. No exception or empty-batch fallback counter was reported. The single filtered-node counter does not identify its category, nor is it a count of unique ads. This is evidence of incomplete coverage; it does not identify the exact renderer of the missed card.

The full-height portrait video in your second screenshot is not automatically classified as a Short. We do not filter videos by their aspect ratio, title or subject.

## Changes

New **Distractions → Extended feed formats** switch, **OFF by default**. When off, the original filtering decisions, traversal depth and renderer paths remain in place, with additional reason counters only.

When on:

- Traverses four additional named renderer-wrapper paths and permits deeper traversal.
- Reads bounded `elementData` payloads of YTI element-renderer objects encountered at the existing presentation boundary.
- Matches a small list of specific template tokens for Shorts and ads, rather than generic words like “shorts” or “ad.” The existing Feed ads and Shorts switches still determine which categories are removed.
- Adds optional **Hide Playables shelves** and **Hide featured / promo cards**, both OFF by default and both requiring Extended feed formats.
- Records category counters, visited/inspected/unmatched element counts, depth limits and node-budget exhaustion. No payload contents, video titles, URLs, account tokens or watch history are added to diagnostics.

## Limits and risks

This is token-based classification of element bytes, **not a complete semantic decoder**. A template token can occur within nested metadata; false positives and missed cards remain possible. This is why the new behavior is opt-in. Matching is limited to 256 KiB per element payload and 1,200 visited model nodes per batch. Unrecognized or oversized elements are retained.

The existing guard against making a nonempty top-level batch empty remains. If a batch consists entirely of recognized unwanted content, the original batch may be retained rather than risk another empty-array assumption.

The reported missing shelf may instead be using a presentation path that never calls the currently hooked method. These counters help determine that; this build does not indiscriminately hook every collection controller.

**Not implemented in this revision:** restoring the ordinary event-free YouTube logo; hiding “Explore more topics”; removing the Shorts navigation tab; hiding every survey; comprehensive full-height-card filtering; in-video ad blocking. Do not interpret these as supported because other filters are enabled. Player-ad blocking stays paused, and native YouTube PiP stays untouched.

The optional promo rule recognizes selected template families such as `statement_banner` and `brand_promo`; it is not proven to match the exact “Sketching for the screen” card. It does not replace the decorated header logo.

## Build

1. Extract `QuietTube-v0.4.zip`.
2. Upload the contents of `QuietTube-v0.4` to your existing repository root, replacing files. Include `.github/workflows/build.yml` and the new `Sources/QTFeedRules.h` and `tests/test_feed_rules.c` files.
3. Run **Actions → Build QuietTube IPA**.
4. Download artifact **QuietTube-0.4-21.38.2-IPA** and extract `QuietTube-0.4-21.38.2.ipa`.
5. Import into LiveContainer and fully restart the guest process. Preserve working app data/your clean fallback. LiveContainer must re-sign/prepare the modified app as before.

The workflow still downloads the same hash-pinned clean base. No credentials are needed. Do not install its standalone debugging dylib on top of the packaged IPA. Check your macOS Actions allowance/billing.

Existing preferences persist when the same 0.3 data container is retained. The new flags default to off. Native PiP and the tested 0.3 navigation sheet are unchanged.

## One test first

1. Keep your currently working Feed ads, Shorts and Background audio settings.
2. Enable **Extended feed formats** only. Leave the two new Playables/promo switches off initially.
3. Fully restart. A feed refresh alone does not apply flags.
4. Scroll Home through several loaded batches, refresh, and check search/subscriptions and normal playback.
5. Report whether the previously visible Shorts shelf disappears, any incorrect removal of normal content, any flickering/crash, and the complete diagnostic counters.

Then, only if stable, test Playables and promotional cards separately, restarting between changes. No Playables appearing in one session is not proof the filter worked; those shelves may not have been served.

If unstable, turn Extended feed formats off and fully restart. That removes the new classifications and deeper traversal. If settings are unreachable, use the preserved 0.3 or clean app; don't delete working account data to troubleshoot.

### Useful counters

- `match explicit Shorts field` / `match Shorts element tokens`: different recognition paths.
- `element renderer visited`, `element payload inspected`, `element retained — no active rule matched`: distinguishes traversal from classification coverage.
- `traversal depth limit`, `traversal node budget exhausted`, `oversize element payload skipped`: intentional bounds.
- `presentation batch changed`: a different array was produced; it may still be reverted by the empty-batch guard.
- `empty presentation batch prevented — kept original`: guard fired; matched content may remain visible.
- `presentation filter exception — kept original`: filter aborted without intentionally editing the original model.

These counts are session events, not unique cards. Nothing uploads automatically. Share diagnostic text manually.

## Tests and attribution

Local checks: eight packaging unit tests, five source-regression checks, and 14 assertions against the compiled standalone C token classifier. None tests live YouTube rendering, native Objective-C integration or server behavior. See `VALIDATION.json`.

Template families were researched from YTKACE's ContentVisibilityHooks and YouTube-X; existing MIT notices are retained and additional references are recorded in `Notices/REFERENCES.md`. Only checked-in source is compiled; no floating upstream tweak is fetched into the build. The source archive does not include YouTube's proprietary binary.
