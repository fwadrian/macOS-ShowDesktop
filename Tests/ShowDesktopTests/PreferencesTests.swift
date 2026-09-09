import XCTest
@testable import ShowDesktop

final class PreferencesTests: XCTestCase {
    private var defaults: UserDefaults!
    private var preferences: Preferences!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "ShowDesktopTests")!
        defaults.removePersistentDomain(forName: "ShowDesktopTests")
        preferences = Preferences(defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: "ShowDesktopTests")
        preferences = nil
        defaults = nil
        super.tearDown()
    }

    func testExcludedApplicationsRoundTrip() {
        let excludedApps: Set<String> = ["com.apple.Finder", "com.apple.Safari"]

        preferences.excludedBundleIdentifiers = excludedApps

        XCTAssertEqual(preferences.excludedBundleIdentifiers, excludedApps)
    }

    func testHotKeyDefaultsToOptionSpace() {
        XCTAssertEqual(preferences.hotKeyConfiguration.id, "option-space")
    }

    func testHotKeyConfigurationRoundTrip() {
        let configuration = HotKeyConfiguration.presets[1]

        preferences.setHotKeyConfiguration(configuration)

        XCTAssertEqual(preferences.hotKeyConfiguration, configuration)
    }

    func testUnknownHotKeyFallsBackToDefault() {
        defaults.set("unknown", forKey: "hotKeyConfigurationID")

        XCTAssertEqual(preferences.hotKeyConfiguration.id, "option-space")
    }
}
