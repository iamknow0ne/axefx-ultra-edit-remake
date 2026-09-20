#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
export DEVELOPER_DIR=/Library/Developer/CommandLineTools
cmake -S tools -B .build/nam -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_SYSROOT="$(xcrun --show-sdk-path)" -DCMAKE_CXX_COMPILER="$(xcrun --find clang++)" -DCMAKE_C_COMPILER="$(xcrun --find clang)" -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_OSX_DEPLOYMENT_TARGET=13.0
cmake --build .build/nam -j 4
