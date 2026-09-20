#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Library/Developer/CommandLineTools}"
export CLANG_MODULE_CACHE_PATH="$PWD/.build/clang-cache"
mkdir -p .build/swift-cache
swiftc -D STANDALONE -module-cache-path "$PWD/.build/swift-cache" Sources/UltraCore/*.swift Tests/UltraCoreTests/*.swift Tests/Standalone/Runner.swift -o .build/ultra-checks
.build/ultra-checks
