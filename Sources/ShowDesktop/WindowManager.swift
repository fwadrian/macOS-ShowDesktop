import AppKit
import ApplicationServices

struct OperationResult {
    var succeeded = 0
    var failed = 0
    var alreadyOpen = 0
    var unavailable = 0
    var pending = 0
}

final class WindowManager {
    private struct StoredWindow {
        let element: AXUIElement
        let processIdentifier: pid_t
        let applicationName: String
    }

    private var minimizedWindows = RestorationTracker<StoredWindow>()

    private let messagingTimeout: Float = 1.0

    func discardStoredWindows() {
        minimizedWindows.discard()
    }

    func minimizeAllWindows(applications: [NSRunningApplication], excludedBundleIdentifiers: Set<String>) -> OperationResult {
        var summary = OperationResult()
        let ownPID = ProcessInfo.processInfo.processIdentifier

        for app in applications {
            guard app.processIdentifier != ownPID,
                  app.activationPolicy == .regular,
                  !app.isHidden,
                  let bundleIdentifier = app.bundleIdentifier,
                  !excludedBundleIdentifiers.contains(bundleIdentifier) else { continue }

            let appElement = AXUIElementCreateApplication(app.processIdentifier)
            AXUIElementSetMessagingTimeout(appElement, messagingTimeout)
            var value: CFTypeRef?
            let result = AXUIElementCopyAttributeValue(
                appElement,
                kAXWindowsAttribute as CFString,
                &value
            )

            guard result == .success, let windowArray = value as? NSArray else { continue }

            for case let window as AXUIElement in windowArray {
                AXUIElementSetMessagingTimeout(window, messagingTimeout)
                guard let minimized = isMinimized(window), !minimized,
                      canMinimize(window) else { continue }

                let result = AXUIElementSetAttributeValue(
                    window,
                    kAXMinimizedAttribute as CFString,
                    kCFBooleanTrue
                )
                if result == .success {
                    minimizedWindows.store(
                        StoredWindow(
                            element: window,
                            processIdentifier: app.processIdentifier,
                            applicationName: app.localizedName ?? bundleIdentifier
                        )
                    )
                    summary.succeeded += 1
                } else {
                    summary.failed += 1
                    NSLog(
                        "ShowDesktop: could not minimize a window in %@ (%@) (AXError: %d)",
                        app.localizedName ?? "Unknown application",
                        bundleIdentifier,
                        result.rawValue
                    )
                }
            }
        }
        summary.pending = minimizedWindows.count
        return summary
    }

    func restoreWindows() -> OperationResult {
        minimizedWindows.restore { storedWindow in
            guard let application = NSRunningApplication(processIdentifier: storedWindow.processIdentifier),
                  !application.isTerminated else { return .unavailable }

            if isMinimized(storedWindow.element) == false { return .alreadyOpen }
            let result = AXUIElementSetAttributeValue(
                storedWindow.element,
                kAXMinimizedAttribute as CFString,
                kCFBooleanFalse
            )
            if result == .invalidUIElement || result == .noValue { return .unavailable }
            if result == .success { return .restored }
            NSLog("ShowDesktop: could not restore a window in %@ (AXError: %d)",
                  storedWindow.applicationName, result.rawValue)
            return .failed
        }
    }

    private func canMinimize(_ window: AXUIElement) -> Bool {
        var settable = DarwinBoolean(false)
        let result = AXUIElementIsAttributeSettable(
            window,
            kAXMinimizedAttribute as CFString,
            &settable
        )
        return result == .success && settable.boolValue
    }

    private func isMinimized(_ window: AXUIElement) -> Bool? {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(
            window,
            kAXMinimizedAttribute as CFString,
            &value
        )
        guard result == .success, let isMinimized = value as? Bool else { return nil }
        return isMinimized
    }
}
