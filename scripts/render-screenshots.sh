#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Library/Developer/CommandLineTools}"
export CLANG_MODULE_CACHE_PATH="$PWD/.build/clang-cache"
swift build -c release --target UltraCore --disable-sandbox --cache-path "$PWD/.build/spm-cache" -Xswiftc -module-cache-path -Xswiftc "$PWD/.build/swift-cache"
sources=()
for source in Sources/UltraEdit/*.swift; do
  [[ "$source" == */UltraEditApp.swift ]] || sources+=("$source")
done
swiftc -module-cache-path "$PWD/.build/swift-cache" -I .build/release/Modules .build/release/UltraCore.build/*.swift.o "${sources[@]}" scripts/RenderScreenshots.swift -o .build/render-screenshots
.build/render-screenshots
