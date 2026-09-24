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
ipa='artifacts/QuietTube-0.9.1-21.38.2.ipa'
[[ -s "$ipa" ]] || { echo 'IPA missing or empty' >&2; exit 1; }
tag="quiettube-0.9.1-${GITHUB_RUN_ID}-${GITHUB_RUN_ATTEMPT}"
server="${GITHUB_SERVER_URL:-https://github.com}"
page="${server}/${GITHUB_REPOSITORY}/releases/tag/${tag}"
download="${server}/${GITHUB_REPOSITORY}/releases/download/${tag}/QuietTube-0.9.1-21.38.2.ipa"
notes="${RUNNER_TEMP:-.}/quiettube-release-notes.md"
cat > "$notes" <<NOTES
# QuietTube 0.9.1 — personal LiveContainer test build

**[Download the IPA directly](${download})** — no outer ZIP to extract.

Import the .ipa into LiveContainer for signing/preparation. Keep the working prior version as a fallback.

Experimental feed rules and logo hooks: successful compilation is not device validation.
In-video ad blocking remains paused. Native PiP uses YouTube's setting.

Source commit: ${GITHUB_SHA}
Build: ${server}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}
NOTES
gh release create "$tag" "$ipa" --repo "$GITHUB_REPOSITORY" --target "$GITHUB_SHA" \
  --prerelease --title "QuietTube 0.9.1 — build ${GITHUB_RUN_ID}.${GITHUB_RUN_ATTEMPT}" --notes-file "$notes"
cat >> "$GITHUB_STEP_SUMMARY" <<SUMMARY
# ✅ [DOWNLOAD IPA — QuietTube 0.9.1](${download})

**This link downloads the actual .ipa file. No artifact ZIP or extraction step.**

[Open the release page / Assets](${page})

**Direct URL:** ${download}

Private repository? Sign into the GitHub account with repository access first. If the direct link fails in an in-app browser, open the release page in Safari and tap the .ipa under Assets.

Keep your working previous IPA. Import this file in LiveContainer. The new matching rules and logo behavior still need device testing; no in-video ad blocking is enabled.
SUMMARY
printf '\nDOWNLOAD IPA: %s\nRELEASE PAGE: %s\n' "$download" "$page"
printf '::notice title=Download IPA::%s\n' "$download"
