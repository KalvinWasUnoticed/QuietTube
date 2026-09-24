# Changelog

## 1.0.0

First source-first public release package.

- Retains the tested native player protection, scoped marked-feed insertion filter, accepted feed cleanup, classic logo and native settings integration.
- Keeps Google sign-in and native PiP behavior; background audio remains optional.
- Groups settings into Ads, Feed, Playback, Appearance and Advanced, with preview-before-Apply presets and non-modal restart notices.
- Preserves existing preferences and requires explicit opt-in on new installs.
- Makes the public workflow manual and library-only: fork → enable Actions → build QuietTube. No hosted base URL, YouTube download, cloud IPA packaging or public IPA release automation.
- Adds concise source-first installation, privacy and support documentation with real settings screenshots.
- Removes retired source stubs, unused hook research/disassembly, iterative docs, obsolete ABI records and old release scripts/tests. Active checks and required license notices remain.

Runtime/settings behavior was tested in the preceding 0.13.5/RC1 builds by the maintainer on iPhone 14, iOS 26.5 and LiveContainer 3.8.0 with the pinned YouTube 21.38.2 base. The 1.0.0 library workflow and local packaging route still require a fresh native end-to-end acceptance run; source tests are not that evidence.
