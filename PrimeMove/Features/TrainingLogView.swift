import SwiftUI

/// Local training history: streak, volume, what you've been training and
/// what you've been skipping. Everything here is read from the device.
struct TrainingLogView: View {
    private var log = TrainingLog.shared

    @State private var confirmClear = false
    @State private var showMotionIntro = false

    @AppStorage("motionCheckEnabled") private var motionCheckEnabled = true
    @AppStorage("motionCheckExplained") private var motionCheckExplained = false

    private let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d MMM"
        return f
    }()

    var body: some View {
        ZStack {
            ScreenBackground(asset: "bg_home", dim: 0.9)
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    header
                    streakBlock
                    motionCheckRow
                    if log.records.isEmpty {
                        emptyState
                    } else {
                        activityBlock
                        balanceBlock
                        historyBlock
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 4)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Log")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            if !log.records.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) {
                        Cue.tap()
                        confirmClear = true
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
        }
        .confirmationDialog("Clear your training history?",
                            isPresented: $confirmClear, titleVisibility: .visible) {
            Button("Delete everything", role: .destructive) { log.clear() }
            Button("Keep it", role: .cancel) { }
        } message: {
            Text("This erases every logged session on this device. It can't be undone.")
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("On this device").eyebrow(Theme.volt)
            Text("Your log")
                .font(.display(40))
                .foregroundStyle(Theme.textPrimary)
                .textCase(.uppercase)
            Text("Every finished session is stored locally. Nothing is uploaded anywhere.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
        }
    }

    // MARK: Streak

    private var streakBlock: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                StatPill(icon: "flame.fill", value: "\(log.currentStreak)",
                         label: "Day streak", accent: Theme.signal)
                StatPill(icon: "trophy.fill", value: "\(log.bestStreak)",
                         label: "Best", accent: Theme.volt)
            }
            HStack(spacing: 10) {
                StatPill(icon: "checkmark.seal.fill", value: "\(log.totalSessions)",
                         label: "Sessions", accent: Theme.cyan)
                StatPill(icon: "clock.fill", value: "\(log.totalMinutes)m",
                         label: "Total time", accent: Theme.violet)
            }
            if let execution = log.averageExecution {
                StatPill(icon: "waveform.path.ecg", value: execution.executionPercent,
                         label: "Avg on target", accent: execution.executionColor)
            }
        }
    }

    // MARK: Motion check

    /// Lets the user read what Motion Check does and switch it on or off.
    private var motionCheckRow: some View {
        let shape = CutCorner(cut: 10, corners: [.topRight, .bottomLeft])
        return Button {
            Cue.tap()
            showMotionIntro = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(motionCheckEnabled ? Theme.volt : Theme.textMuted)
                    .frame(width: 42, height: 42)
                    .background(CutCorner(cut: 7, corners: [.topRight, .bottomLeft])
                        .fill((motionCheckEnabled ? Theme.volt : Theme.textMuted).opacity(0.12)))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Motion check")
                        .font(.heavy(16)).foregroundStyle(Theme.textPrimary)
                    Text(motionCheckEnabled
                         ? "On — hold your phone during a session"
                         : "Off — sessions are not checked")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.textMuted)
                }
                Spacer(minLength: 0)
                Text("How it works")
                    .font(.system(size: 11, weight: .heavy)).tracking(0.8)
                    .textCase(.uppercase)
                    .foregroundStyle(Theme.textSecondary)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(Theme.textMuted)
            }
            .padding(.horizontal, 12).padding(.vertical, 10)
            .background(shape.fill(Theme.surface))
            .overlay(shape.stroke(Theme.stroke, lineWidth: 1))
            .contentShape(shape)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showMotionIntro) {
            MotionCheckIntro(
                onKeep: {
                    motionCheckExplained = true
                    motionCheckEnabled = true
                    showMotionIntro = false
                },
                onTurnOff: {
                    motionCheckExplained = true
                    motionCheckEnabled = false
                    showMotionIntro = false
                })
        }
    }

    // MARK: Activity grid

    private var activityBlock: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(eyebrow: "Last 12 weeks", title: "Consistency",
                          trailing: "\(log.sessionsThisWeek) this week")
            AngledCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 4) {
                        ForEach(Array(log.activityGrid().enumerated()), id: \.offset) { _, week in
                            VStack(spacing: 4) {
                                ForEach(Array(week.enumerated()), id: \.offset) { _, day in
                                    dayCell(day)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)

                    HStack(spacing: 8) {
                        Text("Less").font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Theme.textMuted)
                        ForEach(0..<4) { level in
                            CutCorner(cut: 2, corners: [.topRight, .bottomLeft])
                                .fill(shade(for: level))
                                .frame(width: 12, height: 12)
                        }
                        Text("More").font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Theme.textMuted)
                    }
                }
                .padding(16)
            }
        }
    }

    private func dayCell(_ day: Date) -> some View {
        let count = log.sessionCount(on: day)
        let future = day > Date.now
        return CutCorner(cut: 2, corners: [.topRight, .bottomLeft])
            .fill(future ? Color.white.opacity(0.02) : shade(for: min(count, 3)))
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .accessibilityLabel("\(dayFormatter.string(from: day)): \(count) sessions")
    }

    private func shade(for level: Int) -> Color {
        switch level {
        case 0: Theme.surfaceHi
        case 1: Theme.volt.opacity(0.35)
        case 2: Theme.volt.opacity(0.65)
        default: Theme.volt
        }
    }

    // MARK: Balance

    private var balanceBlock: some View {
        let tally = log.muscleTally
        let top = tally.prefix(6)
        let peak = max(1, tally.first?.count ?? 1)

        return VStack(alignment: .leading, spacing: 14) {
            SectionHeader(eyebrow: "What you train", title: "Balance", accent: Theme.cyan)
            AngledCard {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(top), id: \.muscle) { entry in
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text(entry.muscle.title)
                                    .font(.system(size: 13, weight: .heavy))
                                    .foregroundStyle(Theme.textPrimary)
                                Spacer()
                                Text("\(entry.count)")
                                    .font(.tick(13))
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            AngularProgress(progress: Double(entry.count) / Double(peak),
                                            accent: Theme.cyan, height: 6)
                        }
                    }

                    if !log.neglectedMuscles.isEmpty {
                        Divider().background(Theme.stroke)
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Theme.signal)
                            Text("Under-trained: \(log.neglectedMuscles.map(\.title).joined(separator: ", ")). The builder will prioritise these.")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
                .padding(16)
            }
        }
    }

    // MARK: History

    private var historyBlock: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(eyebrow: "Every session", title: "History",
                          accent: Theme.violet, trailing: "\(log.records.count)")
            VStack(spacing: 8) {
                ForEach(log.records.prefix(40)) { record in
                    HStack(spacing: 12) {
                        Image(systemName: record.source.icon)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Theme.volt)
                            .frame(width: 40, height: 40)
                            .background(CutCorner(cut: 7, corners: [.topRight, .bottomLeft])
                                .fill(Theme.volt.opacity(0.12)))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(record.title)
                                .font(.heavy(16)).foregroundStyle(Theme.textPrimary)
                                .lineLimit(1)
                            Text("\(record.source.label) · \(record.moveCount) moves")
                                .font(.system(size: 11, weight: .heavy)).tracking(0.8)
                                .textCase(.uppercase)
                                .foregroundStyle(Theme.textMuted)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(record.minutes)m")
                                .font(.tick(15)).foregroundStyle(Theme.volt)
                            Text(record.finishedAt, format: .dateTime.day().month(.abbreviated))
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Theme.textMuted)
                        }
                    }
                    .padding(.horizontal, 12).padding(.vertical, 9)
                    .background(CutCorner(cut: 9, corners: [.topRight, .bottomLeft])
                        .fill(Theme.surface))
                    .overlay(CutCorner(cut: 9, corners: [.topRight, .bottomLeft])
                        .stroke(Theme.stroke, lineWidth: 1))
                }
            }
        }
    }

    // MARK: Empty

    private var emptyState: some View {
        AngledCard {
            VStack(spacing: 12) {
                Image(systemName: "chart.bar.doc.horizontal")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(Theme.textMuted)
                Text("Nothing logged yet")
                    .font(.heavy(20)).foregroundStyle(Theme.textPrimary)
                    .textCase(.uppercase)
                Text("Finish a routine and it lands here. Your streak, volume and muscle balance build from there.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(26)
        }
    }
}

// MARK: - Compact streak strip for the home screen

struct StreakStrip: View {
    private var log = TrainingLog.shared

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "flame.fill")
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(log.currentStreak > 0 ? Theme.signal : Theme.textMuted)
            VStack(alignment: .leading, spacing: 1) {
                Text(log.currentStreak > 0
                     ? "\(log.currentStreak) day streak"
                     : "Start a streak")
                    .font(.heavy(16)).foregroundStyle(Theme.textPrimary)
                Text(log.sessionsThisWeek > 0
                     ? "\(log.sessionsThisWeek) sessions · \(log.minutesThisWeek) min this week"
                     : "No sessions logged this week")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.textMuted)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .heavy))
                .foregroundStyle(Theme.textMuted)
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .background(CutCorner(cut: 10, corners: [.topRight, .bottomLeft]).fill(Theme.surface))
        .overlay(CutCorner(cut: 10, corners: [.topRight, .bottomLeft])
            .stroke(Theme.stroke, lineWidth: 1))
    }
}
