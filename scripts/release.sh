#!/bin/bash
# Publish only when authorized; no workflow artifacts/outer ZIP on success.
set -euo pipefail
: "${GITHUB_REPOSITORY:?Missing repository}"
: "${GITHUB_RUN_ID:?Missing run id}"
: "${GITHUB_RUN_ATTEMPT:?Missing attempt}"
: "${GITHUB_SHA:?Missing source commit}"
: "${GITHUB_STEP_SUMMARY:?Missing summary path}"
: "${GH_TOKEN:?Missing Actions token}"
if [[ "${REPO_PRIVATE:-}" != "true" && "${ALLOW_PUBLIC_RELEASE:-false}" != "true" ]]; then
  echo 'Public IPA publishing requires explicit approval in Run workflow.' >&2
  exit 1
fi
ipa="${IPA_PATH:-artifacts/QuietTube-0.14.0-rc1-21.38.2.ipa}"
if [[ ! -s "$ipa" ]]; then
  echo "::error::IPA missing or empty. Expected: $ipa; working directory: $PWD" >&2
  echo 'Files present in artifacts:' >&2
  if [[ -d artifacts ]]; then ls -lah artifacts >&2; else echo '(no artifacts directory)' >&2; fi
  exit 1
fi
asset_name="$(basename "$ipa")"
tag="quiettube-0.14.0-rc1-${GITHUB_RUN_ID}-${GITHUB_RUN_ATTEMPT}"
server="${GITHUB_SERVER_URL:-https://github.com}"
page="${server}/${GITHUB_REPOSITORY}/releases/tag/${tag}"
download="${server}/${GITHUB_REPOSITORY}/releases/download/${tag}/${asset_name}"
notes="${RUNNER_TEMP:-.}/quiettube-release-notes.md"
cat > "$notes" <<NOTES
# QuietTube 0.14.0-rc1 — settings release candidate

**[Download the IPA directly](${download})** — no outer ZIP to extract.

Import the .ipa into LiveContainer for signing/preparation. Keep the working prior version as a fallback.

The 0.13.5 player/feed runtime is preserved; settings and presets have changed.
New-install modifications remain off until enabled. Existing preferences are preserved.
Open Quiet controls → Presets to review an optional setup. Native PiP uses YouTube's setting.
This is a release candidate, not a claim of universal blocking or native UI validation.
Unofficial; not affiliated with YouTube or Google. Publishing permission must be established separately.

Source commit: ${GITHUB_SHA}
Build: ${server}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}
NOTES
gh release create "$tag" "$ipa" --repo "$GITHUB_REPOSITORY" --target "$GITHUB_SHA" \
  --prerelease --title "QuietTube 0.14.0-rc1 — build ${GITHUB_RUN_ID}.${GITHUB_RUN_ATTEMPT}" --notes-file "$notes"
cat >> "$GITHUB_STEP_SUMMARY" <<SUMMARY
# ✅ [DOWNLOAD IPA — QuietTube 0.14.0-rc1](${download})

**This link downloads the actual .ipa file. No artifact ZIP or extraction step.**

[Open the release page / Assets](${page})

**Direct URL:** ${download}

Private repository? Sign into the GitHub account with repository access first. If the direct link fails in an in-app browser, open the release page in Safari and tap the .ipa under Assets.

Keep your working previous IPA. Import this file in LiveContainer. Validate the new settings UI before general release. Existing preferences carry over; new installs opt in. The tested player/feed logic has not been redesigned.
SUMMARY
printf '\nDOWNLOAD IPA: %s\nRELEASE PAGE: %s\n' "$download" "$page"
printf '::notice title=Download IPA::%s\n' "$download"
