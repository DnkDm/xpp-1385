import SwiftUI
import Combine
import UIKit
import AudioToolbox

// MARK: - Haptics & cues

enum Cue {
    static func tick() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.6)
    }
    static func step() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        AudioServicesPlaySystemSound(1113)
    }
    static func done() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        AudioServicesPlaySystemSound(1025)
    }
    static func tap() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

// MARK: - Session engine (drives a routine of timed steps)

@Observable
final class SessionEngine {
    let steps: [RoutineStep]
    let accent: Color
    let title: String

    private(set) var index: Int = 0
    private(set) var remaining: Int
    private(set) var isRunning = false
    private(set) var isComplete = false

    private var timer: AnyCancellable?

    init(steps: [RoutineStep], accent: Color, title: String) {
        self.steps = steps.isEmpty ? [RoutineStep(exerciseID: "ex_neck_release", seconds: 30)] : steps
        self.accent = accent
        self.title = title
        self.remaining = self.steps[0].seconds
    }

    var current: RoutineStep { steps[min(index, steps.count - 1)] }
    var next: RoutineStep? { index + 1 < steps.count ? steps[index + 1] : nil }
    var exercise: Exercise { current.exercise }

    var stepProgress: Double {
        let total = Double(current.seconds)
        return total <= 0 ? 0 : 1 - Double(remaining) / total
    }
    var totalProgress: Double {
        let done = steps.prefix(index).reduce(0) { $0 + $1.seconds }
        let withinStep = current.seconds - remaining
        return Double(done + withinStep) / Double(max(1, totalSeconds))
    }
    var totalSeconds: Int { steps.reduce(0) { $0 + $1.seconds } }
    var elapsed: Int {
        steps.prefix(index).reduce(0) { $0 + $1.seconds } + (current.seconds - remaining)
    }

    func start() {
        guard !isComplete else { return }
        isRunning = true
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tickDown() }
    }

    func pause() {
        isRunning = false
        timer?.cancel()
    }

    func toggle() {
        Cue.tap()
        isRunning ? pause() : start()
    }

    private func tickDown() {
        guard isRunning else { return }
        if remaining > 1 {
            remaining -= 1
            if remaining <= 3 { Cue.tick() }
        } else {
            advance(byUser: false)
        }
    }

    func advance(byUser: Bool) {
        if index + 1 < steps.count {
            index += 1
            remaining = current.seconds
            byUser ? Cue.tap() : Cue.step()
        } else {
            complete()
        }
    }

    func back() {
        Cue.tap()
        if remaining < current.seconds - 1 {
            remaining = current.seconds            // restart current
        } else if index > 0 {
            index -= 1
            remaining = current.seconds
        }
    }

    func skip() { advance(byUser: true) }

    private func complete() {
        isComplete = true
        isRunning = false
        timer?.cancel()
        Cue.done()
    }

    func restart() {
        index = 0
        remaining = steps[0].seconds
        isComplete = false
        Cue.tap()
        start()
    }
}

// MARK: - Interval engine (work / rest rounds)

@Observable
final class IntervalEngine {
    enum Phase { case work, rest, done }

    let preset: IntervalPreset
    private(set) var phase: Phase = .work
    private(set) var round: Int = 1
    private(set) var remaining: Int
    private(set) var isRunning = false

    private var timer: AnyCancellable?

    init(preset: IntervalPreset) {
        self.preset = preset
        self.remaining = preset.workSeconds
    }

    var phaseLabel: String {
        switch phase {
        case .work: "Work"
        case .rest: "Rest"
        case .done: "Done"
        }
    }
    var phaseColor: Color {
        switch phase {
        case .work: preset.accent
        case .rest: Theme.cyan
        case .done: Theme.volt
        }
    }
    var phaseTotal: Int {
        switch phase {
        case .work: preset.workSeconds
        case .rest: preset.restSeconds
        case .done: 1
        }
    }
    var progress: Double { phaseTotal <= 0 ? 1 : 1 - Double(remaining) / Double(phaseTotal) }

    func toggle() {
        Cue.tap()
        isRunning ? pause() : start()
    }

    func start() {
        guard phase != .done else { return }
        isRunning = true
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect().sink { [weak self] _ in self?.tickDown() }
    }

    func pause() { isRunning = false; timer?.cancel() }

    private func tickDown() {
        guard isRunning else { return }
        if remaining > 1 {
            remaining -= 1
            if remaining <= 3 { Cue.tick() }
        } else {
            nextPhase()
        }
    }

    private func nextPhase() {
        switch phase {
        case .work:
            if preset.restSeconds > 0 {
                phase = .rest; remaining = preset.restSeconds; Cue.step()
            } else { advanceRound() }
        case .rest:
            advanceRound()
        case .done:
            break
        }
    }

    private func advanceRound() {
        if round < preset.rounds {
            round += 1; phase = .work; remaining = preset.workSeconds; Cue.step()
        } else {
            phase = .done; isRunning = false; timer?.cancel(); Cue.done()
        }
    }

    func reset() {
        pause()
        phase = .work; round = 1; remaining = preset.workSeconds
        Cue.tap()
    }
}

// MARK: - Stopwatch

@Observable
final class Stopwatch {
    private(set) var elapsed: TimeInterval = 0
    private(set) var laps: [TimeInterval] = []
    private(set) var isRunning = false
    private var timer: AnyCancellable?

    func toggle() {
        Cue.tap()
        if isRunning { pause() } else { start() }
    }
    func start() {
        isRunning = true
        timer?.cancel()
        timer = Timer.publish(every: 0.03, on: .main, in: .common)
            .autoconnect().sink { [weak self] _ in self?.elapsed += 0.03 }
    }
    func pause() { isRunning = false; timer?.cancel() }
    func lap() { Cue.step(); laps.insert(elapsed, at: 0) }
    func reset() { pause(); elapsed = 0; laps = []; Cue.tap() }
}

// MARK: - Time formatting

func mmss(_ seconds: Int) -> String {
    String(format: "%01d:%02d", seconds / 60, seconds % 60)
}
func mmssMillis(_ t: TimeInterval) -> String {
    let m = Int(t) / 60
    let s = Int(t) % 60
    let cs = Int((t - floor(t)) * 100)
    return String(format: "%02d:%02d.%02d", m, s, cs)
}
func durationLabel(_ seconds: Int) -> String {
    let m = seconds / 60, s = seconds % 60
    if m == 0 { return "\(s)s" }
    return s == 0 ? "\(m) min" : "\(m)m \(s)s"
}
