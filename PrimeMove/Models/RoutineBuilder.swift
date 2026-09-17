import SwiftUI

// MARK: - Space available

/// How much room the user has right now. Drives which movements are eligible.
enum PrimeSpace: String, CaseIterable, Identifiable {
    case full, limited, seated

    var id: String { rawValue }

    var title: String {
        switch self {
        case .full: "Open space"
        case .limited: "One mat"
        case .seated: "Seated"
        }
    }

    var detail: String {
        switch self {
        case .full: "A pitch, gym floor or park"
        case .limited: "Room to stand and reach"
        case .seated: "A desk, plane or car seat"
        }
    }

    var icon: String {
        switch self {
        case .full: "figure.run"
        case .limited: "rectangle.portrait"
        case .seated: "chair.fill"
        }
    }
}

// MARK: - The brief

/// What the user told us in the check-in. Everything the builder needs.
struct PrimeBrief {
    var activity: WarmupCategory = .universal
    var minutes: Int = 6
    var tightAreas: Set<MuscleGroup> = []
    var space: PrimeSpace = .full
    var effort: Intensity = .moderate

    var budgetSeconds: Int { minutes * 60 }
}

// MARK: - Builder

/// Assembles a routine on the fly from the exercise library.
///
/// The rules mirror how a warm-up is actually coached: work from general to
/// specific, from low intensity to high, spend the most time on what the user
/// says is tight, and never prescribe a movement the room can't fit.
enum RoutineBuilder {

    /// Movements that need room to travel across the floor.
    private static let needsTravel: Set<String> = [
        "ex_walking_lunge", "ex_inchworm", "ex_worlds_greatest"
    ]

    /// What each activity leans on most.
    private static func emphasis(for category: WarmupCategory) -> Set<MuscleGroup> {
        switch category {
        case .universal: [.fullBody, .core, .shoulders, .hips]
        case .running:   [.hips, .glutes, .hamstrings, .calves, .ankles, .quads]
        case .football:  [.hips, .glutes, .quads, .hamstrings, .ankles, .core]
        case .gym:       [.shoulders, .upperBack, .core, .hips, .wrists, .glutes]
        case .mobility:  [.lowerBack, .upperBack, .hips, .neck, .core]
        }
    }

    /// Order movements run in. General mobility first, highest output last.
    private static func phase(_ kind: ExerciseKind) -> Int {
        switch kind {
        case .mobility: 0
        case .staticStretch: 1
        case .activation: 2
        case .dynamic: 3
        case .cardio: 4
        }
    }

    /// How much each effort level favours a given kind of movement.
    private static func kindBonus(_ kind: ExerciseKind, effort: Intensity) -> Double {
        switch effort {
        case .easy:
            switch kind {
            case .mobility: 2.5
            case .staticStretch: 2.0
            case .activation: 1.0
            case .dynamic: 0.5
            case .cardio: -1.5
            }
        case .moderate:
            switch kind {
            case .mobility: 1.5
            case .staticStretch: 0.5
            case .activation: 1.5
            case .dynamic: 1.5
            case .cardio: 0.5
            }
        case .hard:
            switch kind {
            case .mobility: 0.5
            case .staticStretch: -1.0
            case .activation: 1.5
            case .dynamic: 2.5
            case .cardio: 2.5
            }
        }
    }

    // MARK: Eligibility

    private static func eligible(_ exercise: Exercise, for space: PrimeSpace) -> Bool {
        switch space {
        case .full: true
        case .limited: !needsTravel.contains(exercise.id)
        case .seated: exercise.deskFriendly
        }
    }

    // MARK: Build

    /// Builds a routine for the brief. `neglected` nudges the picker toward
    /// muscle groups the training log shows have been skipped lately.
    static func build(_ brief: PrimeBrief, neglected: [MuscleGroup] = []) -> Routine {
        let pool = Library.exercises.filter { eligible($0, for: brief.space) }
        guard !pool.isEmpty else {
            return fallback(brief)
        }

        let focus = emphasis(for: brief.activity)
        let neglectedSet = Set(neglected)

        func score(_ exercise: Exercise) -> Double {
            var value = kindBonus(exercise.kind, effort: brief.effort)
            for muscle in exercise.primaryMuscles {
                if brief.tightAreas.contains(muscle) { value += 3.5 }
                if focus.contains(muscle) { value += 2.0 }
                if neglectedSet.contains(muscle) { value += 0.75 }
            }
            // Desk-friendly work is a poor use of an open field.
            if brief.space == .full && exercise.deskFriendly { value -= 0.25 }
            return value
        }

        let moveCount = plannedMoveCount(for: brief)

        // Take the best-scoring movements, but keep the body parts varied:
        // once a muscle group has been hit twice it stops earning points.
        var chosen: [Exercise] = []
        var coverage: [MuscleGroup: Int] = [:]
        var remaining = pool.sorted { lhs, rhs in
            let l = score(lhs), r = score(rhs)
            return l == r ? lhs.id < rhs.id : l > r
        }

        while chosen.count < moveCount, !remaining.isEmpty {
            let pick = remaining.max { lhs, rhs in
                adjusted(lhs, base: score(lhs), coverage: coverage)
                    < adjusted(rhs, base: score(rhs), coverage: coverage)
            }
            guard let pick else { break }
            chosen.append(pick)
            for muscle in pick.primaryMuscles { coverage[muscle, default: 0] += 1 }
            remaining.removeAll { $0.id == pick.id }
        }

        // Run them in coaching order, tight areas first inside each phase.
        chosen.sort { lhs, rhs in
            let lp = phase(lhs.kind), rp = phase(rhs.kind)
            if lp != rp { return lp < rp }
            let lt = lhs.primaryMuscles.contains(where: brief.tightAreas.contains)
            let rt = rhs.primaryMuscles.contains(where: brief.tightAreas.contains)
            if lt != rt { return lt }
            return lhs.id < rhs.id
        }

        let steps = allocate(seconds: brief.budgetSeconds, across: chosen, brief: brief)
        guard !steps.isEmpty else { return fallback(brief) }

        return Routine(
            id: "built_\(UUID().uuidString.prefix(8))",
            title: title(for: brief),
            subtitle: subtitle(for: brief),
            category: brief.activity,
            intensity: brief.effort,
            steps: steps)
    }

    /// Penalises a movement whose muscles are already well covered.
    private static func adjusted(_ exercise: Exercise, base: Double,
                                 coverage: [MuscleGroup: Int]) -> Double {
        let repeats = exercise.primaryMuscles.reduce(0) { $0 + (coverage[$1] ?? 0) }
        return base - Double(repeats) * 1.25
    }

    // MARK: Time

    /// Roughly 45 seconds a movement, kept inside sensible bounds.
    /// Exposed so the check-in can preview the shape of the session without
    /// assembling the whole routine on every slider tick.
    static func plannedMoveCount(for brief: PrimeBrief) -> Int {
        let target = Int((Double(brief.budgetSeconds) / 45.0).rounded())
        return min(max(target, 3), 12)
    }

    /// Splits the time budget across the chosen movements, weighted so tight
    /// areas and higher-output work get the longer holds. Rounded to 5s.
    private static func allocate(seconds budget: Int, across exercises: [Exercise],
                                 brief: PrimeBrief) -> [RoutineStep] {
        guard !exercises.isEmpty else { return [] }

        let weights = exercises.map { exercise -> Double in
            var weight = 1.0
            if exercise.primaryMuscles.contains(where: brief.tightAreas.contains) { weight += 0.35 }
            switch exercise.kind {
            case .cardio, .dynamic: weight += brief.effort == .hard ? 0.2 : 0.0
            case .staticStretch: weight += brief.effort == .easy ? 0.25 : 0.0
            default: break
            }
            return weight
        }

        let totalWeight = weights.reduce(0, +)
        return zip(exercises, weights).map { exercise, weight in
            let raw = Double(budget) * (weight / totalWeight)
            let rounded = (raw / 5).rounded() * 5
            return RoutineStep(exerciseID: exercise.id,
                               seconds: Int(min(max(rounded, 20), 90)))
        }
    }

    // MARK: Naming

    private static func title(for brief: PrimeBrief) -> String {
        if let area = brief.tightAreas.sorted(by: { $0.title < $1.title }).first,
           brief.tightAreas.count == 1 {
            return "\(area.title) Primer"
        }
        if brief.tightAreas.count > 1 { return "Targeted Primer" }
        switch brief.activity {
        case .universal: return "Your \(brief.minutes)-Minute Prime"
        case .running: return "Run Primer"
        case .football: return "Pitch Primer"
        case .gym: return "Lift Primer"
        case .mobility: return "Mobility Primer"
        }
    }

    private static func subtitle(for brief: PrimeBrief) -> String {
        var parts = ["\(brief.effort.label.lowercased()) effort"]
        parts.append(brief.space == .seated ? "seated" : brief.space.title.lowercased())
        if !brief.tightAreas.isEmpty {
            let names = brief.tightAreas.sorted { $0.title < $1.title }.prefix(2).map(\.title)
            parts.append("focus on \(names.joined(separator: " & ").lowercased())")
        }
        return "Built for you — " + parts.joined(separator: ", ")
    }

    /// Used only if filtering left nothing to work with.
    private static func fallback(_ brief: PrimeBrief) -> Routine {
        Routine(
            id: "built_fallback",
            title: "Universal Primer",
            subtitle: "A safe all-round warm-up",
            category: brief.activity,
            intensity: .easy,
            steps: [
                RoutineStep(exerciseID: "ex_neck_release", seconds: 30),
                RoutineStep(exerciseID: "ex_shoulder_circles", seconds: 30),
                RoutineStep(exerciseID: "ex_torso_twist", seconds: 30),
                RoutineStep(exerciseID: "ex_side_bend", seconds: 30)
            ])
    }
}
