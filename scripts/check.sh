#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
python3 scripts/verify_release.py
python3 -m unittest discover -s tests -v
temp="$(mktemp -d)"
trap 'rm -rf "$temp"' EXIT
for source in tests/test_feed_rules.c tests/test_template_scan.c tests/test_ad_state.c tests/test_insertion_policy.c; do
  output="$temp/$(basename "$source" .c)"
  "${CC:-cc}" -std=c11 -Wall -Wextra -Werror -fsanitize=address,undefined "$source" -o "$output"
  "$output"
done
bash -n scripts/build.sh scripts/check.sh
if [[ "$(uname -s)" == "Darwin" ]]; then
  cc -fobjc-arc -Wall -Wextra -Werror -framework Foundation Sources/QTPreferences.m tests/test_preferences.m -o "$temp/preferences"
  "$temp/preferences"
else
  echo 'Foundation preference execution skipped (requires macOS); the macOS IPA workflow runs it.'
fi
