import SwiftUI

// MARK: - Muscle groups

enum MuscleGroup: String, CaseIterable, Identifiable {
    case neck, shoulders, chest, upperBack, lowerBack, core
    case hips, glutes, quads, hamstrings, calves, ankles
    case wrists, fullBody

    var id: String { rawValue }

    var title: String {
        switch self {
        case .neck: "Neck"
        case .shoulders: "Shoulders"
        case .chest: "Chest"
        case .upperBack: "Upper Back"
        case .lowerBack: "Lower Back"
        case .core: "Core"
        case .hips: "Hips"
        case .glutes: "Glutes"
        case .quads: "Quads"
        case .hamstrings: "Hamstrings"
        case .calves: "Calves"
        case .ankles: "Ankles"
        case .wrists: "Wrists & Forearms"
        case .fullBody: "Full Body"
        }
    }
}

// MARK: - Exercise

enum ExerciseKind: String {
    case mobility, dynamic, staticStretch = "static", activation, cardio
    var label: String {
        switch self {
        case .mobility: "Mobility"
        case .dynamic: "Dynamic"
        case .staticStretch: "Static Stretch"
        case .activation: "Activation"
        case .cardio: "Cardio"
        }
    }
}

struct Exercise: Identifiable, Hashable {
    let id: String                 // also the asset name, e.g. "ex_neck_release"
    let name: String
    let kind: ExerciseKind
    let cue: String                // one-line coaching cue
    let primaryMuscles: [MuscleGroup]
    let summary: String            // what the movement does
    let whyItMatters: String       // injury-prevention rationale
    let steps: [String]            // how to perform
    let mistakes: [String]         // common mistakes to avoid
    let deskFriendly: Bool

    var asset: String { id }
    static func == (l: Exercise, r: Exercise) -> Bool { l.id == r.id }
    func hash(into h: inout Hasher) { h.combine(id) }
}

// MARK: - Categories

enum WarmupCategory: String, CaseIterable, Identifiable {
    case universal, running, football, gym, mobility

    var id: String { rawValue }

    var title: String {
        switch self {
        case .universal: "Quick / Universal"
        case .running: "Running"
        case .football: "Football"
        case .gym: "Gym & Strength"
        case .mobility: "Mobility & Recovery"
        }
    }

    var short: String {
        switch self {
        case .universal: "Universal"
        case .running: "Run"
        case .football: "Football"
        case .gym: "Gym"
        case .mobility: "Mobility"
        }
    }

    var accent: Color {
        switch self {
        case .universal: Theme.volt
        case .running: Theme.signal
        case .football: Theme.cyan
        case .gym: Theme.magenta
        case .mobility: Theme.violet
        }
    }

    var banner: String {
        switch self {
        case .universal: "banner_quick"
        case .running: "banner_running"
        case .football: "banner_football"
        case .gym: "banner_gym"
        case .mobility: "banner_mobility"
        }
    }

    var icon: String {
        switch self {
        case .universal: "bolt.fill"
        case .running: "figure.run"
        case .football: "soccerball"
        case .gym: "dumbbell.fill"
        case .mobility: "figure.cooldown"
        }
    }

    var blurb: String {
        switch self {
        case .universal: "Prime the whole body, anywhere, in minutes."
        case .running: "Open the hips and fire the posterior chain before you run."
        case .football: "Explosive, multi-directional prep for the pitch."
        case .gym: "Activate and mobilize before you load the bar."
        case .mobility: "Slow, deliberate work to restore range and recover."
        }
    }
}

enum Intensity: String {
    case easy, moderate, hard
    var label: String { rawValue.capitalized }
    var color: Color {
        switch self {
        case .easy: Theme.cyan
        case .moderate: Theme.volt
        case .hard: Theme.signal
        }
    }
}

// MARK: - Routine

/// A single timed step inside a routine.
struct RoutineStep: Identifiable, Hashable {
    let exerciseID: String
    let seconds: Int
    var id: String { exerciseID + "-\(seconds)" }

    var exercise: Exercise { Library.exercise(exerciseID) }
}

struct Routine: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let category: WarmupCategory
    let intensity: Intensity
    let steps: [RoutineStep]

    var accent: Color { category.accent }
    var banner: String { category.banner }

    var totalSeconds: Int { steps.reduce(0) { $0 + $1.seconds } }
    var minutes: Int { Int((Double(totalSeconds) / 60).rounded()) }
    var moveCount: Int { steps.count }
}

// MARK: - Mini warm-ups (desk / commute)

struct MiniWarmup: Identifiable {
    let id: String
    let title: String
    let context: String        // "At your desk", "On the commute"...
    let icon: String
    let accent: Color
    let steps: [RoutineStep]

    var totalSeconds: Int { steps.reduce(0) { $0 + $1.seconds } }
    var minutes: Int { max(1, Int((Double(totalSeconds) / 60).rounded())) }
}

// MARK: - Timer presets

struct IntervalPreset: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let workSeconds: Int
    let restSeconds: Int
    let rounds: Int
    let accent: Color

    var totalSeconds: Int { (workSeconds + restSeconds) * rounds }
}

// MARK: - Emergency / first aid

struct ArticleSource: Identifiable {
    let id = UUID()
    let publisher: String
    let title: String
    let url: URL
}

struct CarePhase: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
}

struct EmergencyProtocol: Identifiable {
    let id: String
    let title: String
    let tagline: String
    let icon: String
    let severity: String          // e.g. "Common", "Urgent", "Call 911"
    let severityColor: Color
    let overview: String
    let doNow: [CarePhase]         // step-by-step actions
    let avoid: [String]           // what NOT to do
    let callEmergencyIf: [String] // red flags
    let sources: [ArticleSource]
}
