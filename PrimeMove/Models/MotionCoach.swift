import SwiftUI
import CoreMotion

// MARK: - What a movement should feel like

/// Every exercise kind implies a different motion signature. The coach checks
/// the one that matches instead of applying a single rule to everything.
enum MoveExpectation {
    /// Repeated, punchy movement: jumping jacks, high knees, butt kicks.
    case rhythmic
    /// Continuous but unhurried: mobility circles, activation work.
    case flowing
    /// Deliberate stillness: a static stretch you are meant to hold.
    case hold

    init(_ kind: ExerciseKind) {
        switch kind {
        case .cardio, .dynamic: self = .rhythmic
        case .mobility, .activation: self = .flowing
        case .staticStretch: self = .hold
        }
    }

    var title: String {
        switch self {
        case .rhythmic: "Keep the rhythm"
        case .flowing: "Keep it moving"
        case .hold: "Hold it steady"
        }
    }

    var icon: String {
        switch self {
        case .rhythmic: "waveform.path.ecg"
        case .flowing: "arrow.triangle.2.circlepath"
        case .hold: "hand.raised.fill"
        }
    }

    /// Prompt shown when the reading disagrees with the expectation.
    var nudge: String {
        switch self {
        case .rhythmic: "Pick the pace back up"
        case .flowing: "Keep the movement going"
        case .hold: "Settle — stop swaying"
        }
    }

    var accent: Color {
        switch self {
        case .rhythmic: Theme.signal
        case .flowing: Theme.volt
        case .hold: Theme.cyan
        }
    }

    /// Acceleration in g. Above this counts as moving.
    var lowerBound: Double {
        switch self {
        case .rhythmic: 0.12
        case .flowing: 0.04
        case .hold: 0
        }
    }

    /// Acceleration in g. A hold is only good while the reading stays below this.
    var upperBound: Double {
        switch self {
        case .hold: 0.06
        default: .infinity
        }
    }

    var countsReps: Bool { self == .rhythmic }
}

// MARK: - Coach

/// Reads the device's motion sensors during a session and judges whether the
/// movement on screen is actually happening.
///
/// Nothing is recorded and nothing leaves the phone: the raw signal is turned
/// into a single number per step and then discarded. Device motion needs no
/// permission prompt, and on hardware without the sensors the whole feature
/// reports itself unavailable and the UI hides it.
@MainActor
@Observable
final class MotionCoach {

    // MARK: Live readings

    /// Smoothed acceleration, normalized to 0...1 for the meter.
    private(set) var level: Double = 0
    /// Reps counted during the current step, for rhythmic movements only.
    private(set) var reps: Int = 0
    /// How much of the current step matched the expectation, 0...1.
    private(set) var compliance: Double = 0
    private(set) var expectation: MoveExpectation = .flowing
    private(set) var isRunning = false
    /// True once enough of the step has gone by to judge it.
    private(set) var hasReading = false

    /// Weighted score for the whole session, 0...1. Nil until a session ends.
    private(set) var sessionScore: Double?

    var isAvailable: Bool { manager.isDeviceMotionAvailable }

    /// True when the reading currently disagrees with the expectation.
    var isOffTarget: Bool {
        guard hasReading, isRunning else { return false }
        return !matchesExpectation(smoothed)
    }

    // MARK: Internals

    private let manager = CMMotionManager()
    private let sampleInterval = 1.0 / 30.0
    /// Seconds at the start of a step before judging begins, to get into position.
    private let gracePeriod: TimeInterval = 1.5

    private var smoothed: Double = 0
    private var stepStart = Date.distantPast
    private var goodSamples = 0
    private var totalSamples = 0

    /// Rep detection state: armed once the signal drops, fires on the next peak.
    private var repArmed = true
    private var lastRepAt = Date.distantPast

    /// Finished steps as (duration in seconds, compliance 0...1).
    private var stepScores: [(weight: Double, score: Double)] = []

    private var lastNudgeAt = Date.distantPast

    // MARK: Lifecycle

    func start() {
        guard isAvailable, !isRunning else { return }
        manager.deviceMotionUpdateInterval = sampleInterval
        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self, let motion else { return }
            MainActor.assumeIsolated { self.ingest(motion.userAcceleration) }
        }
        isRunning = true
    }

    func stop() {
        guard isRunning else { return }
        manager.stopDeviceMotionUpdates()
        isRunning = false
    }

    /// Call when a new movement begins.
    func beginStep(kind: ExerciseKind) {
        expectation = MoveExpectation(kind)
        stepStart = .now
        goodSamples = 0
        totalSamples = 0
        reps = 0
        compliance = 0
        hasReading = false
        repArmed = true
    }

    /// Call when a movement finishes, with how long it ran for.
    func endStep(seconds: Int) {
        guard totalSamples > 0 else { return }
        stepScores.append((weight: Double(max(seconds, 1)), score: compliance))
    }

    /// Call once the whole session is done.
    func finish() {
        stop()
        guard !stepScores.isEmpty else { return }
        let totalWeight = stepScores.reduce(0) { $0 + $1.weight }
        guard totalWeight > 0 else { return }
        sessionScore = stepScores.reduce(0) { $0 + $1.weight * $1.score } / totalWeight
    }

    func reset() {
        stepScores = []
        sessionScore = nil
        reps = 0
        compliance = 0
        hasReading = false
    }

    // MARK: Signal

    private func ingest(_ acceleration: CMAcceleration) {
        let magnitude = sqrt(acceleration.x * acceleration.x
                             + acceleration.y * acceleration.y
                             + acceleration.z * acceleration.z)

        // Low-pass filter: the raw signal is far too jumpy to score or display.
        smoothed += (magnitude - smoothed) * 0.25
        level = min(1, smoothed / 0.8)

        if expectation.countsReps { countRep(on: smoothed) }

        // Give the user a moment to get into position before judging.
        guard Date.now.timeIntervalSince(stepStart) > gracePeriod else { return }

        totalSamples += 1
        if matchesExpectation(smoothed) { goodSamples += 1 }
        compliance = Double(goodSamples) / Double(totalSamples)
        hasReading = true

        nudgeIfDrifting()
    }

    private func matchesExpectation(_ value: Double) -> Bool {
        value >= expectation.lowerBound && value <= expectation.upperBound
    }

    /// Peak counting with a re-arm threshold, so one rep is never counted twice.
    private func countRep(on value: Double) {
        let peak = 0.30
        let rearm = 0.14
        let minimumGap: TimeInterval = 0.28

        if value < rearm {
            repArmed = true
            return
        }
        guard repArmed, value > peak,
              Date.now.timeIntervalSince(lastRepAt) > minimumGap else { return }

        repArmed = false
        lastRepAt = .now
        reps += 1
        Cue.tick()
    }

    /// A single tap if the movement has clearly stalled, at most once every 4s.
    private func nudgeIfDrifting() {
        guard compliance < 0.45, totalSamples > 45,
              Date.now.timeIntervalSince(lastNudgeAt) > 4 else { return }
        lastNudgeAt = .now
        Cue.tick()
    }
}

// MARK: - Grading

extension Double {
    /// Turns a 0...1 execution score into a short verdict.
    var executionGrade: String {
        switch self {
        case 0.85...: "Sharp"
        case 0.65..<0.85: "Solid"
        case 0.4..<0.65: "Loose"
        default: "Patchy"
        }
    }

    var executionColor: Color {
        switch self {
        case 0.85...: Theme.volt
        case 0.65..<0.85: Theme.cyan
        case 0.4..<0.65: Theme.signal
        default: Theme.textMuted
        }
    }

    var executionPercent: String { "\(Int((self * 100).rounded()))%" }
}
