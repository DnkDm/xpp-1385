import SwiftUI

/// The one thing an iPad window can be running full-screen: a timed routine
/// (routine or mini warm-up) or an interval preset.
struct PadSessionItem: Identifiable {
    enum Kind {
        case routine(SessionEngine)
        case interval(IntervalEngine)
    }
    let id = UUID()
    let kind: Kind
}

/// Owns the active session on iPad. It lives at the root so a running session
/// survives sidebar ⇄ tab-bar relayouts (Split View / Slide Over resizes).
@Observable
final class PadSessionPresenter {
    var active: PadSessionItem?

    func start(_ routine: Routine) {
        Cue.tap()
        active = PadSessionItem(kind: .routine(
            SessionEngine(steps: routine.steps, accent: routine.accent, title: routine.title)))
    }

    func start(_ mini: MiniWarmup) {
        Cue.tap()
        active = PadSessionItem(kind: .routine(
            SessionEngine(steps: mini.steps, accent: mini.accent, title: mini.title)))
    }

    func start(_ preset: IntervalPreset) {
        Cue.tap()
        active = PadSessionItem(kind: .interval(IntervalEngine(preset: preset)))
    }
}
