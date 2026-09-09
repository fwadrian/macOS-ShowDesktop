// Owns only windows successfully minimized by ShowDesktop. Failed restores stay
// tracked until they succeed, disappear, or the user explicitly discards them.
struct RestorationTracker<Window> {
    enum Outcome { case restored, alreadyOpen, unavailable, failed }
    private var windows: [Window] = []
    var count: Int { windows.count }

    mutating func store(_ window: Window) { windows.append(window) }
    mutating func discard() { windows.removeAll() }

    mutating func restore(_ action: (Window) -> Outcome) -> OperationResult {
        var summary = OperationResult()
        windows = windows.filter { window in
            switch action(window) {
            case .restored: summary.succeeded += 1
            case .alreadyOpen: summary.alreadyOpen += 1
            case .unavailable: summary.unavailable += 1
            case .failed:
                summary.failed += 1
                return true
            }
            return false
        }
        summary.pending = windows.count
        return summary
    }
}
