#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Library/Developer/CommandLineTools}"
export CLANG_MODULE_CACHE_PATH="$PWD/.build/clang-cache"
mkdir -p .build/clang-cache .build/swift-cache
./scripts/build-nam.sh
swift build -c release --disable-sandbox --cache-path "$PWD/.build/spm-cache" -Xswiftc -module-cache-path -Xswiftc "$PWD/.build/swift-cache"
version="$(cat VERSION)"
app="${APP_PATH:-dist/Ultra Edit.app}"
identity="${SIGN_IDENTITY:--}"
sign_bundle() {
  if [[ "$identity" == "-" ]]; then
    codesign --force --sign - "$1"
  else
    codesign --force --sign "$identity" --options runtime --timestamp "$1"
  fi
}
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
cp .build/nam/nam-ir "$app/Contents/MacOS/nam-ir"
sign_bundle "$app/Contents/MacOS/nam-ir"
cp Vendor/NeuralAmpModelerCore/LICENSE "$app/Contents/Resources/NAM-LICENSE.txt"
cp .build/release/UltraEdit "$app/Contents/MacOS/UltraEdit"
cp Resources/UltraEdit.icns "$app/Contents/Resources/UltraEdit.icns"
cp Resources/ThirdPartyNotices.txt "$app/Contents/Resources/ThirdPartyNotices.txt"
cp Resources/UltraCatalog.json "$app/Contents/Resources/UltraCatalog.json"
cat > "$app/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleName</key><string>Ultra Edit</string>
<key>CFBundleDisplayName</key><string>Ultra Edit</string>
<key>CFBundleIdentifier</key><string>tech.hostin.ultra-edit</string>
<key>CFBundleExecutable</key><string>UltraEdit</string>
<key>CFBundleIconFile</key><string>UltraEdit</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>$version</string>
<key>CFBundleVersion</key><string>6</string>
<key>LSMinimumSystemVersion</key><string>13.0</string>
<key>NSHighResolutionCapable</key><true/>
<key>NSHumanReadableCopyright</key><string>Independent native editor. Not affiliated with Fractal Audio Systems.</string>
</dict></plist>
PLIST
sign_bundle "$app"
codesign --verify --deep --strict "$app"
/usr/bin/ditto -c -k --sequesterRsrc --keepParent "$app" "dist/Ultra-Edit-$version-arm64.zip"
file "$app/Contents/MacOS/UltraEdit"
