import SwiftUI
import Observation

// MARK: - A completed session

/// One finished session, written to disk so progress survives relaunches.
struct SessionRecord: Identifiable, Codable, Hashable {
    enum Source: String, Codable {
        case routine, mini, custom, interval

        var label: String {
            switch self {
            case .routine: "Routine"
            case .mini: "Mini move"
            case .custom: "Built for you"
            case .interval: "Interval"
            }
        }

        var icon: String {
            switch self {
            case .routine: "bolt.fill"
            case .mini: "timer"
            case .custom: "wand.and.stars"
            case .interval: "stopwatch.fill"
            }
        }
    }

    let id: UUID
    let title: String
    let finishedAt: Date
    let seconds: Int
    let moveCount: Int
    let source: Source
    /// Raw values of `MuscleGroup`, so the log stays decodable if the enum grows.
    let muscles: [String]
    /// Motion-check result, 0...1. Nil when the sensors were unavailable or the
    /// feature was switched off. Optional, so older logs still decode.
    let executionScore: Double?

    init(id: UUID = UUID(), title: String, finishedAt: Date = .now,
         seconds: Int, moveCount: Int, source: Source, muscles: [MuscleGroup],
         executionScore: Double? = nil) {
        self.id = id
        self.title = title
        self.finishedAt = finishedAt
        self.seconds = seconds
        self.moveCount = moveCount
        self.source = source
        self.muscles = muscles.map(\.rawValue)
        self.executionScore = executionScore
    }

    var muscleGroups: [MuscleGroup] { muscles.compactMap(MuscleGroup.init(rawValue:)) }
    var minutes: Int { max(1, Int((Double(seconds) / 60).rounded())) }
}

// MARK: - Store

/// Local-only training history. Nothing leaves the device: records are written
/// as JSON into Application Support.
@Observable
final class TrainingLog {

    static let shared = TrainingLog()

    private(set) var records: [SessionRecord] = []

    private let fileURL: URL
    private let calendar = Calendar.current

    private init() {
        let base = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL.documentsDirectory
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        fileURL = base.appendingPathComponent("training-log.json")
        load()
    }

    // MARK: Mutation

    func record(_ session: SessionRecord) {
        records.insert(session, at: 0)
        records.sort { $0.finishedAt > $1.finishedAt }
        save()
    }

    /// Logs a finished engine run. Called from the completion screen.
    func record(engine: SessionEngine, source: SessionRecord.Source,
                executionScore: Double? = nil) {
        var seen = Set<MuscleGroup>()
        var muscles: [MuscleGroup] = []
        for step in engine.steps {
            for m in step.exercise.primaryMuscles where !seen.contains(m) {
                seen.insert(m)
                muscles.append(m)
            }
        }
        record(SessionRecord(title: engine.title,
                             seconds: engine.totalSeconds,
                             moveCount: engine.steps.count,
                             source: source,
                             muscles: muscles,
                             executionScore: executionScore))
    }

    func clear() {
        records = []
        save()
    }

    // MARK: Persistence

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        records = (try? decoder.decode([SessionRecord].self, from: data)) ?? []
        records.sort { $0.finishedAt > $1.finishedAt }
    }

    private func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(records) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    // MARK: Derived stats

    var totalSessions: Int { records.count }

    var totalMinutes: Int { Int((Double(records.reduce(0) { $0 + $1.seconds }) / 60).rounded()) }

    /// Days, counting back from today, on which at least one session was logged.
    /// Yesterday still counts so a streak is not lost before the day is over.
    var currentStreak: Int {
        let days = Set(records.map { calendar.startOfDay(for: $0.finishedAt) })
        guard !days.isEmpty else { return 0 }

        let today = calendar.startOfDay(for: .now)
        var cursor = days.contains(today)
            ? today
            : calendar.date(byAdding: .day, value: -1, to: today)!
        guard days.contains(cursor) else { return 0 }

        var streak = 0
        while days.contains(cursor) {
            streak += 1
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor)!
        }
        return streak
    }

    var bestStreak: Int {
        let days = Set(records.map { calendar.startOfDay(for: $0.finishedAt) }).sorted()
        guard !days.isEmpty else { return 0 }

        var best = 1
        var run = 1
        for (previous, day) in zip(days, days.dropFirst()) {
            if calendar.date(byAdding: .day, value: 1, to: previous) == day {
                run += 1
                best = max(best, run)
            } else {
                run = 1
            }
        }
        return best
    }

    /// Mean motion-check score across sessions that captured one.
    var averageExecution: Double? {
        let scored = records.compactMap(\.executionScore)
        guard !scored.isEmpty else { return nil }
        return scored.reduce(0, +) / Double(scored.count)
    }

    var minutesThisWeek: Int {
        guard let week = calendar.dateInterval(of: .weekOfYear, for: .now) else { return 0 }
        let seconds = records
            .filter { week.contains($0.finishedAt) }
            .reduce(0) { $0 + $1.seconds }
        return Int((Double(seconds) / 60).rounded())
    }

    var sessionsThisWeek: Int {
        guard let week = calendar.dateInterval(of: .weekOfYear, for: .now) else { return 0 }
        return records.filter { week.contains($0.finishedAt) }.count
    }

    func sessionCount(on day: Date) -> Int {
        let start = calendar.startOfDay(for: day)
        return records.filter { calendar.isDate($0.finishedAt, inSameDayAs: start) }.count
    }

    /// Muscle groups ranked by how often they appear in logged sessions.
    var muscleTally: [(muscle: MuscleGroup, count: Int)] {
        var tally: [MuscleGroup: Int] = [:]
        for record in records {
            for muscle in record.muscleGroups { tally[muscle, default: 0] += 1 }
        }
        return tally
            .map { (muscle: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }

    /// The groups trained least often — what the builder should bias toward.
    var neglectedMuscles: [MuscleGroup] {
        guard !records.isEmpty else { return [] }
        let trained = Set(records.flatMap(\.muscleGroups))
        let untouched = MuscleGroup.allCases.filter { !trained.contains($0) && $0 != .fullBody }
        guard untouched.count < 4 else { return Array(untouched.prefix(4)) }
        let leastTrained = muscleTally.suffix(4).map(\.muscle)
        return Array((untouched + leastTrained).prefix(4))
    }

    /// The last `weeks` weeks of daily activity, oldest first, for the grid.
    func activityGrid(weeks: Int = 12) -> [[Date]] {
        let today = calendar.startOfDay(for: .now)
        // Walk back to the start of the week containing today.
        let weekday = calendar.component(.weekday, from: today)
        let offsetToWeekStart = (weekday - calendar.firstWeekday + 7) % 7
        guard let thisWeekStart = calendar.date(byAdding: .day, value: -offsetToWeekStart, to: today),
              let firstDay = calendar.date(byAdding: .day, value: -7 * (weeks - 1), to: thisWeekStart)
        else { return [] }

        return (0..<weeks).compactMap { week in
            guard let weekStart = calendar.date(byAdding: .day, value: 7 * week, to: firstDay)
            else { return nil }
            return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
        }
    }
}
