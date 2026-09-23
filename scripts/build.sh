#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p artifacts
sdk="$(xcrun --sdk iphoneos --show-sdk-path)"
xcrun --sdk iphoneos clang -arch arm64 -isysroot "$sdk" \
  -miphoneos-version-min=17.0 -dynamiclib -fobjc-arc -fblocks \
  -O2 -Wall -Wextra -Wno-unused-parameter \
  -install_name '@rpath/QuietTube.dylib' \
  -framework Foundation -framework UIKit \
  Sources/QTCore.m Sources/QTSettings.m Sources/QTFeatures.m \
  -o artifacts/QuietTube.dylib
codesign --force --sign - artifacts/QuietTube.dylib
file artifacts/QuietTube.dylib
