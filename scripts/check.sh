#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
python3 scripts/verify_release.py
python3 -m unittest discover -s tests -v
temp="$(mktemp -d)"
trap 'rm -rf "$temp"' EXIT
for source in tests/test_feed_rules.c tests/test_template_scan.c tests/test_ad_state.c tests/test_insertion_policy.c tests/test_stress.c tests/test_diagnostic_policy.c; do
  output="$temp/$(basename "$source" .c)"
  "${CC:-cc}" -std=c11 -Wall -Wextra -Werror -fsanitize=address,undefined "$source" -o "$output"
  "$output"
done
bash -n scripts/build.sh scripts/check.sh
if [[ "$(uname -s)" == "Darwin" ]]; then
  python3 scripts/test_native.py
else
  echo 'Native Foundation logger/observer/settings/preference tests skipped (requires macOS); macOS CI runs them.'
fi
