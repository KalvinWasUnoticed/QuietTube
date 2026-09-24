# Pinned 21.38.2 static inspection for 0.12

Input SHA-256: d0f6f5c9d27f7fea8f040ae59c425b3a8222f67d891937374b21ef8937deba11. Download verified before extracting ARM64 executable. Original research parser reads Mach-O Objective-C class lists and relative method lists. Capstone was used for selected ARM64 instructions and selector-stub resolution. No application execution or Apple SDK build occurred.

## Verified native path

YTLocalPlaybackController.createAdsPlaybackCoordinator at 0x1004c4034 calls the native ads-player services factory. YTRealAdsPlayerServices owns adsPlaybackCoordinatorWithOverlayManager:delegate:parentResponder:contentPlayerResponse: (@48@0:8@16@24@32@40), implementation 0x1004c4154.

At 0x1004c419c onward, the factory follows playerData → playerConfig → iosPlayerConfig. At 0x1004c41d0 it calls useNoOpAdsCoordinator. A true result reaches the allocation branch at 0x1004c41e8. Class reference 0x10c96ef98 resolves to YTNoOpAdsPlaybackCoordinator; at 0x1004c41fc it calls initWithServiceRegistryScope:delegate: with the factory's own scope and supplied delegate. No-op init (@16@0:8) explicitly returns nil; manual alloc/init is not a valid replacement.

The no-op startPrerollAdBreak at 0x1015894b8 and startPostrollAdBreak at 0x1015894f8 call adsPlaybackCoordinator:didFinishBreakWithBreakType: on the stored delegate, passing types 1 and 3. This establishes a native callback path lacking when the coordinator was nil. It does NOT establish the precise cause of code 0, validity for all responses, timing/side effects, media authorization, server behavior or safety under forced selection.

YTIIosPlayerConfig exists, but has no instance methods in its static class list. The getter is dynamically resolved; 0.12 resolves/checks its BOOL/no-argument ABI at runtime before attempting the scoped experiment. Failure leaves native selection unchanged. Getter override is limited to the exact config pointer during a synchronous native factory call, not a global YES override, and does not serialize modified fields.

## Verified insertion candidate

YTInnerTubeCollectionViewController owns insertBelowVisibleSection: (v24@0:8@16, 0x10433db18) and insertBelowVisibleSectionInternal: (@24@0:8@16, 0x10433dbdc). The outer method invokes the inner and performs further collection bookkeeping. 0.12 optionally filters the outer method's input before insertion. The actual class/content of inputs and association with the post-minimize cards remain unobserved. Skipping it may omit bookkeeping; test separately from playback.

BASE-PLAYER-ABI.json retains selected class ownership, exact signatures and addresses. These addresses are evidence only, not hard-coded patch offsets. Production hooks still require runtime signatures. No extracted executable is included in the source archive.
