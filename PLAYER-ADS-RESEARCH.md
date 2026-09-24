# 0.13.4 update

Device trace: didCollapse followed 403 ms later by applyMutationOperation → handleInsertItemSectionContent → one YTIElementRenderer insert notification. All flags ON; five player substitutions; zero companion callbacks; sponsored card persists. Native event correlation is observed, but exact payload/ad identity is not yet established.

Corrected trace vq/vqq compact registrations to vQ/vQQ to match the existing normalizer, without changing signed native wrapper ABI. Added completion-anchor fallback and bounded element detail at the observed insertion notification. No new suppression. Accepted player suffix and cleanup remain hash-protected. See README/VALIDATION.json for current checks and limits. Older sections below are historical.

---

# 0.13.3 update

Added one-button prerequisite saving and nine binary-verified pass-through minimize/mutation observers. See BASE-MINIMIZE-ABI.json and README.md. Player suffix hash and accepted cleanup checks remain unchanged. No new ad suppression. 0.13.2 device feedback: five no-op supplies, zero companion callbacks, sponsored card persists. The prior sections below are historical, not a fresh device result.

---

# 0.13.2 current status

User 0.13.1 report: five native no-op objects supplied, no player ads and stable playback in that test. Player factory workaround is frozen and hash-checked in this revision. Post-minimize card remains; prior feed getter never ran. Only the feed side changes to a binary-verified native companion empty-update path. Current report distinguishes callback activity from observer-state clearing; runtime association with the card unverified. See README and BINARY-RESEARCH.

## Historical notes below

# Current finding for 0.13.1

Latest supplied 0.13 logs show zero workaround activity because both subordinate settings were saved OFF. Missing ads during one stable run cannot be attributed to player blocking; cause not identifiable from logs. 0.13.1 removes those controls, cleans retired hooks and reports installation/invocation separately. The constructor/feed-feature hypotheses are unchanged, awaiting an actually active test. Read README for the upgrade activation change and safety limits.

## Historical notes below

# 0.13 current status

0.12 did not activate no-op behavior: missing response/config on three factory calls; delayed install retries caused misleading not-installed logs. Insertion candidate saw zero calls. Both paths removed. 0.13 uses native no-op designated initializer with verified factory scope/delegate and disables the native watch-while-feed-mutation feature, combined into one opt-in profile with independent diagnostic counters, bounded trace, underlying numeric errors and a safety latch. This remains unverified on device. Read README, BINARY-RESEARCH and AUDIT for current behavior.

## Historical notes below — status text superseded above

# Current status: 0.10 observation stage

0.9.1 is user-confirmed stable with playerAds off and ads playing. 0.10 implements the read-only candidate coordinator probe proposed below, behind playerProbe (off by default). This is NOT ad blocking. Runtime method availability/signature and call activity still need device confirmation; no base-binary ABI verification was performed for this selector. See README.md, AUDIT.md and TEST-PLAN.md for current implementation and limitations.

Current source re-review confirmed YouTube-X still combines response-array overrides, coordinator suppression and signal changes. Its source existence does not establish effectiveness on this account/version. Reviewed YTPlaybackFix still broadly changes client identity and request paths. Neither combination was adopted. The probe is independently implemented and returns the original coordinator.

## Historical investigation, retained for rationale

> Historical player-ad research. This remains a proposal; 0.6 adds no player-ad blocking. See README.md for current features.

# Player-ad investigation — separate from the 0.3 UI update

## What is actually established

User tests on YouTube 21.38.2 / iOS 26.5 / LiveContainer 3.8.0:

- Clean YouTube plays beyond five minutes with ads.
- 0.1 could crash with an empty-array exception. That is a local data-structure failure, not evidence of server-side ad-block detection.
- 0.2's presentation-boundary feed filtering, Shorts shelves and background audio passed the reported tests.
- Native PiP worked with QuietTube PiP off. No independent benefit from our PiP hooks was demonstrated.
- No uninterrupted, ad-free player session has yet been demonstrated with QuietTube.

The 10–20-second interruptions reported in other mods may have multiple causes. We have not captured an error domain/code and a controlled single-change comparison for that failure in a new QuietTube player experiment.

## Source approaches reviewed

These are source observations, not claims of current effectiveness for this account/version.

### 1. Global player-response array overrides

YouTube-X implements empty `playerAdsArray` and `adSlotsArray` getters:
https://github.com/PoomSmart/YouTube-X/blob/main/Tweak.x

Decision: do not reinstate this approach. A getter can participate in constructing a mutable protobuf model as well as rendering it. Our earlier model-getter design was not adequately isolated. Existing use elsewhere does not validate it here.

### 2. Ad-playback coordinator suppression

The same source overrides `YTLocalPlaybackController.createAdsPlaybackCoordinator` to return nil.

This is a narrower candidate to investigate than global model mutation, but it is not proven safe: dependent code may require a coordinator, and server-side behavior may still interrupt playback. Before mutation, verify the selector and ABI in 21.38.2 and observe whether it is invoked at ad-bearing playback starts. If experimentally enabled later, isolate it behind a default-off switch with no concurrent request or response modifications. Returning nil must not be presented as an already verified fix.

### 3. Post-parse response transformation

A potential original implementation would transform a copy of a completed response at a verified handoff to the playback consumer, instead of replacing global field getters. This avoids the particular getter/construction flaw, but can still violate coordinator/streaming assumptions. The feed handoff that worked does not establish the equivalent player boundary. We first need to identify that boundary and verify method ownership/signatures; this is not implemented.

### 4. Signal / request-context alterations

YouTube-X also changes signal-generating methods and an ad-context-related configuration method. A combined tweak makes it hard to know which change is necessary or responsible for a regression. We should not remove unrelated signals or change account-scoped request generation as a first experiment.

### 5. Alternate client identification

YTPlaybackFix's reviewed source uses a TV/game-console client identity and intercepts requests:
https://github.com/Mark02-2012/YTPlaybackFix/blob/main/YouFixPlaybackIssues.xm

This is not merely UI filtering. The reviewed interceptor reaches browse/next as well as playback-related paths. Broad path matching and rewriting can affect unrelated behavior and could conflict with native protobuf/request semantics. It is unsuitable for blind inclusion in a minimal signed-in app. We have no test establishing that it works for this account, maintains expected formats, or avoids the 10–20-second failure. Not included in 0.3.

### 6. Retry-and-seek recovery

YTPlaybackFix's Refresh.xm retries playback after selected errors and seeks back:
https://github.com/Mark02-2012/YTPlaybackFix/blob/main/Refresh.xm

Decision: do not use this as a purported ad-block fix. It can mask a recurring failure rather than prevent it, and uninterrupted playback is the requirement.

## Proposed next player experiment

1. Preserve the known-working 0.2-derived feed/background code and native Google login.
2. Add narrowly scoped, read-only observations of the candidate playback boundary/coordinator: method presence, invocation counts and numeric errors only. Do not log response descriptions, request bodies, signed media URLs, cookies or tokens.
3. Choose ONE verified boundary for a default-off player-ad experiment. Keep coordinator suppression and post-parse transformation mutually exclusive in testing.
4. Compare the same videos with the experiment off/on; include prerolls, a longer video with midrolls, seeking, background transitions and native PiP.
5. If interruptions reappear, retain the real error and stop rather than automatically retrying or suppressing it. Restore the known-working configuration.

No player-blocking mutation or additional playback observation hook is included in 0.3. This document is a research result and next-step design, not a running background investigation or a promise of an undetectable bypass.
