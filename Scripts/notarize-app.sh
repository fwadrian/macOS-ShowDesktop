#!/bin/zsh

set -euo pipefail

project_root="${0:A:h}/.."
app_bundle="$project_root/dist/ShowDesktop.app"
archive_path="$project_root/dist/ShowDesktop.zip"
keychain_profile="${SHOWDESKTOP_NOTARY_PROFILE:-ShowDesktopNotary}"

if [[ ! -d "$app_bundle" ]]; then
    echo "Error: run zsh Scripts/build-app.sh first." >&2
    exit 1
fi

version="$(plutil -extract CFBundleShortVersionString raw "$app_bundle/Contents/Info.plist" 2>/dev/null || true)"

if [[ -z "$version" ]]; then
    echo "Error: could not read the application version." >&2
    exit 1
fi

dmg_path="${SHOWDESKTOP_DMG_PATH:-$project_root/dist/ShowDesktop-$version.dmg}"

ditto -c -k --keepParent "$app_bundle" "$archive_path"
xcrun notarytool submit "$archive_path" --keychain-profile "$keychain_profile" --wait
xcrun stapler staple "$app_bundle"
xcrun stapler validate "$app_bundle"
spctl --assess --type execute --verbose=4 "$app_bundle"

SHOWDESKTOP_DMG_PATH="$dmg_path" zsh "$project_root/Scripts/create-dmg.sh"
xcrun notarytool submit "$dmg_path" --keychain-profile "$keychain_profile" --wait
xcrun stapler staple "$dmg_path"
xcrun stapler validate "$dmg_path"
spctl --assess --type open --context context:primary-signature --verbose=4 "$dmg_path"
shasum -a 256 "$dmg_path"

echo "Notarization complete: $app_bundle"
echo "Release DMG ready: $dmg_path"
