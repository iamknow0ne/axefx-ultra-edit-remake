#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Library/Developer/CommandLineTools}"
version="$(cat VERSION)"
app="${APP_PATH:-dist/Ultra Edit.app}"
python="${PACKAGING_PYTHON:-$PWD/.build/packaging-venv/bin/python}"
[[ -x "$python" ]] || { echo 'Create .build/packaging-venv and install scripts/packaging-requirements.txt first.' >&2; exit 1; }
"$python" -c 'import ds_store, mac_alias, markdown'
[[ -d "$app" ]] || { echo 'Build the application first.' >&2; exit 1; }
[[ "$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$app/Contents/Info.plist")" == "$version" ]] || { echo 'Bundle version differs from VERSION.' >&2; exit 1; }
codesign --verify --deep --strict "$app"
stage="$(mktemp -d "$PWD/.build/dmg-stage.XXXXXX")"
mount=""
rw="$stage/image-rw.dmg"
cleanup() { if [[ -n "$mount" ]]; then hdiutil detach "$mount" -quiet 2>/dev/null || true; fi; rm -rf "$stage"; }
trap cleanup EXIT
mkdir -p "$stage/content/.background"
ditto "$app" "$stage/content/Ultra Edit.app"
ln -s /Applications "$stage/content/Applications"
"$python" scripts/build-docs.py "$stage/content/Documentation"
ln -s Documentation/docs/INSTALLATION.html "$stage/content/Install Ultra Edit.html"
swift -module-cache-path "$PWD/.build/swift-cache" scripts/DMGBackground.swift "$stage/content/.background/background.png"
hdiutil create -quiet -volname "Ultra Edit Installer" -srcfolder "$stage/content" -format UDRW -fs HFS+ "$rw"
hdiutil attach -nobrowse -plist "$rw" > "$stage/attached.plist"
mount="$("$python" -c 'import plistlib,sys; p=plistlib.load(open(sys.argv[1],"rb")); print(next(e["mount-point"] for e in p["system-entities"] if "mount-point" in e))' "$stage/attached.plist")"
"$python" scripts/dmg-layout.py "$mount"
hdiutil detach -quiet "$mount"
target="dist/Ultra-Edit-$version-arm64.dmg"
[[ ! -e "$target" ]] || rm "$target"
hdiutil convert -quiet "$rw" -format UDZO -imagekey zlib-level=9 -o "$target"
hdiutil verify "$target"
tar -czf "dist/Ultra-Edit-$version-third-party-source.tar.gz" Vendor Resources/ThirdPartyNotices.txt THIRD_PARTY_NOTICES.md
(cd dist && shasum -a 256 "Ultra-Edit-$version-arm64.dmg" "Ultra-Edit-$version-arm64.zip" "Ultra-Edit-$version-third-party-source.tar.gz" > SHA256SUMS.txt)
echo "Created $target and dist/SHA256SUMS.txt"
