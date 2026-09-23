# QuietTube 0.2 — recovery / isolation build

**This is source plus a GitHub build workflow, not a compiled IPA or a verified fix.** Target: the same clean YouTube 21.38.2 IPA and LiveContainer normal launch. The changed Objective-C code has not been compiled or device-tested here.

## What the crash report establishes

The uploaded log starts with:

```
*** -[__NSArrayM objectAtIndexedSubscript:]: index 0 beyond bounds for empty array
```

YouTube accessed index zero of an empty mutable array. The rest of the log contains unsymbolicated YouTube/UIKit addresses. It does not establish which particular flag or method caused the bad model. It also does not establish ad-block detection as the cause of this crash.

Your test shows the clean app and the modified app with flags disabled work, whereas enabling modifications causes loading flicker and a crash. This strongly implicates our modifications.

Source review identified an unsafe design in 0.1: repeated-field model getters returned fresh filtered arrays. Those getters can be involved in model construction, not just presentation. This can change identity, mutation behavior and expected contents. Separately, layout callbacks repeatedly hiding content views could interfere with loading/layout. These are plausible causes, not a symbolicated diagnosis.

## Changes in 0.2

- **Removed all feed and player-response array-getter hooks.** No `contentsArray`, `itemsArray`, `playerAdsArray`, `adSlotsArray` or `adPlacementsArray` getter is overridden.
- **Removed all layout-based hiding**, plus related-section limiting, pivot manipulation and navigation view hiding for now.
- **First 0.2 launch resets modifications and available feature flags to OFF**, even when upgrading a 0.1 data container. Older stored keys have no effect because those features are no longer loaded.
- **Preferences are immutable during each guest process.** Changing a switch only saves a preference for the next launch. Refreshing the feed does NOT apply it.
- Only settings hooks load with the master switch off. With the master on, only selected feature hooks and playback error observation load.
- A new, optional feed experiment filters **copies at `addSectionsFromArray:`**, not model getters. Unchanged objects retain their identity; the original model is not intentionally mutated. It uses explicit ad/Shorts fields, not whole-model description matching.
- If filtering would turn a nonempty top-level presentation batch into an empty one, the original batch is passed through. Ads may remain visible rather than manufacturing an empty batch. This guard is not a general guarantee against every empty-array crash.
- A shorter settings footer replaces the long explanation on the main controls page.
- Diagnostics distinguish **active flags this launch** from **preferences saved for next launch**.

## Temporary reductions — important

This is NOT the full requested feature set.

**Player-ad blocking is paused and its switch is disabled. Video ads are expected.** The previous approach is removed, not fixed or silently kept active.

Home hiding is also paused. Shorts/Create tab hiding, notification/Cast hiding, related-video cleanup, end-screen cleanup, comments/community filtering, feed-preview suppression and promotional prompts are not active in this revision. Their absence lets us narrow the regression rather than combine many unverified changes.

Available experiments, all OFF by default:

1. Explicit feed-ad filtering (limited coverage).
2. Explicit Shorts-shelf filtering (not the Shorts tab).
3. Background audio eligibility.
4. PiP eligibility.
5. Selected automatic-next-video actions.

Google sign-in behavior is unchanged. No network interception, client spoofing, token logging, account export, error suppression, automatic retries, proxy service, or downloader is added.

## Update your existing GitHub repository

1. Extract `QuietTube-recovery-v0.2.zip`.
2. Upload the **contents of `QuietTube-prototype-v0.2` into your existing repository root**, replacing the previous files. Do not upload the enclosing folder as another level.
3. Ensure the hidden `.github/workflows/build.yml` was replaced too. If necessary use GitHub's file editor at that exact path.
4. Your root should contain `Sources`, `scripts`, `tests`, `Notices`, and `.github`.
5. Open **Actions → Build QuietTube Recovery IPA → Run workflow**.
6. Once successful, download artifact **QuietTube-0.2-21.38.2-recovery-IPA**.
7. Extract the artifact ZIP to get **QuietTube-0.2-21.38.2-recovery.ipa**.

The workflow uses your original supplied clean base, not the crashed modified IPA. The original SHA-256 remains pinned:

```
d0f6f5c9d27f7fea8f040ae59c425b3a8222f67d891937374b21ef8937deba11
```

No Apple or Google credentials are needed in GitHub. macOS Actions billing/allowances still depend on your account. A build failure means no new IPA; share the failed compile step if that happens.

## Install and test — in this order

Preserve your working clean app/container and account data. Do not uninstall it to run this experiment. Keep all unrelated LiveContainer global/app-specific tweaks disabled.

### A. Recovery baseline

1. Import the new IPA in LiveContainer. It needs LiveContainer to re-sign/prepare it, like 0.1.
2. Fully terminate the old guest process before launching the new build. Returning Home or refreshing a feed is not a restart; if unsure, force-close LiveContainer and relaunch normally.
3. Open **Settings → General → Quiet controls**. The footer should say **0.2 recovery build**; the master switch and feature switches should be off on first 0.2 launch.
4. Check Home, refresh, open a video and play it. Ads are expected.

If flicker/crash occurs at this baseline, stop. Do not enable features. Send the new crash report and diagnostics if reachable; revert to your preserved clean app.

### B. One-feature test

1. Enable the master switch.
2. Enable ONLY **Distractions → Filter explicit feed ads**. Leave Shorts and all Playback switches off.
3. Fully restart the guest process.
4. Check feed loading, refresh once, then try a video.
5. Send **Advanced → View diagnostics** text, whether the feed flickers, whether any feed ads disappear, and any new crash report.

If the hook is unavailable or never invoked, feed ads may remain. Do not interpret a successful build or a checked switch as proof of effective filtering. Video ads are expected throughout this test because player-ad blocking is disabled.

If there is another crash, disable modifications (if settings remain reachable), fully restart, and return to the clean baseline. Do not enable the rest of the flags simultaneously or keep reproducing the crash unnecessarily.

We will only add the other features after this isolated test is stable. This is a deliberate recovery step, not a claim that the original ad-blocking goal is complete.

## Diagnostics and privacy

Advanced → View diagnostics contains selectable text. Copy it or provide readable screenshots. It includes hook status, active/saved flags, counters and numeric playback error codes. It does not intentionally include cookies, signed video URLs, watch history or tokens.

LiveContainer's crash report is separate from QuietTube diagnostics. If attaching another report, confirm the text file is nonempty, or paste its contents. Remove personal data before sharing. No need to send Google credentials or account-data exports.

## Verification

- Eight Python packaging tests rerun: passed.
- Shell syntax and workflow YAML checked.
- Source regression checks confirm removal of the old getter/layout hook implementation and presence of the startup flag snapshot and zero-batch guard. These are static checks, NOT native runtime tests.
- The packager previously passed an actual-executable header-injection dry run on this same base IPA. That is not a playback test.
- Objective-C compilation of **0.2**: not run here; GitHub is required.
- Device testing of **0.2**: pending your test.

See `VALIDATION.json`, `Sources/`, `scripts/`, and `Notices/`. The source archive does not include YouTube's proprietary binary. The generated guest package invalidates old signatures, removes guest app extensions and needs LiveContainer signing. Do not load the standalone debugging dylib on top of the packaged IPA.
