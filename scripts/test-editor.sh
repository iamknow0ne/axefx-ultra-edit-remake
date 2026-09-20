#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Library/Developer/CommandLineTools}"
export CLANG_MODULE_CACHE_PATH="$PWD/.build/clang-cache"
swift build -c release --target UltraCore --disable-sandbox --cache-path "$PWD/.build/spm-cache" -Xswiftc -module-cache-path -Xswiftc "$PWD/.build/swift-cache"
swiftc -D EDITOR_TESTS -module-cache-path "$PWD/.build/swift-cache" -I .build/release/Modules .build/release/UltraCore.build/*.swift.o Sources/UltraEdit/EditorModel.swift Sources/UltraEdit/GridModel.swift Sources/UltraEdit/DeviceLibraryModel.swift Sources/UltraEdit/LibraryNavigationModel.swift Sources/UltraEdit/LibraryWorkspaceModel.swift Sources/UltraEdit/LiveHistoryModel.swift Sources/UltraEdit/GridKeyboardModel.swift Sources/UltraEdit/PerformanceModel.swift Sources/UltraEdit/ModifierWorkspaceModel.swift Sources/UltraEdit/UserCabModel.swift Sources/UltraEdit/GlobalControlsModel.swift Sources/UltraEdit/ProductivityModel.swift Sources/UltraEdit/CabinetLab.swift Sources/UltraEdit/DeviceArtwork.swift Tests/Standalone/EditorChecks.swift -o .build/editor-checks
.build/editor-checks
