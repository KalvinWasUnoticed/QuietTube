# QuietTube 0.9.1 — context and regression audit

## Scope

User requested a separate switch for the English “Watch it again” shelf, keeping the now-working feed and prior functionality intact. This release adds only that opt-in feature, dependencies/counters/tests and a version bump. No player-ad work is mixed into this patch.

## Review against conversation history

| Requirement / earlier issue | 0.9.1 treatment and evidence |
|---|---|
| Native YouTube 21.38.2 in LiveContainer, not a separate player | Same hash-pinned base and packager, same dylib injection and extension stripping. No second injection or new login flow. |
| Preserve Google sign-in / same data | No authentication, network or account edits; same preference namespace. Preservation is source evidence, not a fresh sign-in test. |
| 0.1 empty-array crash and feed flicker | Global model getter overrides and layout hiding remain absent. Presentation boundary, copy-before-set, exception fallback and nonempty-batch guard unchanged. |
| Settings navigation offscreen before 0.3 | User-confirmed owned navigation sheet/Done implementation unchanged except new switch dependency list and version. |
| Background audio and native PiP | Existing background hooks unchanged; redundant tweak PiP switch/hooks remain absent. Native YouTube PiP still governs behavior. No new playback requests. |
| Automatic next video | Existing selected-action suppression unchanged; still does not stop in-feed previews. |
| Shorts shelves, edge-to-edge Shorts and feed ads | All prior classifiers and gates preserved. User says inline Short/ad seem gone; 0.9 logs show one overlay+icon hit, 10 Shorts hits, 2 explicit-ad hits. These are not unique-card counts or proof of every ad's removal. |
| Mix recommendations | Existing RD URL and native navigation checks unchanged. User's 0.9 log has one Mix RD query match and reports most feed issues fixed. |
| Explore topics vs top topic-selection bar | Existing chips_shelf/exact shelf-title rules unchanged. No generic chip_cloud removal. Existing broader chips-shelf/locale limitations remain. |
| Playables and event/promo controls | Existing independent rules unchanged; no new coverage claim. |
| Default YouTube logo | Byte-identical to 0.9 and device-confirmed 0.7 fix. Two native-default reset hooks retained; forced image rescaling and custom rendering remain removed. |
| New Watch it again switch | Off by default, Extended feed formats dependency, immutable launch flag. Native exact shelf-title path plus bounded horizontal-element/string-field candidate. English only, unverified on device; may miss indirect text or match nested content. Does not delete watch history. |
| Diagnostics | Same bounded session-only opt-in capture, normalization and counters. No raw dumps, persistent capture or uploads. Inspection does not itself remove content. |
| Preserve preferences / rollback | No new migration reset. Same data container recommended, full guest restart required. Original 0.2 recovery migration remains only for fresh/very old installs. |
| Direct IPA output and prominent link | Versioned 0.9.1 actual IPA in GitHub Releases, prominent Summary link, no outer Actions artifact ZIP; public-publication approval and failure handling retained. Private repository recommended. |
| Uninterrupted player-ad blocking | Still unresolved and paused, as agreed. No unsafe response-array overrides, retries/seeks, error masking or unsupported bypass promise. Keep separate from feed patch. |

## Patch-scope verification

BASELINE-0.9.json records SHA-256 hashes of 11 baseline source/build/workflow files after replacing the version with a placeholder. The new test removes only marked new shelf-feature blocks, the new enum bit, new install-gate operand and new UI dependency key, then compares hashes. It passed for Core, Features, Settings, feed classifier, logo, capture scanner, Core header, build script, packager, release script and workflow. This demonstrates preexisting implementation preservation, not native runtime equivalence.

The new native title path uses the existing QTShelfTitle helper, restricted to YTI…ShelfRenderer classes. Element matching requires a bounded horizontal_shelf token and a legal protobuf-style length-delimited field candidate containing an exact supported title. The byte scan is not a decoded root template; it scans legal-looking fields at arbitrary offsets and nested text may match. It accepts tags up to five bytes and short single-byte string lengths, rejects truncation/illegal wire types, and never reads beyond a <=256 KiB payload. Removing the containing shelf rather than only its header uses existing wrapper propagation and empty-batch protection.

Generic Home/injection keys, ordinary title text, standalone shelf_header, ordinary horizontal shelves, and top chip_cloud do not match this new rule in negative fixtures. No library-specific navigation scope was added: the shared presentation boundary may apply elsewhere.

## Local results and remaining checks

34 Python tests passed: 8 packaging, 6 mocked release, 20 static/source/ABI/patch checks (11 files verified within the preservation test). C: 79 classifier fixtures and 20 scanner fixtures plus 5,000 random iterations each under ASan/UBSan and -Wall -Wextra -Werror. An initial new fixture used the wrong encoded title length; it was corrected to the actual 14-byte English text, and the full suite reran successfully. Shell syntax passed; YAML/archive checked at packaging.

No Apple SDK/native Objective-C compile, actual release upload, LiveContainer import, 0.9.1 shelf removal, sign-in or playback test here. On-device acceptance remains: new shelf removed, ordinary content/top bar retained, existing cleanup/logo stable, navigation functional, background and native PiP working. A preserved source baseline is not a guarantee against runtime interactions from the new rule.
