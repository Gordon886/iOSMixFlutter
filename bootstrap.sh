#!/bin/zsh
set -euo pipefail

root="$(cd "$(dirname "$0")" && pwd)"

echo "→ flutter pub get"
(cd "$root/flutter" && flutter pub get)

echo "→ pod install"
(cd "$root" && pod install)

echo "完成。用 Xcode 打开 ios/App.xcworkspace"
