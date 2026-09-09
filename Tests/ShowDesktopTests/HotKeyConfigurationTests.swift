import XCTest
@testable import ShowDesktop

final class HotKeyConfigurationTests: XCTestCase {
    func testPresetsHaveUniqueIdentifiers() {
        let identifiers = HotKeyConfiguration.presets.map(\.id)

        XCTAssertEqual(identifiers.count, Set(identifiers).count)
    }

    func testOptionSpaceIsTheDefaultPreset() {
        let defaultPreset = HotKeyConfiguration.defaultPreset

        XCTAssertEqual(defaultPreset.id, "option-space")
        XCTAssertEqual(defaultPreset.title, "⌥ Space")
    }

    func testPresetsHaveValidKeyCodesAndModifiers() {
        for preset in HotKeyConfiguration.presets {
            XCTAssertGreaterThanOrEqual(preset.keyCode, 0)
            XCTAssertGreaterThan(preset.modifiers, 0)
        }
    }
}
