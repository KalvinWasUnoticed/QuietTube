# QuietTube 0.5 — opt-in unmatched-template capture

**This download is source + a GitHub build workflow, not a compiled IPA. It does not yet remove “Explore more topics” or the edge-to-edge video cards.** It adds the missing diagnostic information needed to investigate those formats without guessing at new blocking rules.

## What the evidence says

Your 0.4 report recorded 10 Shorts-template matches, 3 explicit ad-logging matches and 1 promo-template match. You reported that Shorts shelves disappeared but two other layouts remained. These counters are not counts of unique ads or visible cards. They do not identify the 168 unmatched element payloads.

No exception, budget, depth-limit or empty-batch fallback counter was reported. That points to classification/traversal coverage rather than the safety fallback as the immediate next area to investigate. The portrait video's context menu and screenshots do not prove its internal renderer type.

## What changed

**Advanced → Inspect unmatched templates** (OFF by default).

With this option and Extended feed formats active, the existing feed-boundary filter extracts bounded, template-like names ending in `.eml` from element payloads it inspected but retained. It groups names that co-occurred in one payload and adds the results to **View diagnostics → UNMATCHED ELEMENT TEMPLATE CAPTURE**.

- No new filter rules or feed/playback hook points.
- No video-title, aspect-ratio, or blanket vertical-video blocking.
- Existing 0.4 filtering decisions, original-array preservation, and empty-batch guard are retained.
- Native YouTube PiP, background behavior and the tested settings sheet remain unchanged.
- Existing preferences are preserved when the same app-data container is retained; the capture option starts off.

## Capture boundaries and privacy

Capture is local, opt-in, in-memory, and never uploaded automatically. It does not request authentication fields or record full payloads, URLs, cookies or video titles deliberately. It extracts lowercase/digit/underscore/dot/hyphen tokens ending in `.eml`, rejects obvious URL/path/email contexts, and limits tokens to 96 characters.

**This is lexical extraction, not a schema-aware parser.** A user-authored string that happens to look like a template filename could pass these rules. Review the resulting text before sharing. Names may describe nested templates rather than a card's root renderer. A group is not reliably tied to the visible card directly above/below your scroll position; feeds can preload content.

Limits: 256 KiB per inspected element, 128 unmatched elements per capture, 48 unique groups, and up to eight names per group. Payloads and complete model descriptions are not retained. Clearing capture or fully restarting discards its samples. Oversized elements are already skipped by the extended filter.

If the payloads do not expose `.eml`-style names, the capture may contain no names. That is a useful limit to report, not evidence that the cards cannot be filtered.

## Build/install

1. Keep your 0.4 IPA as a rollback copy and preserve your working account data.
2. Extract `QuietTube-v0.5.zip` and upload the **contents of QuietTube-v0.5** to your existing repository root. Replace files and include the hidden `.github/workflows/build.yml`, new `Sources/QTTemplateScan.h` and `tests/test_template_scan.c`.
3. Run **Actions → Build QuietTube IPA**.
4. Download and extract artifact **QuietTube-0.5-21.38.2-IPA** to obtain `QuietTube-0.5-21.38.2.ipa`.
5. Import into LiveContainer and let it re-sign/prepare the guest as before. Do not add the standalone debugging dylib on top of the package.

The workflow uses the same hash-pinned clean YouTube 21.38.2 IPA; no Apple/Google credentials are required. Check macOS Actions minutes/billing. The changed native source has not been compiled here; a failed compile step needs troubleshooting before an IPA is available.

## One targeted capture

1. Keep your working flags and **Extended feed formats** enabled.
2. Enable **Quiet controls → Advanced → Inspect unmatched templates**.
3. Fully restart the guest process. Confirm the footer says **0.5**.
4. Open **Advanced → Clear template capture**. This clears only captured names/sample counts, not feature flags or ordinary session counters.
5. Tap Done, return to Home, refresh once, then scroll until an “Explore more topics” shelf or edge-to-edge card appears. Do not keep scrolling far beyond it.
6. Open **Advanced → View diagnostics**. Copy the new **UNMATCHED ELEMENT TEMPLATE CAPTURE** section and session counters. Identify which unwanted layout you saw during that run.

If both layouts appear close together, one capture is enough to start. If they appear in separate browsing sessions, clear capture before the second refresh and label the two outputs. Do not reproduce crashes unnecessarily.

Capture reflects newly processed payloads, not already cached visible cards. If `unmatched elements sampled` is zero, refresh/reload the feed rather than repeatedly opening a cached card. If the 128-sample cap is reached before the target appears, clear capture and refresh nearer the test instead of collecting an enormous log.

After sharing, switch capture off and fully restart. Normal filtering continues unchanged. If this diagnostic build is unstable, return to your saved 0.4 package; do not delete your working clean app or account data.

## Not implemented yet

The two requested filters (Explore more topics and edge-to-edge video cards), standard-logo restoration, and in-video ad blocking remain unresolved. No disabled or nonfunctional toggle for either new feed layout is advertised as implemented.

## Validation

Local: eight packaging unit tests, six static source-regression checks, 14 standalone C classifier assertions and ten standalone C template-extraction assertions. They do NOT test YouTube's runtime/rendering or native Objective-C integration.

0.5 native compilation and device testing: pending GitHub/device. Prior successful code and user tests are retained as historical evidence, not proof of this new revision. See `VALIDATION.json`, `Sources`, `tests`, and `Notices`.
