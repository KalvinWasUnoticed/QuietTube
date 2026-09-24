# QuietTube 0.6 — feed controls, plain logo, direct IPA downloads

**This download is source + build workflow, not a compiled IPA.** YouTube base stays at 21.38.2 with the original pinned SHA-256. Keep your working 0.4/0.5 IPA and data as a fallback. No player-ad blocking is added.

## Changes you requested

### 1. Hide “Explore more topics” shelves

New switch under **Distractions**, off by default. Requires **Extended feed formats**.

Matches the specific `chips_shelf` component family or an exact English shelf-header title. It does not match arbitrary video titles and does not target the generic `chip_cloud` top filter bar. Because chips-shelf families can be reused, other shelves of that family can also be hidden. The English-title fallback does not cover every locale.

### 2. Hide edge-to-edge video cards

New independent switch under **Distractions**, off by default. Requires **Extended feed formats**.

Experimental rules recognize an `inline_shorts` component, or selected video-lockup/card markers combined with portrait-thumbnail markers. This is **not a measurement of the actual card's geometry** and is not yet verified against your captured layout. It may miss the full-height card or also hide compact portrait cards. It does not hide every video just for using a generic `video_card` marker, and excludes the common `frame0.jpg` heuristic because it can identify normal videos too.

We did not receive a 0.5 template capture before this release; these rules are cross-client candidates plus narrowly scoped structural/title checks, not confirmed iOS renderer identification.

### 3. Use plain YouTube logo

New switch under **Distractions**, on by default when modifications are enabled. You can disable it independently.

The logo update hooks target `YTHeaderLogoControllerImpl`, not every image/view in the app. They route the native event/entity and Lottie-animation entry points through YouTube's own `updateToDefaultLogo` method. The image hook uses its native default wordmark first, then a normal asset or local text-only “YouTube” label as fallbacks. The intended result is a plain wordmark instead of the event artwork, without a global UI-image replacement.

Class ownership and method encodings were parsed from the hash-verified supplied executable and recorded in `BASE-LOGO-ABI.json`. Runtime signature checks still gate installation. A different future rendering path can evade these hooks; unsupported methods are recorded rather than patched using guessed ABIs. This is an implemented candidate fix, **not a verified device result**.

### 4. Actual IPA download, no outer ZIP

Successful builds now upload **QuietTube-0.6-21.38.2.ipa directly to GitHub Releases**, not to Actions Artifacts. The run summary contains a large **DOWNLOAD IPA** link and a release-page fallback. The release notes repeat the direct link. The upload step also prints the URL and a notice.

An IPA is internally ZIP-formatted by Apple's convention, but its download filename is `.ipa`; there is no extra artifact ZIP to extract. GitHub may show automatically generated **Source code (zip)** / **Source code (tar.gz)** links on a release. Ignore those—choose the `.ipa` asset.

## Update your repository and build

1. Extract `QuietTube-v0.6.zip` (the source distribution).
2. Upload the **contents of `QuietTube-v0.6` to your existing repository root**, replacing the previous files. Include the hidden `.github/workflows/build.yml`, new `Sources/QTLogo.m`, new `scripts/release.sh`, and all tests.
3. Prefer a **private repository** for this personal modified app. Release assets inherit repository visibility and a public release would expose the modified YouTube IPA.
4. Open **Actions → Build QuietTube IPA → Run workflow**.
   - Private repository: leave the public-release checkbox off.
   - Public repository: the build stops unless you explicitly approve public IPA publication. Only approve if you have the rights to publish it; otherwise use a private repository.
5. Wait for success, then click the completed run. In **Summary**, click **DOWNLOAD IPA — QuietTube 0.6**.
6. Alternatively open the repository's **Releases**, choose the newest QuietTube 0.6 prerelease, then select the `.ipa` under Assets.
7. Import the downloaded `.ipa` directly into LiveContainer and allow guest signing/preparation. Fully restart the guest process afterward.

Private downloads require the GitHub account with repository access. If the direct link opens poorly in an in-app browser, open the release-page link in Safari, sign in, then tap the IPA asset. The link is not an anonymous/private-content sharing link.

No Apple or Google credentials need to be added. The workflow's built-in GitHub token receives `contents: write` for creating its release; no personal access token is requested. Organization policy can still prohibit release creation. If upload fails, the run reports failure and does not display a confirmed-success download summary. Check the red step rather than installing an old build by mistake.

Each run/attempt receives its own release tag so downloads cannot silently overwrite a prior test build. Release assets persist until you delete them (unlike expiring Actions artifacts); remove old releases manually if needed. macOS Actions allowance/billing still applies.

## Settings after installing

Existing settings are preserved when using the same data container; there is no new preference reset. The existing recovery reset still applies when upgrading directly from 0.1 or installing fresh.

- **Enable modifications**: on.
- **Extended feed formats**: on.
- Enable **Hide “Explore more topics” shelves**.
- Enable **Hide edge-to-edge video cards**.
- **Use plain YouTube logo**: on by default; turn off if it causes a header regression.
- Keep your working Feed ads, Shorts, Background audio and native YouTube PiP settings.
- Leave template inspection off unless a missed card needs investigation.

Dependent switches are grayed out with an explanation when the saved Extended feed formats preference is off. This avoids the former confusing state where a switch appeared usable but its dependency was missing. Flags still take effect on full guest-process restart, not refresh.

“Stop automatic next video” does not control in-feed autoplay previews; its explanatory text now says so. Player-ad blocking remains paused. The settings sheet/Done navigation and native PiP are retained.

## Regression check on your iPhone

1. Verify the footer says 0.6 and the source build was successful.
2. Restart after configuring the new flags. Check the top-left wordmark in light and dark appearance.
3. Confirm Home loads/refreshes, the top topic-selection bar remains, normal videos remain, and search/subscriptions work.
4. Look for the two unwanted layouts. If a normal portrait card disappears that you wanted to keep, disable **edge-to-edge video cards**, restart, and compare.
5. Play a normal video for five minutes; switch apps/lock the phone and check audio and lock-screen controls.
6. Verify native PiP and returning to the app. Confirm the Quiet controls sheet/back/Done controls still fit.

If a rule misses or the logo stays decorated, send diagnostics rather than enabling more unrelated options. Useful new counters:

- `match Explore topics shelf title`
- `match topics shelf element tokens`
- `match inline portrait card heuristic`
- `header logo image update intercepted`
- `event logo replaced by native default` / `animated logo replaced by native default`
- `plain logo native default used` / `plain logo native asset used` / `plain logo text fallback used`
- `plain logo update skipped — thread or recursion guard`
- `plain logo generation failed — kept original`

Also include any unavailable/signature-mismatch entries for `YTHeaderLogoControllerImpl`. A switch alone does not prove the corresponding hook is active. Do not remove the empty-array guard to force a filter: it remains deliberately intact.

## Audit and testing

See **AUDIT.md** for findings and shortcomings, and **VALIDATION.json** for results actually obtained. Tests run locally include packaging, mock GitHub-release shell integration, static source checks and sanitizer-instrumented pure C matcher/scanner tests. They do not replace native compilation or device testing. This environment has no Apple SDK, so 0.6 Objective-C compilation happens on GitHub and native behavior remains unverified.

## Privacy and licenses

No new authentication interception, request rewriting, error suppression, auto-retry loop or network service is added to the app. Template capture remains opt-in, bounded and in memory; review extracted names before sharing. Release publication is the only new build-network behavior and is subject to the explicit visibility guard.

Third-party research/attribution is recorded in `Notices/`. The source archive does not contain the proprietary YouTube binary. Building from your supplied base does not itself grant redistribution rights. App extensions are removed by the packager as in previous builds, and LiveContainer must sign/prepare the guest app.
