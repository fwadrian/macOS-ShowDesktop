# Releasing ShowDesktop

1. Update `CFBundleShortVersionString` and `CFBundleVersion` in `Resources/Info.plist`.
2. Run the test suite with `swift test`.
3. Build the signed universal application:

   ```sh
   SHOWDESKTOP_SIGNING_IDENTITY="Developer ID Application: <certificate name> (<team ID>)" \
   zsh Scripts/build-app.sh
   ```

4. Notarize, staple, and verify the application and DMG:

   ```sh
   SHOWDESKTOP_SIGNING_IDENTITY="Developer ID Application: <certificate name> (<team ID>)" \
   SHOWDESKTOP_NOTARY_PROFILE="ShowDesktopNotary" \
   zsh Scripts/notarize-app.sh
   ```

5. Replace the matching entry in `SHA256SUMS` with the digest printed by the script.
6. Commit the release metadata and create an annotated version tag on that commit.
7. Publish the matching `dist/ShowDesktop-<version>.dmg` and include its SHA-256 digest in the release notes.

The Keychain profile and signing credentials must remain outside the repository.
