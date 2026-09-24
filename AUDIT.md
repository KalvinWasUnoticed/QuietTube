# 0.10 audit — player observation stage

## Scope and new implementation

User authorized progressing to 0.10 after confirming 0.9.1 ads-enabled playback is stable. The agreed first step is observation, not an unverified bundle of blocking hooks. Added QTPlayerProbe.m, one default-off Playback preference, installer declaration/call, diagnostic explanation and build input. Source selector observation: https://raw.githubusercontent.com/PoomSmart/YouTube-X/main/Tweak.x . No implementation copied into the new probe; existing third-party notices retained.

Runtime QTHook validates selector availability, zero explicit arguments and object return ABI. Inherited methods are overridden on the named class, not patched on the superclass. Native class/selector ownership was NOT parsed from the supplied executable for this probe. The method name `create…` is not one of the Objective-C retained-return method families used by `new/copy/alloc`; nevertheless native compilation and ARC behavior remain untested here. Runtime ABI checks do not establish nullable-result semantics or that this is the active ad path.

The hook counts entry, calls its saved original exactly once and returns the same result. It does not retain a coordinator in persistent state, enumerate it, change properties, disable it or intercept its network activity. Native exceptions propagate. Only exceptions raised while counting are caught so a failed diagnostic cannot prevent the original call/return. Additional overhead and return-value lifetime effects are possible; read-only instrumentation is not a zero-risk assertion.

## Preservation of earlier requirements

- Native YouTube 21.38.2 / pinned base / LiveContainer packager and Google sign-in paths unchanged.
- Feed array-getter/layout overrides remain absent. Bounded traversal, copy-before-set, exception fallback and empty-batch guard unchanged.
- User-confirmed logo reset code unchanged; no forced rescaling or custom image fallback.
- Mix RD destination, inline Shorts, Watch again, topic, Shorts, feed-ad and optional display-ad rules unchanged. No new coverage claims.
- Background hooks unchanged; native PiP governs PiP. No redundant PiP control restored.
- Settings navigation/Done retained; saved flags immutable until restart, no new preference reset.
- Autoplay setting still concerns next-video actions, not feed previews.
- Player-ad blocking remains disabled. No response arrays, signal suppression, alternate client spoofing, fake ad completions, retries, seeks or error masking.
- Existing numeric playback-error observer forwards to the native handler unchanged. No raw error descriptions/URLs/tokens are collected by the probe.
- Direct IPA release link, public approval gate/private repository recommendation and upload-success requirement preserved, versioned 0.10.

## Checks

39 Python tests: 8 packaging, 6 mocked release, 25 source/ABI/patch-scope. Immediate-baseline hashes for 11 source/build/workflow files compare against 0.9.1 after removing only marked probe additions, added build input and version/headline changes. Historical 0.9 preservation checks also pass. Probe source checks verify default-off/master gates, runtime signature request, one original call and unchanged result, no catch around native code, no private-data/request/response handling and clear diagnostics.

79 C classifier fixtures plus 5,000 random-byte iterations and 20 scanner fixtures plus 5,000 random-byte iterations passed with ASan/UBSan, -Wall -Wextra -Werror. Native source checks are static, not compiled Objective-C execution. Shell syntax passed; YAML and source ZIP checked during packaging.

No Apple SDK build, actual GitHub release upload or device validation here. No blocking solution or invisible/undetectable behavior established. See TEST-PLAN.md for off/on comparison and stop conditions.
