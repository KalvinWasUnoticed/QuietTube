# 0.8 audit

## Evidence

User confirmed 0.7 normal default-logo sizing. Logo file is byte-for-byte identical in 0.8. User still sees full-height inline short and a Mix card. Flags were enabled; no edge match appeared. Group 11 includes video_lockup_overlay.eml-fe and yt_fill_youtube_shorts_24pt. Other groups include Home/injection markers alone or with post lockups: those generic markers are unsafe removal criteria.

## Changes

- New classifier bit for overlay + Shorts-icon co-occurrence, gated only by the existing edgeCards flag inside extendedFeed. Both components required, bounded token matching, negative fixtures for each component alone and longer lookalike tokens.
- Separate off-by-default mixes flag. Four explicit automix/radio renderer fields and corresponding exact classes, plus three exact Mix byte tokens. Runtime access uses existing signature-checked getters. Public ytkace reference observations, not proof of target binary ownership or this Mix card's renderer. No new runtime hooks or guessed method implementations. No generic title, playlist, Home-key or feed_nudge removal.
- Normalize numeric injection teaser suffixes before deduplication and capture grouping. Include Mix/radio/playlist family words in lexical capture. Limits, opt-in gate and observation-only behavior retained. Non-numeric suffixes remain unnormalized; arbitrary identifier-shaped content may still be captured.
- Existing presentation-boundary copy/exception/empty-batch guards, immutable flags, migration key, logo, background, native PiP and error observer retained. Independent Mix switch also installs the existing boundary when needed.
- Direct IPA release workflow versioned 0.8, retains public approval gate and success-after-upload requirement.

## Validation

30 Python tests (8 packaging, 6 release mocks, 16 static/ABI), 45 C classifier fixtures + 5,000 random iterations, 20 scanner fixtures + 5,000 random iterations passed. C compiled with -Wall -Wextra -Werror and ASan/UBSan. Shell syntax and YAML parsed; source ZIP integrity checked at packaging.

## Remaining limitations

No Apple SDK/native compilation, real release upload or 0.8 device test here. Co-occurrence is in one payload, not proof of the visible root card, and nested content may match. Mix identification is reference-based and may miss new formats. Capture reached 128 samples on 0.7; normalization reduces group fragmentation, not sample consumption. Full-height ads are distinct from Shorts and not automatically covered by this rule. Player-ad blocking remains paused. No evidence yet that the prior Apple ad was removed.
