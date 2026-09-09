import XCTest
@testable import ShowDesktop

final class RestorationTrackerTests: XCTestCase {
    func testOnlyFailedWindowsAreRetried() {
        var tracker = RestorationTracker<Int>()
        (1...4).forEach { tracker.store($0) }
        let result = tracker.restore { window in
            switch window {
            case 1: return .restored
            case 2: return .alreadyOpen
            case 3: return .unavailable
            default: return .failed
            }
        }
        XCTAssertEqual(result.succeeded, 1)
        XCTAssertEqual(result.alreadyOpen, 1)
        XCTAssertEqual(result.unavailable, 1)
        XCTAssertEqual(result.failed, 1)
        XCTAssertEqual(result.pending, 1)
        var retried: [Int] = []
        let retry = tracker.restore { retried.append($0); return .restored }
        XCTAssertEqual(retried, [4])
        XCTAssertEqual(retry.succeeded, 1)
        XCTAssertEqual(retry.pending, 0)
    }

    func testPersistentFailuresAreNotSilentlyDiscarded() {
        var tracker = RestorationTracker<Int>()
        tracker.store(1)
        for _ in 0..<10 {
            let result = tracker.restore { _ in .failed }
            XCTAssertEqual(result.failed, 1)
            XCTAssertEqual(result.pending, 1)
        }
    }

    func testExplicitRecoveryAllowsNewCycleWithoutRestoringForgottenWindows() {
        var tracker = RestorationTracker<Int>()
        tracker.store(1)
        _ = tracker.restore { _ in .failed }
        tracker.discard()
        XCTAssertEqual(tracker.count, 0)
        tracker.store(2)
        var restored: [Int] = []
        let result = tracker.restore { restored.append($0); return .restored }
        XCTAssertEqual(restored, [2])
        XCTAssertEqual(result.pending, 0)
    }
}
