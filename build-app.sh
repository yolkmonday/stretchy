#!/bin/bash
# Build Stretchy.app universal (arm64 + x86_64) + .dmg + .pkg di dist/.
#   VERSION            default: git tag terbaru tanpa "v"
#   SIGN_IDENTITY      Developer ID Application; kosong -> ad-hoc
#   INSTALLER_IDENTITY Developer ID Installer; kosong -> pkg unsigned (tidak dinotarisasi)
#   NOTARIZE=1         notarytool + staple. Kredensial: APPLE_ID/APPLE_PASSWORD/APPLE_TEAM_ID,
#                      kalau kosong pakai keychain profile "notary"
set -euo pipefail
cd "$(dirname "$0")"

VERSION="${VERSION:-$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || true)}"
VERSION="${VERSION:-0.0.0}"
ARCH=(--arch arm64 --arch x86_64)

swift build -c release "${ARCH[@]}"
BIN_DIR="$(swift build -c release "${ARCH[@]}" --show-bin-path)"
APP="dist/Stretchy.app"

rm -rf dist
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

notarize() {
    local auth=(--keychain-profile notary)
    [ -n "${APPLE_ID:-}" ] && auth=(--apple-id "$APPLE_ID" --password "$APPLE_PASSWORD" --team-id "$APPLE_TEAM_ID")
    local out
    out="$(xcrun notarytool submit "$1" "${auth[@]}" --wait 2>&1)" || true
    echo "$out"
    grep -q "status: Accepted" <<<"$out" || { echo "Notarisasi gagal: $1" >&2; exit 1; }
}

NOTARIZE="${NOTARIZE:-0}"
if [ "$NOTARIZE" = "1" ]; then
    ditto -c -k --keepParent "$APP" dist/notarize.zip
    notarize dist/notarize.zip
    rm dist/notarize.zip
    xcrun stapler staple "$APP"
fi

# DMG: app + shortcut Applications
DMG="dist/Stretchy-$VERSION.dmg"
STAGE="$(mktemp -d)"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"
hdiutil create -volname Stretchy -srcfolder "$STAGE" -fs HFS+ -format UDZO -ov "$DMG"
rm -rf "$STAGE"
[ -n "${SIGN_IDENTITY:-}" ] && codesign --force --timestamp -s "$SIGN_IDENTITY" "$DMG"

# PKG: install ke /Applications, jangan relocate ke salinan lain
PKG="dist/Stretchy-$VERSION.pkg"
ROOT="$(mktemp -d)"
cp -R "$APP" "$ROOT/"
pkgbuild --analyze --root "$ROOT" dist/component.plist
plutil -replace 0.BundleIsRelocatable -bool NO dist/component.plist
pkgbuild --root "$ROOT" --component-plist dist/component.plist --install-location /Applications \
    --identifier com.yolkmonday.stretchy.pkg --version "$VERSION" \
    ${INSTALLER_IDENTITY:+--sign "$INSTALLER_IDENTITY" --timestamp} "$PKG"
rm -rf "$ROOT" dist/component.plist

if [ "$NOTARIZE" = "1" ]; then
    notarize "$DMG"
    xcrun stapler staple "$DMG"
    if [ -n "${INSTALLER_IDENTITY:-}" ]; then
        notarize "$PKG"
        xcrun stapler staple "$PKG"
    fi
fi
echo "==> $APP  $DMG  $PKG"
