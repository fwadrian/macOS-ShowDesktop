#!/bin/zsh

set -euo pipefail

project_root="${0:A:h}/.."
cd "$project_root"

swift build -c release --product ShowDesktop
binary_path="$(swift build -c release --show-bin-path)/ShowDesktop"
app_bundle="$project_root/dist/ShowDesktop.app"
signing_identity="${SHOWDESKTOP_SIGNING_IDENTITY:-}"
bundle_identifier="${SHOWDESKTOP_BUNDLE_IDENTIFIER:-com.example.ShowDesktop}"

if [[ -z "$signing_identity" ]]; then
    echo "Hata: SHOWDESKTOP_SIGNING_IDENTITY ortam değişkeni ayarlanmalı." >&2
    echo "Örnek: SHOWDESKTOP_SIGNING_IDENTITY=\"Developer ID Application: ...\" zsh Scripts/build-app.sh" >&2
    exit 1
fi

mkdir -p "$app_bundle/Contents/MacOS" "$app_bundle/Contents/Resources"
cp "$binary_path" "$app_bundle/Contents/MacOS/ShowDesktop"
# Remove compiler debug paths before signing a public distribution.
xcrun strip -S "$app_bundle/Contents/MacOS/ShowDesktop"
cp "$project_root/Resources/Info.plist" "$app_bundle/Contents/Info.plist"
cp "$project_root/Resources/AppIconSource.png" "$app_bundle/Contents/Resources/AppIcon.png"
plutil -replace CFBundleIdentifier -string "$bundle_identifier" "$app_bundle/Contents/Info.plist"

# This bundle contains a single executable; sign the outer bundle directly.
# Apple advises against --deep during signing because it can mask nested-signature issues.
codesign --force --options runtime --timestamp --sign "$signing_identity" "$app_bundle"
echo "Uygulama oluşturuldu: $app_bundle"
echo "İmzalama kimliği: $signing_identity"
