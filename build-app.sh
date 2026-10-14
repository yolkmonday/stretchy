#!/bin/bash
# Build Stretchy.app universal (arm64 + x86_64) di dist/.
#   VERSION        default: git tag terbaru tanpa "v"
#   SIGN_IDENTITY  Developer ID; kosong -> ad-hoc
#   NOTARIZE=1     notarytool (keychain profile "notary") + staple
set -euo pipefail
cd "$(dirname "$0")"

VERSION="${VERSION:-$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || true)}"
VERSION="${VERSION:-0.0.0}"
ARCH=(--arch arm64 --arch x86_64)

swift build -c release "${ARCH[@]}"
BIN_DIR="$(swift build -c release "${ARCH[@]}" --show-bin-path)"
APP="dist/Stretchy.app"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN_DIR/Stretchy" "$APP/Contents/MacOS/"
cp -R "$BIN_DIR"/*.bundle "$APP/Contents/Resources/"
cp Resources/AppIcon.icns "$APP/Contents/Resources/"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key><string>Stretchy</string>
    <key>CFBundleIdentifier</key><string>com.yolkmonday.stretchy</string>
    <key>CFBundleVersion</key><string>${VERSION}</string>
    <key>CFBundleShortVersionString</key><string>${VERSION}</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleExecutable</key><string>Stretchy</string>
    <key>CFBundleIconFile</key><string>AppIcon</string>
    <key>CFBundleLocalizations</key><array><string>en</string><string>id</string></array>
    <key>LSMinimumSystemVersion</key><string>14.0</string>
    <key>LSUIElement</key><true/>
    <key>LSMultipleInstancesProhibited</key><true/>
</dict>
</plist>
PLIST

if [ -n "${SIGN_IDENTITY:-}" ]; then
    codesign --force --options runtime --timestamp -s "$SIGN_IDENTITY" "$APP"
else
    codesign --force --deep -s - "$APP"
fi
codesign --verify --deep --strict "$APP"

ZIP="dist/Stretchy-$VERSION.zip"
ditto -c -k --keepParent "$APP" "$ZIP"
if [ "${NOTARIZE:-0}" = "1" ]; then
    OUT="$(xcrun notarytool submit "$ZIP" --keychain-profile notary --wait 2>&1)"
    echo "$OUT"
    grep -q "status: Accepted" <<<"$OUT" || { echo "Notarisasi gagal" >&2; exit 1; }
    xcrun stapler staple "$APP"
    rm "$ZIP"
    ditto -c -k --keepParent "$APP" "$ZIP"
fi
echo "==> $APP  ($ZIP)"
