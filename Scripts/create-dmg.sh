#!/bin/zsh

set -euo pipefail

project_root="${0:A:h}/.."
app_bundle="$project_root/dist/ShowDesktop.app"
dmg_path="${SHOWDESKTOP_DMG_PATH:-$project_root/dist/ShowDesktop-0.1.1.dmg}"
staging_path="$project_root/dist/.dmg-staging"

if [[ ! -d "$app_bundle" ]]; then
    echo "Error: run zsh Scripts/build-app.sh first." >&2
    exit 1
fi

rm -rf "$staging_path"
mkdir -p "$staging_path"
ditto "$app_bundle" "$staging_path/ShowDesktop.app"
ln -s /Applications "$staging_path/Applications"
hdiutil create -volname ShowDesktop -srcfolder "$staging_path" -ov -format UDZO "$dmg_path"
hdiutil verify "$dmg_path"
rm -rf "$staging_path"
echo "DMG created: $dmg_path"
