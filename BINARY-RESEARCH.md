# 0.13 static evidence and corrected hypotheses

Pinned IPA SHA-256: d0f6f5c9d27f7fea8f040ae59c425b3a8222f67d891937374b21ef8937deba11. Re-downloaded, verified, inspected Objective-C class/method/ivar metadata and selected ARM64 instructions. Inputs removed after extraction; no executable distributed. BASE-AD-PROFILE-ABI.json contains selected records.

## Native player construction

YTRealAdsPlayerServices owns the factory method adsPlaybackCoordinatorWithOverlayManager:delegate:parentResponder:contentPlayerResponse: (@48@0:8@16@24@32@40) and object ivar _serviceRegistryScope with type @"<YTServiceRegistryScope>". Earlier factory disassembly verified its no-op branch allocates YTNoOpAdsPlaybackCoordinator and calls initWithServiceRegistryScope:delegate: (@32@0:8@16@24) with this scope and the original delegate. Parameterless init explicitly returns nil, so it is not used. Native preroll/postroll methods call the stored delegate's break-finished method.

0.12 diagnostics: missing config on all three factory calls meant the scoped config approach did not select that branch. Scheduled retries at 1/3/8 seconds compared the already-installed getter IMP to itself, generating the misleading three not-installed counts. 0.13 uses persistent install success flags and constructs the native object through the verified initializer, independent of response availability. This substitutes the factory return and bypasses the original factory on success; it is not a claim of an unchanged native call path. Fallback calls original with original arguments. Constructor validation includes object ivar and exact init encoding; no raw ivar offsets or scope writes.

## Feed-mutation path

YTInFeedDynamicSectionListLayoutRenderingAdapter initializer at 0x1015cb2c0 calls enableWatchWhileFeedMutationOnIos at 0x1015cb364. With the flag enabled and required renderer fields present, it stores triggeringLayoutId, sectionListTargetId and mutationOperations and registers addLayoutEnteredEventListener: at 0x1015cb484. Disabled/invalid setup follows native onLayoutErrorWithSlot:layout:exception:type: handling rather than registering that listener. This is native ad-control-flow behavior, not a forged impression/completion.

YTHotConfig contains the selector enableWatchWhileFeedMutationOnIos with BOOL/no-argument encoding B16@0:8 (two metadata entries, same ABI). 0.13 hooks the runtime-selected implementation and returns NO only while the ad profile is effective. It does not hook all mutation methods or collection updates. The zero insertBelowVisibleSection counter in the user's 0.12 run invalidates treating that selector as a demonstrated path for the reproduced cards.

Static evidence establishes a feature-controlled ad mutation mechanism, not that every screenshot card uses it or that disabling it cannot affect other watch-while behavior. Device confirmation and separate report counters remain necessary. No interpretation of code0 as proof of server detection; no undetectability guarantee.
