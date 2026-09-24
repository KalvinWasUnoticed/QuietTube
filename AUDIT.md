# 0.6 consistency and regression audit

## Scope and evidence

Reviewed the native flags/hooks/settings, feed classifier, template scanner, binary packager, workflow and release shell script. Ran local tests on Linux. Did not run the iOS app, Apple-SDK compilation, a real GitHub upload, or account playback tests. Successful tests are not a claim of native stability or complete filtering.

## Findings and actions

| Finding | Action / status |
|---|---|
| New topics/edge formats have no user-supplied template capture | Implemented independent, default-off experimental rules with match reasons and explicit coverage warnings. No claim of verified iOS root-renderer identification. |
| “Explore more topics” is not necessarily an ad | Separate flag. Specific chips-shelf component or exact shelf-header title; generic video titles/top chip bar are not targeted. Chips shelves can still have other uses. |
| Full-height portrait display is not proof of Shorts | Independent edge-card flag. Inline component or video-card + portrait-thumbnail heuristic. This may affect compact portrait cards; no “perfect edge geometry” claim. |
| Old getter hooks could violate model invariants | Still absent. Existing copy-at-presentation logic, signature checks, bounded traversal and empty-batch fallback remain. |
| Template capture could not run when no other feed category installed the boundary hook | Capture now participates in the installation condition, while it remains absent from the drop/keep decision. Existing static test was narrowed to verify that actual invariant instead of forbidding capture from installing the observation boundary. |
| Advanced flag dependencies were unclear | Dependent switches now explain/disable themselves until Extended feed formats is enabled in saved preferences. UI refreshes after toggle changes. |
| Event artwork was visually separate from event navigation | Added image replacement only at logo-specific controller hooks. Native event/animation reset, default-logo getter, then asset/text fallbacks. No global image, custom-title or layout hook. |
| New logo rendering could recurse or be called on a background thread | Added main-thread/recursion guards and exception fallback to original image. Native downstream exceptions are not suppressed. |
| Logo method names alone were insufficient evidence | Parsed class ownership and encodings from the hash-verified 21.38.2 executable. Verified image, entity and Lottie entry points plus the default-reset method. Removed an unverified setter candidate. Runtime checks still apply; future/different paths remain a limitation. |
| Header appearance may differ between light/dark modes | Uses page style when available, otherwise current traits. Device theme-transition test remains required. |
| Autoplay switch could be confused with feed previews | Help text explicitly states it stops selected next-video actions, not in-feed previews. |
| Long option labels / accessibility text | Preferred Dynamic Type fonts and multiline labels used; the working independent navigation sheet remains. Device accessibility-size test still pending. |
| Actions artifact ZIP made IPA download hard to find | No upload-artifact steps on success. Real IPA is a release asset with direct URL in heading, plain text, release notes and log notice. |
| Release could unintentionally publish the user's modified binary | Private repo preferred. Public publication requires an explicit workflow checkbox; gate runs before download and again in release script. |
| Failed upload could leave a misleading “success” link | Summary is written only after successful `gh release create` + asset upload command. Failure mock verifies no confirmed-success summary. A failed command may still leave a partial release on GitHub; inspect/delete it if needed. |
| Old artifacts/source instructions could confuse version identity | Workflow names, IPA filename, package metadata, diagnostics/footer and new README use 0.6. Historical research docs are labeled as prior designs. |

## Tests run locally

- **26 Python tests passed:** 8 binary packaging tests; 6 workflow/release tests (mock GitHub CLI plus workflow assertions); 12 static native-source/ABI invariant checks. Source checks do not compile Objective-C or simulate UIKit.
- **26 C classifier fixtures passed** plus **5,000 deterministic random-byte iterations** with AddressSanitizer and UndefinedBehaviorSanitizer enabled.
- **10 C template-scanner assertions passed**, also sanitizer-instrumented.
- Shell syntax checked for build/release scripts; YAML parsed; source ZIP integrity checked.
- The exact same base executable previously passed a header-injection dry run. That historical check is not a new 0.6 playback or code-signing validation.

The first audit run failed one inherited static assertion that forbade any reference to the capture flag in the feature file. The code fix intentionally lets capture install the observation boundary without enabling a drop rule. The test now asserts the intended invariant specifically within the drop decision; the full suite was rerun successfully. No failing runtime test was hidden or relabeled as passed.

## Shortcomings intentionally not concealed

1. No 0.6 native compilation or device tests completed here.
2. No real GitHub release was created here; release tests use a stub CLI. Actual permission, visibility and browser-login behavior must be tested in your repository.
3. Byte-token heuristics may match nested metadata and can have false positives/negatives. Cross-platform component research does not prove identical iOS formats.
4. Exact English shelf-title matching is locale-specific; the structural chip marker is broader than that label.
5. All-unwanted top-level batches can pass through because the empty-array safety guard is retained.
6. No in-video ad blocking, verified universal logo replacement, comprehensive ad removal, or formal malware/security audit is claimed.
7. The IPA input is SHA-256 pinned but that only establishes identity with the inspected file, not its authenticity or safety.
8. A private release requires authenticated access; direct URLs do not bypass GitHub access control. GitHub's automatically generated source archives may still appear alongside the IPA asset.

## Device acceptance checklist

- New settings present with accurate default/dependency behavior.
- New topics/portrait rules remove the intended sections without hiding wanted videos or top chips.
- Plain header branding in light/dark mode; no clipped navigation or changed channel headings/icons.
- Feed refresh, search, subscriptions, video playback, background audio and native PiP continue working.
- Flags change only after restart; disabling each new flag restores its original behavior after restart.
- Direct IPA link downloads a .ipa without a wrapper ZIP, with proper private-repository authentication.
