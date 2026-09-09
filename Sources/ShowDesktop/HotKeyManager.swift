import Carbon

struct HotKeyConfiguration: Equatable {
    let id: String
    let title: String
    let keyCode: UInt32
    let modifiers: UInt32

    static let defaultPreset = HotKeyConfiguration(id: "option-space", title: "⌥ Space", keyCode: UInt32(kVK_Space), modifiers: UInt32(optionKey))

    static let presets = [
        defaultPreset,
        HotKeyConfiguration(id: "control-space", title: "⌃ Space", keyCode: UInt32(kVK_Space), modifiers: UInt32(controlKey)),
        HotKeyConfiguration(id: "option-d", title: "⌥ D", keyCode: UInt32(kVK_ANSI_D), modifiers: UInt32(optionKey))
    ]
}

final class HotKeyManager {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private let action: () -> Void
    private var currentConfiguration: HotKeyConfiguration?

    private(set) var isRegistered = false

    init(configuration: HotKeyConfiguration, action: @escaping () -> Void) {
        self.action = action

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let handlerStatus = InstallEventHandler(
            GetApplicationEventTarget(),
            { _, _, userData -> OSStatus in
                guard let userData else { return noErr }
                // AppDelegate manager'ı yaşam boyu güçlü tuttuğu için burada
                // unretained erişim güvenlidir; deinit handler'ı önce kaldırır.
                let manager = Unmanaged<HotKeyManager>
                    .fromOpaque(userData)
                    .takeUnretainedValue()
                DispatchQueue.main.async { manager.action() }
                return noErr
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandler
        )

        guard handlerStatus == noErr else {
            NSLog("ShowDesktop: global event handler kurulamadı (OSStatus: %d)", handlerStatus)
            return
        }

        _ = register(configuration)
    }

    @discardableResult
    func update(to configuration: HotKeyConfiguration) -> Bool {
        let previousConfiguration = currentConfiguration
        unregisterHotKey()
        if register(configuration) { return true }

        NSLog("ShowDesktop: yeni kısayol kaydolmadı; önceki kısayol geri yükleniyor.")
        if let previousConfiguration {
            _ = register(previousConfiguration)
        }
        return false
    }

    deinit {
        unregisterHotKey()
        if let eventHandler { RemoveEventHandler(eventHandler) }
    }

    private func register(_ configuration: HotKeyConfiguration) -> Bool {
        let hotKeyID = EventHotKeyID(signature: fourCharCode("SHDT"), id: 1)
        let hotKeyStatus = RegisterEventHotKey(
            configuration.keyCode,
            configuration.modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        guard hotKeyStatus == noErr else {
            NSLog("ShowDesktop: global kısayol kaydedilemedi (OSStatus: %d)", hotKeyStatus)
            isRegistered = false
            return false
        }

        isRegistered = true
        currentConfiguration = configuration
        return true
    }

    private func unregisterHotKey() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        isRegistered = false
        currentConfiguration = nil
    }

    private func fourCharCode(_ string: String) -> FourCharCode {
        string.utf8.reduce(0) { ($0 << 8) + FourCharCode($1) }
    }
}
