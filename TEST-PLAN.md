# Release-candidate acceptance

First build with unchanged existing preferences. Do not immediately apply a preset: confirm upgrade preserves the known-working configuration. Keep the previous IPA/data container for rollback.

1. Open Quiet controls. All controls have clear labels; existing settings retain their values. Back/Done stays visible.
2. Toggle several options rapidly. No modal confirmation should appear. The notice resets its three-second timeout and the footer retains pending-restart status. Toggle back to launch values; the pending state should clear.
3. Enable a cleanup option with its prerequisite off. Required matching turns on too; no alert interrupts the action. Disable extended matching deliberately; dependent selections are retained with an explanation.
4. Open a preset, review every before/after value, then back out: nothing changes. Reopen and Apply: only listed settings change; background and next-video choices are retained.
5. Restart the guest. Confirm the pending footer clears, playback and swipe-down feed-ad blocking still work, and native PiP/background, sign-in and existing cleanup have no regression. Logging-off protection should work because runtime gating did not change.
6. Check dark/light mode and large Dynamic Type, scrolling, page titles, footer and switch labels. Check Advanced → Troubleshooting support report; enabling its test preparation gives a non-modal notice.
7. Test master OFF preserves individual values. Only Disable all options clears selections, after confirmation.

Native UI/device results are pending; report any mismatch before public promotion. No repeated forced ad-test matrix is required for normal use.

Offline: python -m unittest discover -s tests; four tests/test_*.c with ASan/UBSan; bash syntax and workflow YAML parse; overlay onto 0.13.5 then rerun Python tests. Hash protection covers runtime modules and accepted integration boundaries; settings UI expectations were intentionally updated.
