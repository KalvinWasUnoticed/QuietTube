# 0.11 audit

## Evidence and scope

0.10 device observation: coordinator installed, entered 3, object returns 3; user saw an ad on one of several videos. No supplied error counter. This verifies active method/signature matching and observation success in that session, not whether nil is supported or blocking will be stable. Sponsored MIVI/MadMuscles cards appear after minimizing; the screenshot/capture does not identify the actual insertion method or template.

Two separate off-by-default keys: playerExperiment1 and companionAds. The previously disabled playerAds key remains disabled to prevent old stored preferences activating new code. Existing flags/migration unchanged. UI, documentation and diagnostic mode explain precedence and restart requirement.

## Player mutation

One existing coordinator hook only. Suppression branch counts and returns nil before calling the original. Observation branch still calls original once and returns the original object; native exceptions propagate. Counter exceptions alone are isolated. No fabricated completion, network/protobuf mutation, client spoofing, signal removal, retry or seek behavior. The original creator may have required side effects; its absence may crash or stall. No automatic recovery or guarantee of ad-free/undetectable playback. No player instance pointers, responses or URLs are captured.

## Sponsored cards

Four exact template candidates observed in public YouTube-X source; new classifier bit separately gated by companionAds/feedAds inside existing extendedFeed. Generic metadata, injection, Sponsored text and link strings are negative fixtures. These names have not been observed in the actual missed cards.

Public YouTubeHeader declares loadWithModel: on YTInnerTubeCollectionViewController. Runtime signature checks gate the new hook; actual method ownership/encoding was not parsed from the supplied executable and this path was not observed on the device. YTI-prefixed models only, same bounded traversal/copy logic; non-YTI, nil result and exceptions preserve input. Original always invoked once after traversal. Prior thread-local budget restored in finally. No view hiding, player model hook, unrestricted KVC or whole-model serialization. Existing active feed filters also apply at this new boundary when opted in; that scope change may affect other collection surfaces. All-empty results fail open rather than pass nil. Other dynamic insert/update paths remain uncovered.

## Preservation

Logo module, feed capture scanner, core hook ABI checks, background/PiP settings, sign-in/network code, next-video actions and original error forwarding unchanged. Existing feed rules retained; new templates/boundary only when independently opted in. Old 0.9 and 0.9.1 baseline tests account for explicitly delimited additions, new dependency, version and diagnostic text; all hashes pass. Existing direct IPA workflow, public approval gate and successful-upload link behavior preserved.

## Local tests

43 Python tests: 8 packaging, 6 mocked release, 29 source/ABI/scope tests. C with -Wall -Wextra -Werror and ASan/UBSan: 89 classifier fixtures + 5,000 random-byte iterations; 20 scanner fixtures + 5,000 random-byte iterations. Initial stale exact-list assertion was updated to include the new UI dependency, without removing prior dependency checks. Shell syntax passed. Workflow YAML and ZIP checked at packaging.

No Apple SDK/native compilation, actual GitHub release upload or 0.11 device test here. Static tests do not execute nil-return or model handoff behavior. Performance/timing, ARC semantics, stable playback, correct card removal and regression-free combined operation remain to be validated separately. Do not interpret absence of recorded errors as proof of stability.
