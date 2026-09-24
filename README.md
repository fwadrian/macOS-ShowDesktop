# ShowDesktop

ShowDesktop is a lightweight macOS menu bar utility that minimizes open application windows to the Dock with one click or the `Option-Space` shortcut. The next activation restores only the windows minimized by ShowDesktop, while leaving windows already minimized by the user untouched.

## Requirements

- macOS 13 or later
- Apple Silicon or Intel Mac for the prebuilt universal package
- Xcode 15 or later to build from source
- Accessibility permission for window management

## Release Status

Version 0.1.2 is a Developer ID-signed and Apple-notarized universal release for Apple Silicon and Intel Macs. Core minimize and restore behavior, shortcut handling, protection of already minimized windows, restoring a window opened from the Dock, and continuing after an application closes have been tested successfully. Ten automated tests pass.

## Installation

Move ShowDesktop from the published DMG to the Applications folder. Quit any running version from the context menu before updating, then open the new version. If prompted, enable Accessibility permission in System Settings > Privacy & Security > Accessibility.

## Privacy

The application has no account system, advertising, analytics, or in-app network requests. It uses the macOS Accessibility API to manage windows. Excluded applications and shortcut preferences are stored locally in UserDefaults. Error logs may include application names, bundle identifiers, and error codes in the local system log.

## Known Limitations

- Full-screen or non-minimizable custom windows may be unaffected.
- The restore list is lost when ShowDesktop quits; windows can still be opened from the Dock.
- Toggle requests received while an operation is running are ignored.
- Failed restores remain pending for another attempt until the list is explicitly reset.
- The prebuilt package is universal; Intel and every supported macOS version have not been independently verified.
- This distribution is not a Mac App Store release.

## Development

Open `Package.swift` in Xcode, select the `ShowDesktop` target and `My Mac`, then press `Command-R` to run it.

The first launch may require Accessibility permission in System Settings > Privacy & Security > Accessibility.

## Usage

- Left-click the menu bar icon to minimize or restore windows.
- Press `Option-Space` to run the same toggle.
- Right-click the icon to open the management menu.

The menu provides excluded applications, shortcut selection, and launch-at-login settings.

## Testing

```sh
swift test
```

Manual window behavior testing requires macOS Accessibility permission.

## Release Build

Create a signed release application by providing your Developer ID identity through an environment variable:

```sh
SHOWDESKTOP_SIGNING_IDENTITY="Developer ID Application: ..." \
SHOWDESKTOP_BUNDLE_IDENTIFIER="app.showdesktop.utility" \
zsh Scripts/build-app.sh
```

Create, notarize, staple, and verify the application and release DMG:

```sh
SHOWDESKTOP_SIGNING_IDENTITY="Developer ID Application: ..." \
SHOWDESKTOP_NOTARY_PROFILE="ShowDesktopNotary" \
zsh Scripts/notarize-app.sh
```

Published releases include a SHA-256 digest in their release notes. Verify a download with `shasum -a 256 ShowDesktop-*.dmg` before opening it.

Never add signing or notarization credentials to project files. Store them in the macOS Keychain or a secure CI secret store.

## Project Structure

- `Sources/ShowDesktop/`: application source code
- `Tests/ShowDesktopTests/`: automated tests
- `Resources/`: application bundle resources and icon
- `Scripts/`: build and release scripts

## License

This project is licensed under the [MIT License](LICENSE).
