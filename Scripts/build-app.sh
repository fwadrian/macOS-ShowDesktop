#!/bin/zsh

set -euo pipefail

project_root="${0:A:h}/.."
cd "$project_root"

archive_path="$project_root/dist/ShowDesktop.xcarchive"
app_bundle="$project_root/dist/ShowDesktop.app"
signing_identity="${SHOWDESKTOP_SIGNING_IDENTITY:-}"
bundle_identifier="${SHOWDESKTOP_BUNDLE_IDENTIFIER:-app.showdesktop.utility}"

if [[ -z "$signing_identity" ]]; then
    echo "Error: SHOWDESKTOP_SIGNING_IDENTITY must be set." >&2
    echo "Example: SHOWDESKTOP_SIGNING_IDENTITY=\"Developer ID Application: ...\" zsh Scripts/build-app.sh" >&2
    exit 1
fi

xcodebuild \
    -project "$project_root/ShowDesktop.xcodeproj" \
    -scheme ShowDesktop \
    -configuration Release \
    -archivePath "$archive_path" \
    archive \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY= \
    DEVELOPMENT_TEAM= \
    PRODUCT_BUNDLE_IDENTIFIER="$bundle_identifier"

rm -rf "$app_bundle"
ditto "$archive_path/Products/Applications/ShowDesktop.app" "$app_bundle"
codesign --force --options runtime --timestamp --sign "$signing_identity" "$app_bundle"
codesign --verify --deep --strict "$app_bundle"
echo "Application built and signed: $app_bundle"
echo "Signing identity: $signing_identity"
