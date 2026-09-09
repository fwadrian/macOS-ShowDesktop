import Foundation

final class Preferences {
    static let shared = Preferences()

    private let defaults: UserDefaults
    private let excludedAppsKey = "excludedBundleIdentifiers"
    private let hotKeyKey = "hotKeyConfigurationID"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var excludedBundleIdentifiers: Set<String> {
        get { Set(defaults.stringArray(forKey: excludedAppsKey) ?? []) }
        set { defaults.set(Array(newValue).sorted(), forKey: excludedAppsKey) }
    }

    var hotKeyConfiguration: HotKeyConfiguration {
        let storedID = defaults.string(forKey: hotKeyKey)
        return HotKeyConfiguration.presets.first { $0.id == storedID } ?? HotKeyConfiguration.defaultPreset
    }

    func setHotKeyConfiguration(_ configuration: HotKeyConfiguration) {
        defaults.set(configuration.id, forKey: hotKeyKey)
    }
}
