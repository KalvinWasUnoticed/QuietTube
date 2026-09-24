# QuietTube 0.7 audit

## Evidence and scope

The user's 0.6 runtime report supersedes its pre-device assessment: inline short and sponsored Apple card persisted; the default wordmark became tiny. Active flags were correct. 143 payload inspections and 5 explicit-ad matches do not identify the missed card; zero edge matches means the edge heuristic had no observed effect. All 92 capture samples lacked accepted `.eml` names, not necessarily metadata.

## Changes and safeguards

- Deleted `updateLogoWithImage:needsRescaling:withYoodle:` hook and all custom/default-image fallbacks. No guessed rescaling value replaces it. Native default reset still has main-thread, recursion, signature and exception guards. Two installed-hook signatures match `BASE-LOGO-ABI.json` from the pinned executable. Runtime behavior is not established by ABI checks.
- Added `.e` and structured extensionless identifier capture. Maximal lowercase lexical runs only; known family segment and underscore required when no suffix. Length, deduplication and URL/path/email boundary checks remain. No full payload/model dump. Some identifier-shaped content may pass, and binary boundaries/encoding may hide real identifiers. This is not a schema parser or a privacy guarantee for every captured string.
- Six additional exact ad-marker candidates come from the retained YTLite reference, not the screenshot. Separate classifier bit and new off-by-default preference require both feedAds and extendedFeed. Partial-word negative tests retain ordinary similarly named templates. Matching nested metadata still risks false positives; switch permits isolation.
- No edge heuristic change without new evidence. No removal of arbitrary portrait videos.
- Existing launch snapshot, migration key, bounded traversal, copy-before-mutation, exception fallback, preserve-empty-batch logic and settings navigation retained. No playback/sign-in/PiP changes.
- Direct IPA GitHub release workflow preserved and versioned 0.7; private-repo default recommendation, public approval gate, and no success link on mock upload failure retained.

## Local regression results

28 Python tests passed: 8 packaging, 6 release CLI mocks, 14 static source/ABI checks. C passed with `-Wall -Wextra -Werror -fsanitize=address,undefined`: 32 classifier fixtures plus 5,000 random-byte iterations and 15 scanner fixtures plus 5,000 random-byte iterations. Build/release shell syntax passed. Workflow YAML and source archive checked separately at packaging.

These test model/byte behavior and source invariants, not Objective-C compilation or runtime UI. Native compilation, LiveContainer guest lifecycle, default logo size/event suppression, actual sponsored-card removal, Google sign-in, background audio, PiP and playback must be checked on device. Player-ad blocking remains deliberately paused.
