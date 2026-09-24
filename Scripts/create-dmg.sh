#!/bin/zsh

set -euo pipefail

project_root="${0:A:h}/.."
app_bundle="$project_root/dist/ShowDesktop.app"
signing_identity="${SHOWDESKTOP_SIGNING_IDENTITY:-}"

if [[ ! -d "$app_bundle" ]]; then
    echo "Error: run zsh Scripts/build-app.sh first." >&2
    exit 1
fi

version="$(plutil -extract CFBundleShortVersionString raw "$app_bundle/Contents/Info.plist" 2>/dev/null || true)"

if [[ -z "$version" ]]; then
    echo "Error: could not read the application version." >&2
    exit 1
fi

if [[ -z "$signing_identity" ]]; then
    echo "Error: SHOWDESKTOP_SIGNING_IDENTITY must be set." >&2
    exit 1
fi

dmg_path="${SHOWDESKTOP_DMG_PATH:-$project_root/dist/ShowDesktop-$version.dmg}"
staging_path="$(mktemp -d "$project_root/dist/.dmg-staging.XXXXXX")"
trap 'rm -rf "$staging_path"' EXIT

ditto "$app_bundle" "$staging_path/ShowDesktop.app"
ln -s /Applications "$staging_path/Applications"
hdiutil create -volname ShowDesktop -srcfolder "$staging_path" -ov -format UDZO "$dmg_path"
hdiutil verify "$dmg_path"
codesign --force --timestamp --sign "$signing_identity" "$dmg_path"
codesign --verify --verbose=2 "$dmg_path"
echo "DMG created: $dmg_path"
