# QuietTube 0.13.5 — scoped blocking of explicitly marked feed insertions

**Source + GitHub build workflow, not an installable IPA.** Pinned YouTube 21.38.2 base.

## Evidence from your 0.13.4 report

All required flags were active. The corrected transition hooks ran. At +0.978 seconds after collapse started, the app collection handled an item-content insertion and inserted one `YTIElementRenderer` with **`hasAdLoggingData = YES`**. Its byte classifier mask was zero. That explicit marker is already checked by the accepted presentation filter; the trace supports a missing dynamic-insertion boundary rather than a need to blacklist generic template names.

The report again recorded five native no-op player substitutions and zero companion callbacks. It does not by itself establish player-ad absence or playback stability for that session.

## Actual blocking change

The unused companion-clearing hook is removed. In its place:

1. Enter a thread-local scope only while the observed `handleInsertItemSectionContent:error:` runs on `YTAppCollectionViewController` (or a subclass), with the ad profile active and feed ads enabled.
2. At `YTArraySectionViewModel / insertEntries:atIndex:`, remove only exact `YTIElementRenderer` entries whose compatibility options have the explicit ad-logging presence marker.
3. Pass a new retained-entry array to the original native insertion once, with the original index. Preserve unmarked/unknown entries and their order. Leave the original array/objects untouched. Unchanged input keeps its identity.
4. Restore the previous scope in `@finally`; other controllers, other threads, calls outside this transaction, profile OFF, feedAds OFF and safety-stopped calls retain native behavior.

The handler itself receives its original operation and NSError pointer and produces its own return value. No fabricated mutation-result object, nil coordinator, post-insertion notification suppression, error swallowing or retry is used. Inspection failures pass the original array. Batches over 512 entries pass through rather than being partially scanned.

### Why empty arrays are allowed here

The pinned binary was re-downloaded and SHA256-verified. Disassembly shows append/prepend/before/after **array** insertions converge on this method. At `0x100505710` it reads input count; at `0x100505714` zero count branches to release/return, before storage, index-set or index-rebuild operations. Thus an all-ad batch reaches an existing native no-op branch. This is specific evidence for this boundary, not permission to empty arbitrary YouTube arrays.

See BASE-FEED-INSERTION-ABI.json and Notices/insertion-boundary-disassembly.txt. Static evidence does not prove all later server updates or device sessions tolerate the omitted entry.

## Scope and limits

This is the first blocking revision aimed at the device-observed insertion and explicit marker. **Card removal and runtime safety still need device confirmation.** It is not a blanket gesture-based blocker, and is not guaranteed Home-only: the app-collection class can serve multiple contexts. Any explicitly marked entry encountered during its scoped synchronous item-content insertion is eligible.

Unknown/unmarked elements, different methods, direct single-entry methods, asynchronous work after the handler returns, and paths bypassing this array method are deliberately not covered. Handler case 4 has a separate insert-below path; coverage of that branch is not asserted. Potential later operations referring to an omitted ad's target have not been device-tested. Do not claim undetectability.

## Preserved and cleaned up

- Player construction/fallback suffix is byte-for-byte unchanged from 0.13.1 onward. The reported active no-ad/stable session was 0.13.1; no universal guarantee is made.
- Accepted cleanup, logo, settings navigation, native PiP/background and sign-in-related code are unchanged.
- Retired the zero-call companion hook and its active clearing/counter code. Its historical evidence/tests remain as history, not installed functionality.
- The trace and filter share one handler hook rather than competing to install it. Optional tracing is not required for filtering to work.
- Prepare ad test still saves the same seven flags, preserves unrelated preferences and requires a full guest restart.

## Build and one test

1. Replace repository files including `.github`, Sources, tests and evidence records. Commit and start a **new workflow run**.
2. Download `QuietTube-0.13.5-21.38.2.ipa` from **Summary → DOWNLOAD IPA — QuietTube 0.13.5**. Private downloads need authorized GitHub login; public release needs explicit approval.
3. Import into the same LiveContainer data container without a second injection. Keep the old IPA for rollback.
4. Tap **Quiet controls → Prepare ad test**, fully stop/relaunch the guest, play a video and swipe down once. Wait about 12 seconds, then copy **Advanced → Ad test report** before further swipes/scrolling.
5. Send that report and whether the sponsored card appeared; mention any player/feed regression. No extra flags, full diagnostics or two-run matrix required.

New report counters distinguish handler calls, scoped array calls, matched entries and **entries withheld on returned native calls**. If an all-ad insertion is blocked, zero insert notifications afterward can be expected. A positive withheld count establishes argument filtering, not that every visible ad has disappeared. Zero scoped array calls explicitly leaves the boundary unconfirmed on device.

## Validation and safety

70 Python source/ABI/packaging/release checks passed clean and overlaid onto 0.13.4; frozen player/cleanup hashes passed. C sanitizer runs cover classifier, template scanner, status state and the new shared insertion gate/marker/bounds policy. Native hooks themselves were not executed here. Shell/workflow YAML and ZIP checks passed; details in VALIDATION.json.

**No Apple SDK compilation, real cloud release or 0.13.5 device test here.** Existing observed-playback-error latch restores native behavior for future calls only and saves the profile OFF; it does not repair an existing player or restore withheld feed entries. Restart after errors; revert for crashes, stalls or broken feed updates. Prepare explicitly opts back in for a new test.
