# 0.9 audit — Mix destination candidate

## Runtime evidence from user

0.8: mixes and extendedFeed on, zero Mix matches, Mix screenshot persists. One inline overlay + Shorts-icon match; user reports inline ad and Short seem gone. Logo remains confirmed fixed from 0.7. Generic captured Home/injection keys and horizontal_shelf/shelf_header do not justify removal.

## Change scope

New RD playlist destination matching only under mixes and extendedFeed. Native read path restricted to the item's navigationEndpoint.watchEndpoint.playlistId, using QTGet object ABI checks. No setter, new hook, menu search, title search or arbitrary object description. Native getter availability is not yet established on this binary/device; unavailable getters fail open.

New byte rule requires query-boundary ?list= or &list=, uppercase RD, at least one following playlist character, at most 96 bytes, and permitted query/end boundaries. Invalid encoded continuations are not matched as prefixes. It intentionally does not decode escaped URLs or compressed payloads, scan naked RD tokens, or parse arbitrary protobuf IDs. These restrictions can miss other representations. Matching a nested URL may hide an enclosing item; matching RD can include radio-style auto playlists beyond music Mix recommendations. Shared presentation boundary is not Home-only.

Reference: https://github.com/MorpheApp/morphe-patches/pull/1835 documents an Android move to RD query matching. Independent implementation, no upstream implementation copied. This is cross-client evidence, not proof of the actual iOS Mix's bytes.

## Regression safeguards

Logo and lexical capture scanner byte-for-byte unchanged from 0.8. Existing ad/Shorts/edge/topic token rules unchanged; new classifier bit has its own counter and Mix gate. Existing explicit Mix rules retained. Background, native PiP, error observer, sign-in behavior, copy-before-set, exception fallback, top-level empty-batch guard, launch snapshot and migration key unchanged. No player-ad experimentation included.

31 Python tests passed: 8 packaging, 6 mocked release, 17 static/ABI. 63 classifier fixtures and 20 scanner fixtures, each plus 5,000 random iterations, passed under -Wall -Wextra -Werror and ASan/UBSan. Build/release shell syntax passed. YAML and archive checked during packaging. Direct IPA release workflow versioned 0.9, approval and upload-success gates preserved.

No native Objective-C build, device test or real release upload here. Removal remains unverified until device testing. Do not claim the explicit-ad counter identifies the disappeared inline ad, or that the new Mix matcher solves every format. Player-ad blocking remains pending a separate investigation.
