# RC1 packaging → publishing handoff patch

Replace these files in your existing repository (do not create a nested folder):
- .github/workflows/build.yml
- scripts/release.sh
- tests/test_release.py

If your active build workflow uses a different filename, replace that workflow's contents instead of adding a duplicate build workflow. Ensure the hidden .github folder is included.

Commit the changes and start a NEW workflow run against that commit. Re-running the failed job from an old run uses the old commit.

Packaging and publishing now share IPA_PATH. Packaging immediately checks that the expected file exists and is nonempty. Publication uses that same path and derives the download-link filename from it. Missing-file errors show the expected path, working directory and artifact directory listing. No app source, preference or runtime logic changes.

The screenshot established successful native compilation and packaging, then a missing-file error in publication. It did not reveal the actual packaged filename; filename/path mismatch is plausible, not established. These changes remove the duplicated handoff path and make any remaining failure actionable. No successful cloud release has been verified for this patch.

81 Python checks passed locally, including explicit-path upload/link and missing-path diagnostics. Shell syntax and workflow YAML checks passed. No real release was created.

If it still fails, send the expanded “Package the IPA for LiveContainer” output (especially its “Created …” line) and the final publishing step's new error. No app diagnostics are needed.
