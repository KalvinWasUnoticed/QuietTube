# 0.11 — first player mutation and separate sponsored-card experiment

- New default-off playerExperiment1 skips coordinator creation; the observed native hook is reused, not duplicated. Observation-only still available.
- New default-off companionAds adds four reference-observed display-ad families and a guarded model-load boundary. No claim that these are the pictured cards' templates/path.
- Preserve existing working rules, logo, background/PiP, login, navigation, preferences and direct IPA release workflow.
- New diagnostics, rollback instructions and separate test matrix. Neither experiment device-tested here.

# 0.10 — player test 0, observation only

- Add default-off Observe player ad coordinator control and one signature-checked pass-through hook.
- Count calls and object/nil results; do not block ads or change requests/responses.
- Preserve 0.9.1 feed/logo/background/native PiP and existing error forwarding.
- Add baseline hashes, source checks, explicit test protocol and direct IPA release version 0.10.
- Native build/device result pending. No ad-free or undetectable playback claim.

# 0.9.1 — optional Watch it again shelf hiding

- Add independent off-by-default Distractions switch, requiring Extended feed formats and restart.
- Match exact English native shelf titles; add horizontal-element + exact encoded title candidate without hiding generic horizontal shelves or editing watch history.
- Preserve 0.9 implementation outside the new feature/version bump; add baseline hash comparison across 11 files and focused negative fixtures.
- Keep player-ad blocking paused; direct release asset versioned 0.9.1.
- User 0.9 report: most feed problems fixed, Mix RD query match present; Watch it again shelf remains. New shelf rule awaits device confirmation.

# 0.9 — Mix playlist destination coverage

- Add bounded RD-family playlist query matching and signature-checked native navigation playlist-ID matching under the existing Mix control.
- Preserve working inline, logo, playback and capture code; do not match generic Home/shelf markers or title text.
- Add 18 C fixtures and a source-scope regression test; preserve direct IPA download workflow.
- 0.8 user result: inline ad/Short seem gone, one inline match; Mix remains with zero Mix matches. 0.9 device result pending.

# 0.8 — follow-up to 0.7 capture

- Preserve user-confirmed logo fix unchanged.
- Add overlay + Shorts-icon candidate under the existing edge-card switch.
- Add separate off-by-default Mix recommendation control with explicit renderer/token candidates.
- Normalize numeric injection teaser capture suffixes; add Mix-related diagnostic families.
- Add negative and positive regression fixtures; retain direct IPA download workflow.

# 0.7 — targeted follow-up to 0.6 device failures

- Remove forced native-logo image rescaling and custom image fallbacks; retain two native-default reset hooks.
- Expand opt-in lexical capture to `.e` and structured extensionless component candidates.
- Add separately gated, off-by-default display-ad candidate rules from retained reference identifiers.
- Preserve edge rules as experimental: reported full-height inline short is not established as fixed.
- Preserve direct IPA release links, versioned 0.7; add regression tests.
- 0.6's prior pre-device assessment is superseded: user confirmed tiny logo and missed edge/ad cards.

## Historical notes below

# 0.6 feed controls and direct IPA

Adds default-off topics-shelf and inline/portrait-card filters, with limited experimental coverage. Adds default-on plain-header-logo hook, dependent UI controls, Dynamic Type text, and clearer autoplay help. Fixes observer installation for capture-only feed diagnostics. Keeps the working navigation sheet and native PiP.

Replaces successful Actions artifact uploads with a directly downloadable GitHub Release IPA and prominent summary/notes links. Public release requires explicit approval. Adds release-shell integration tests and expanded classifier/static regression tests; see AUDIT.md for unresolved limitations.

# 0.5 diagnostic capture

Opt-in bounded template-like name capture; no new blocking rules.

# 0.4 extended feed

User reports Shorts shelves removed, but topics and edge-to-edge cards still visible. Coverage incomplete.

# 0.3 settings

User-tested settings sheet and native PiP; own PiP hooks removed.
