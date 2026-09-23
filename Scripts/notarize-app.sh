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

ditto -c -k --keepParent "$app_bundle" "$archive_path"
xcrun notarytool submit "$archive_path" --keychain-profile "$keychain_profile" --wait
xcrun stapler staple "$app_bundle"
xcrun stapler validate "$app_bundle"
spctl --assess --type execute --verbose=2 "$app_bundle"

echo "Notarization complete: $app_bundle"
