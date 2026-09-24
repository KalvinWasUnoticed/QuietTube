# 0.13.4 update

Device trace: didCollapse followed 403 ms later by applyMutationOperation → handleInsertItemSectionContent → one YTIElementRenderer insert notification. All flags ON; five player substitutions; zero companion callbacks; sponsored card persists. Native event correlation is observed, but exact payload/ad identity is not yet established.

Corrected trace vq/vqq compact registrations to vQ/vQQ to match the existing normalizer, without changing signed native wrapper ABI. Added completion-anchor fallback and bounded element detail at the observed insertion notification. No new suppression. Accepted player suffix and cleanup remain hash-protected. See README/VALIDATION.json for current checks and limits. Older sections below are historical.

---

# 0.13.3 update

Added one-button prerequisite saving and nine binary-verified pass-through minimize/mutation observers. See BASE-MINIMIZE-ABI.json and README.md. Player suffix hash and accepted cleanup checks remain unchanged. No new ad suppression. 0.13.2 device feedback: five no-op supplies, zero companion callbacks, sponsored card persists. The prior sections below are historical, not a fresh device result.

---

# 0.13.2 audit

Evidence: 0.13.1 actually supplied five native no-op objects and user reported no player ads/stable playback. Last user sentence confirms post-minimize card remains despite the earlier checkbox-style “no”. Zero feature-getter reads means previous feed hook not demonstrated active.

Change: replace only the unused feed-feature hook with one companion observer callback. Pinned IPA re-downloaded/hash-verified; method metadata and selected ARM64 control flow inspected. Native nil-companion path clears entries and pushes staged changes. Active hook forwards nil update/logging arguments to that original callback exactly once. Disabled/stopped path forwards original arguments exactly once. Native exceptions are not caught; only post-call currentAd diagnostic reads are caught. No general collection/view manipulation. Companion payload read uses the existing signature-checked object getter; a failed/unavailable read may undercount observed payloads but does not log raw data.

Scope risk: native companion section can include companion recommendations as well as an ad. It may affect multiple surfaces sharing this observer. We cannot identify the exact screenshot card from callback metadata alone. Post-clear currentAd nil is observer state, not proof of screenshot removal. No hook is added to the engagement-companion observer because its nil-update path does not clear its on-play shelf.

Player substitution block is byte-identical to user-tested 0.13.1, enforced by PLAYER-PATH-BASELINE.json. Safety latch, native error forwarding, default-off profile for new installs, existing cleanup/appearance/background/PiP/navigation, feed classifier/scanner and release gates retained. Existing saved profile ON enables the new companion path after restart. C status text changed to ASCII to avoid %s encoding-dependent garbling; native NSString messages otherwise unchanged.

54 Python tests pass clean and after overlay upgrade:8 packaging,6 mock release,40 static/source/ABI/scope. New callback signature check, original-call branch check, no-global-clear check, C-string ASCII check and player-block hash. C sanitizer suites pass:79+5000 classifier,20+5000 scanner,32 status combinations+inactive regression. Shell syntax/YAML/ZIP checked. No native compile/device execution or real release upload here. Do not turn the user's limited successful player session into a universal stability or invisible-blocking claim.
