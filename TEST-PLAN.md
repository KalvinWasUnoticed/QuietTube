# 0.13.4 test

Build a new workflow commit; download its direct IPA release link. Tap Prepare ad test and fully stop/relaunch the LiveContainer guest. Play one video, swipe down once, wait about 12 seconds, copy Advanced → Ad test report. State whether the card appeared and whether playback regressed. No additional logging switches or full diagnostics needed.

Look for willCollapse/layoutChanged installed; the prior failures were our compact-signature normalization bug. Confirm the timing anchor's exact label. For didInsertEntries, read entry sample details: explicit ad-logging presence (or unavailable), payload size, existing-rule-mask and lexical template candidates. Do not equate a bitmask/template clue with a decoded root, nor suppress all YTIElementRenderer insertions. Detail quota, missing payload/getter and trace truncation are explicit limits.

Offline: python -m unittest discover -s tests; compile/run tests/test_{feed_rules,template_scan,ad_state}.c with GCC ASan/UBSan; bash -n scripts/build.sh scripts/release.sh; parse workflow YAML; repeat Python tests overlaid onto 0.13.3. Native compilation/runtime safety requires the Apple build/device separately.
