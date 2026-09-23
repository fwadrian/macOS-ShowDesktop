import AppKit
import ApplicationServices
import ServiceManagement

final class AppDelegate: NSObject, NSApplicationDelegate {
    private lazy var statusItem: NSStatusItem =
        NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let windowManager = WindowManager()
    private let windowQueue = DispatchQueue(label: "ShowDesktop.windows", qos: .userInitiated)
    private var isToggling = false
    private var pendingWindowCount = 0
    private var restoreFailed = false
    private let preferences = Preferences.shared
    private var hotKeyManager: HotKeyManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        configureStatusItem()
        requestAccessibilityPermission()
        hotKeyManager = HotKeyManager(configuration: selectedHotKeyConfiguration) { [weak self] in self?.toggleDesktop() }

        if hotKeyManager?.isRegistered == false {
            NSLog("ShowDesktop: ⌥ Space shortcut is unavailable.")
        }
    }

    private func configureStatusItem() {
        guard let button = statusItem.button else { return }
        button.image = desktopImage
        button.contentTintColor = .white
        button.toolTip = "ShowDesktop — Click: minimize / restore"
        button.target = self
        button.action = #selector(statusItemClicked(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    private static let desktopImage = makeWhiteImage(
        named: "rectangle.on.rectangle.slash",
        description: "Show desktop"
    )

    private static let restoreImage = makeWhiteImage(
        named: "rectangle.stack",
        description: "Restore windows"
    )

    private static func makeWhiteImage(named name: String, description: String) -> NSImage? {
        guard let source = NSImage(systemSymbolName: name, accessibilityDescription: description),
              let image = source.withSymbolConfiguration(
                  NSImage.SymbolConfiguration(paletteColors: [.white])
              ) else {
            return nil
        }
        image.isTemplate = false
        return image
    }

    private var desktopImage: NSImage? {
        Self.desktopImage
    }

    private var restoreImage: NSImage? {
        Self.restoreImage
    }

    @objc private func statusItemClicked(_ sender: NSStatusBarButton) {
        if NSApp.currentEvent?.type == .rightMouseUp {
            showMenu()
        } else {
            toggleDesktop()
        }
    }

    private func toggleDesktop() {
        guard !isToggling else { return }
        isToggling = true
        guard AXIsProcessTrusted() else {
            defer { isToggling = false }
            requestAccessibilityPermission()
            showPermissionAlert()
            return
        }

        let restoring = pendingWindowCount > 0
        let applications = NSWorkspace.shared.runningApplications
        let exclusions = preferences.excludedBundleIdentifiers
        statusItem.button?.toolTip = "ShowDesktop — Operation in progress…"
        windowQueue.async { [self] in
            let result = restoring
                ? windowManager.restoreWindows()
                : windowManager.minimizeAllWindows(applications: applications, excludedBundleIdentifiers: exclusions)
            DispatchQueue.main.async { [self] in
                pendingWindowCount = result.pending
                restoreFailed = restoring && result.failed > 0
                isToggling = false
                statusItem.button?.image = result.pending > 0 ? restoreImage : desktopImage
                if restoring {
                    statusItem.button?.toolTip = "ShowDesktop — \(result.succeeded) restored, \(result.alreadyOpen) already open, \(result.unavailable) no longer available, \(result.failed) pending"
                    if restoreFailed {
                        statusItem.button?.toolTip = (statusItem.button?.toolTip ?? "") + "; click to retry or reset the list from the context menu"
                    }
                } else {
                    statusItem.button?.toolTip = "ShowDesktop — \(result.succeeded) minimized, \(result.failed) failed"
                }
            }
        }
    }

    @objc private func resetRestoreList() {
        guard !isToggling, pendingWindowCount > 0 else { return }
        isToggling = true
        let alert = NSAlert()
        alert.messageText = "Reset the restore list?"
        alert.informativeText = "The \(pendingWindowCount) pending window(s) will not be restored automatically. You can open remaining windows from the Dock. The next click starts a new minimize operation."
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Reset List")
        guard presentAlert(alert) == .alertSecondButtonReturn else {
            isToggling = false
            return
        }
        windowQueue.async { [self] in
            windowManager.discardStoredWindows()
            DispatchQueue.main.async { [self] in
                pendingWindowCount = 0
                restoreFailed = false
                isToggling = false
                statusItem.button?.image = desktopImage
                statusItem.button?.toolTip = "ShowDesktop — List reset; click to minimize"
            }
        }
    }

    @discardableResult
    private func presentAlert(_ alert: NSAlert) -> NSApplication.ModalResponse {
        NSApp.activate(ignoringOtherApps: true)
        return alert.runModal()
    }

    private func requestAccessibilityPermission() {
        let options = [
            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true
        ] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }

    private func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility permission required"
        alert.informativeText = "Allow ShowDesktop to control windows in System Settings > Privacy & Security > Accessibility."
        alert.addButton(withTitle: "Open Settings")
        alert.addButton(withTitle: "Cancel")

        if presentAlert(alert) == .alertFirstButtonReturn {
            openAccessibilitySettings()
        }
    }

    private func showMenu() {
        let menu = NSMenu()
        menu.autoenablesItems = false
        let permissionText = AXIsProcessTrusted()
            ? "Accessibility: Enabled"
            : "Accessibility: Disabled"
        let permissionItem = NSMenuItem(title: permissionText, action: nil, keyEquivalent: "")
        permissionItem.isEnabled = false
        menu.addItem(permissionItem)

        let toggleItem = NSMenuItem(
            title: "Minimize / restore windows",
            action: #selector(menuToggle),
            keyEquivalent: ""
        )
        toggleItem.isEnabled = !isToggling
        toggleItem.target = self
        menu.addItem(toggleItem)
        if pendingWindowCount > 0 {
            let resetItem = NSMenuItem(title: "Reset restore list…", action: #selector(resetRestoreList), keyEquivalent: "")
            resetItem.target = self
            resetItem.isEnabled = !isToggling
            menu.addItem(resetItem)
        }

        let excludedAppsItem = NSMenuItem(title: "Excluded applications", action: nil, keyEquivalent: "")
        excludedAppsItem.submenu = makeExcludedAppsMenu()
        menu.addItem(excludedAppsItem)

        let hotKeyItem = NSMenuItem(title: "Keyboard shortcut", action: nil, keyEquivalent: "")
        hotKeyItem.submenu = makeHotKeyMenu()
        menu.addItem(hotKeyItem)

        let launchAtLoginItem = NSMenuItem(
            title: "Launch at login",
            action: #selector(toggleLaunchAtLogin(_:)),
            keyEquivalent: ""
        )
        launchAtLoginItem.target = self
        launchAtLoginItem.state = launchAtLoginEnabled ? .on : .off
        menu.addItem(launchAtLoginItem)

        let settingsItem = NSMenuItem(
            title: "Open Accessibility settings",
            action: #selector(openAccessibilitySettings),
            keyEquivalent: ""
        )
        settingsItem.target = self
        menu.addItem(settingsItem)
        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "Quit ShowDesktop",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    private func makeExcludedAppsMenu() -> NSMenu {
        let submenu = NSMenu()
        let ownPID = ProcessInfo.processInfo.processIdentifier
        let apps = NSWorkspace.shared.runningApplications
            .filter {
                $0.processIdentifier != ownPID &&
                $0.activationPolicy == .regular &&
                !$0.isHidden &&
                $0.bundleIdentifier != nil
            }
            .sorted {
                ($0.localizedName ?? $0.bundleIdentifier ?? "") <
                ($1.localizedName ?? $1.bundleIdentifier ?? "")
            }

        let appNamesByBundleIdentifier = apps.reduce(into: [String: String]()) { names, app in
            guard let bundleIdentifier = app.bundleIdentifier else { return }
            if names[bundleIdentifier] == nil {
                names[bundleIdentifier] = app.localizedName ?? bundleIdentifier
            }
        }
        let bundleIdentifiers = Set(appNamesByBundleIdentifier.keys)
            .union(preferences.excludedBundleIdentifiers)
            .sorted { (appNamesByBundleIdentifier[$0] ?? $0) < (appNamesByBundleIdentifier[$1] ?? $1) }

        if bundleIdentifiers.isEmpty {
            let emptyItem = NSMenuItem(title: "No running applications", action: nil, keyEquivalent: "")
            emptyItem.isEnabled = false
            submenu.addItem(emptyItem)
            return submenu
        }

        for bundleIdentifier in bundleIdentifiers {
            let item = NSMenuItem(
                title: appNamesByBundleIdentifier[bundleIdentifier] ?? bundleIdentifier,
                action: #selector(toggleExcludedApp(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = bundleIdentifier
            item.state = preferences.excludedBundleIdentifiers.contains(bundleIdentifier)
                ? NSControl.StateValue.on
                : NSControl.StateValue.off
            submenu.addItem(item)
        }

        return submenu
    }

    private var launchAtLoginEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    private var selectedHotKeyConfiguration: HotKeyConfiguration {
        preferences.hotKeyConfiguration
    }

    private func makeHotKeyMenu() -> NSMenu {
        let submenu = NSMenu()
        let selectedID = selectedHotKeyConfiguration.id

        for configuration in HotKeyConfiguration.presets {
            let item = NSMenuItem(
                title: configuration.title,
                action: #selector(selectHotKey(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = configuration.id
            item.state = configuration.id == selectedID ? .on : .off
            submenu.addItem(item)
        }

        return submenu
    }

    @objc private func selectHotKey(_ sender: NSMenuItem) {
        guard let id = sender.representedObject as? String,
              let configuration = HotKeyConfiguration.presets.first(where: { $0.id == id }),
              let hotKeyManager else { return }

        guard hotKeyManager.update(to: configuration) else {
            showHotKeyRegistrationError(configuration)
            return
        }
        preferences.setHotKeyConfiguration(configuration)
    }

    private func showHotKeyRegistrationError(_ configuration: HotKeyConfiguration) {
        let alert = NSAlert()
        alert.messageText = "Shortcut unavailable"
        alert.informativeText = "\(configuration.title) may already be used by another application or macOS. The previous shortcut has been kept."
        alert.addButton(withTitle: "OK")
        presentAlert(alert)
    }

    @objc private func toggleLaunchAtLogin(_ sender: NSMenuItem) {
        do {
            if launchAtLoginEnabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            NSLog("ShowDesktop: could not change launch-at-login setting: %@", error.localizedDescription)
            showLaunchAtLoginError(error)
        }
    }

    private func showLaunchAtLoginError(_ error: Error) {
        let alert = NSAlert()
        alert.messageText = "Could not configure launch at login"
        alert.informativeText = "macOS could not change whether ShowDesktop starts at login: \(error.localizedDescription)"
        alert.addButton(withTitle: "OK")
        presentAlert(alert)
    }

    @objc private func toggleExcludedApp(_ sender: NSMenuItem) {
        guard let bundleIdentifier = sender.representedObject as? String else { return }
        var updated = preferences.excludedBundleIdentifiers
        if updated.contains(bundleIdentifier) {
            updated.remove(bundleIdentifier)
        } else {
            updated.insert(bundleIdentifier)
        }
        preferences.excludedBundleIdentifiers = updated
    }

    @objc private func menuToggle() { toggleDesktop() }

    @objc private func openAccessibilitySettings() {
        guard let url = URL(
            string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        ) else { return }
        NSWorkspace.shared.open(url)
    }

    @objc private func quit() { NSApp.terminate(nil) }
}
