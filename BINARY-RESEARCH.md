# 0.13.4 update

Device trace: didCollapse followed 403 ms later by applyMutationOperation → handleInsertItemSectionContent → one YTIElementRenderer insert notification. All flags ON; five player substitutions; zero companion callbacks; sponsored card persists. Native event correlation is observed, but exact payload/ad identity is not yet established.

Corrected trace vq/vqq compact registrations to vQ/vQQ to match the existing normalizer, without changing signed native wrapper ABI. Added completion-anchor fallback and bounded element detail at the observed insertion notification. No new suppression. Accepted player suffix and cleanup remain hash-protected. See README/VALIDATION.json for current checks and limits. Older sections below are historical.

---

# 0.13.3 update

Added one-button prerequisite saving and nine binary-verified pass-through minimize/mutation observers. See BASE-MINIMIZE-ABI.json and README.md. Player suffix hash and accepted cleanup checks remain unchanged. No new ad suppression. 0.13.2 device feedback: five no-op supplies, zero companion callbacks, sponsored card persists. The prior sections below are historical, not a fresh device result.

---

# 0.13.2 companion callback inspection

Pinned input SHA-256 d0f6f5c9d27f7fea8f040ae59c425b3a8222f67d891937374b21ef8937deba11 verified again. Selected Objective-C method metadata and ARM64 instructions inspected; downloaded IPA/executable removed afterward. BASE-COMPANION-ABI.json records the callback and getter encodings.

YTCompanionAdObserverBehavior owns companionAdDidChange:interactionLoggingAdsClientData: (v32@0:8@16@24), implementation 0x10172cde8. At 0x10172ce2c it reads companionAd from update. It compares currentAd, then clearEntries at 0x10172ce6c. Nil incoming companion branches at 0x10172ce70 to 0x10172d0a4; pushStagedChanges is called at 0x10172d0a8. Non-nil branches append companion/suggested entries. Passing nil update and nil logging data thus exercises the native empty-companion update path; no synthetic completion or general feed mutation is invoked by the tweak.

YTEngagementCompanionAdObserverBehavior's similarly named method instead returns on nil companion and disables its shelf on non-nil companion. It is NOT patched. Names/signatures alone were insufficient to assume equivalent behavior.

Static inspection does not map these methods to the user's screenshot or prove runtime safety. The player path retains the prior native initializer/scope/delegate workaround exactly. The previous watch-while feature hook is removed after zero recorded reads in the relevant session.

## Prior player evidence (historical feed-feature approach below is superseded)

# 0.13 static evidence and corrected hypotheses

Pinned IPA SHA-256: d0f6f5c9d27f7fea8f040ae59c425b3a8222f67d891937374b21ef8937deba11. Re-downloaded, verified, inspected Objective-C class/method/ivar metadata and selected ARM64 instructions. Inputs removed after extraction; no executable distributed. BASE-AD-PROFILE-ABI.json contains selected records.

## Native player construction

YTRealAdsPlayerServices owns the factory method adsPlaybackCoordinatorWithOverlayManager:delegate:parentResponder:contentPlayerResponse: (@48@0:8@16@24@32@40) and object ivar _serviceRegistryScope with type @"<YTServiceRegistryScope>". Earlier factory disassembly verified its no-op branch allocates YTNoOpAdsPlaybackCoordinator and calls initWithServiceRegistryScope:delegate: (@32@0:8@16@24) with this scope and the original delegate. Parameterless init explicitly returns nil, so it is not used. Native preroll/postroll methods call the stored delegate's break-finished method.

0.12 diagnostics: missing config on all three factory calls meant the scoped config approach did not select that branch. Scheduled retries at 1/3/8 seconds compared the already-installed getter IMP to itself, generating the misleading three not-installed counts. 0.13 uses persistent install success flags and constructs the native object through the verified initializer, independent of response availability. This substitutes the factory return and bypasses the original factory on success; it is not a claim of an unchanged native call path. Fallback calls original with original arguments. Constructor validation includes object ivar and exact init encoding; no raw ivar offsets or scope writes.

## Feed-mutation path

YTInFeedDynamicSectionListLayoutRenderingAdapter initializer at 0x1015cb2c0 calls enableWatchWhileFeedMutationOnIos at 0x1015cb364. With the flag enabled and required renderer fields present, it stores triggeringLayoutId, sectionListTargetId and mutationOperations and registers addLayoutEnteredEventListener: at 0x1015cb484. Disabled/invalid setup follows native onLayoutErrorWithSlot:layout:exception:type: handling rather than registering that listener. This is native ad-control-flow behavior, not a forged impression/completion.

YTHotConfig contains the selector enableWatchWhileFeedMutationOnIos with BOOL/no-argument encoding B16@0:8 (two metadata entries, same ABI). 0.13 hooks the runtime-selected implementation and returns NO only while the ad profile is effective. It does not hook all mutation methods or collection updates. The zero insertBelowVisibleSection counter in the user's 0.12 run invalidates treating that selector as a demonstrated path for the reproduced cards.

Static evidence establishes a feature-controlled ad mutation mechanism, not that every screenshot card uses it or that disabling it cannot affect other watch-while behavior. Device confirmation and separate report counters remain necessary. No interpretation of code0 as proof of server detection; no undetectability guarantee.
