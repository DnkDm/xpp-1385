import SwiftUI
import UIKit

struct TimersView: View {
    enum Mode: String, CaseIterable { case intervals = "Intervals", stopwatch = "Stopwatch" }
    @State private var mode: Mode = .intervals
    @State private var activePreset: IntervalPreset? = nil
    @State private var stopwatch = Stopwatch()

    var body: some View {
        NavigationStack {
            ZStack {
                ScreenBackground(asset: "bg_home")
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header
                        segmented
                        if mode == .intervals { intervalList } else { stopwatchPanel }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .fullScreenCover(item: $activePreset) { preset in
                IntervalRunnerView(engine: IntervalEngine(preset: preset))
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Train by the clock").eyebrow(Theme.volt)
            Text("Timers")
                .font(.display(42)).foregroundStyle(Theme.textPrimary).textCase(.uppercase)
            Text("Interval engines for conditioning and stretch holds, plus a precision stopwatch.")
                .font(.system(size: 14, weight: .medium)).foregroundStyle(Theme.textSecondary)
        }
    }

    private var segmented: some View {
        HStack(spacing: 8) {
            ForEach(Mode.allCases, id: \.self) { m in
                FilterChip(text: m.rawValue, selected: mode == m) { Cue.tap(); mode = m }
            }
        }
    }

    private var intervalList: some View {
        VStack(spacing: 12) {
            ForEach(Library.intervalPresets) { preset in
                Button { Cue.tap(); activePreset = preset } label: { IntervalPresetCard(preset: preset) }
                    .buttonStyle(.plain)
            }
        }
    }

    private var stopwatchPanel: some View {
        VStack(spacing: 20) {
            Text(mmssMillis(stopwatch.elapsed))
                .font(.tick(58)).foregroundStyle(Theme.textPrimary)
                .contentTransition(.numericText())
                .padding(.vertical, 26)
                .frame(maxWidth: .infinity)
                .background(Theme.surface)
                .clipShape(CutCorner(cut: 18, corners: [.topRight, .bottomLeft]))
                .overlay(CutCorner(cut: 18, corners: [.topRight, .bottomLeft]).stroke(Theme.stroke, lineWidth: 1))

            HStack(spacing: 12) {
                GhostButton(title: stopwatch.isRunning ? "Lap" : "Reset",
                            systemImage: stopwatch.isRunning ? "flag.fill" : "arrow.counterclockwise") {
                    stopwatch.isRunning ? stopwatch.lap() : stopwatch.reset()
                }
                PrimaryButton(title: stopwatch.isRunning ? "Stop" : "Start",
                              systemImage: stopwatch.isRunning ? "pause.fill" : "play.fill",
                              accent: stopwatch.isRunning ? Theme.signal : Theme.volt) {
                    stopwatch.toggle()
                }
            }

            if !stopwatch.laps.isEmpty {
                VStack(spacing: 8) {
                    ForEach(Array(stopwatch.laps.enumerated()), id: \.offset) { i, lap in
                        HStack {
                            Text("Lap \(stopwatch.laps.count - i)")
                                .font(.system(size: 13, weight: .heavy)).tracking(1)
                                .foregroundStyle(Theme.textMuted)
                            Spacer()
                            Text(mmssMillis(lap)).font(.tick(16)).foregroundStyle(Theme.textPrimary)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .background(Theme.surface)
                        .clipShape(CutCorner(cut: 7, corners: [.topRight, .bottomLeft]))
                    }
                }
            }
        }
    }
}

// MARK: - Preset card

struct IntervalPresetCard: View {
    let preset: IntervalPreset
    var body: some View {
        HStack(spacing: 0) {
            Rectangle().fill(preset.accent).frame(width: 5)
            VStack(alignment: .leading, spacing: 4) {
                Text(preset.title)
                    .font(.heavy(21)).foregroundStyle(Theme.textPrimary).textCase(.uppercase)
                Text(preset.subtitle)
                    .font(.system(size: 13, weight: .medium)).foregroundStyle(Theme.textSecondary)
                HStack(spacing: 10) {
                    Text("\(preset.rounds) ROUNDS").foregroundStyle(preset.accent)
                    Text(durationLabel(preset.totalSeconds).uppercased()).foregroundStyle(Theme.textMuted)
                }
                .font(.system(size: 11, weight: .heavy)).tracking(1)
            }
            .padding(.vertical, 16).padding(.leading, 14)
            Spacer()
            Image(systemName: "play.fill")
                .font(.system(size: 16, weight: .black)).foregroundStyle(Theme.canvas)
                .frame(width: 44, height: 44)
                .background(CutCorner(cut: 8, corners: [.topRight, .bottomLeft]).fill(preset.accent))
                .padding(.trailing, 14)
        }
        .background(Theme.surface)
        .clipShape(CutCorner(cut: 14, corners: [.topRight, .bottomLeft]))
        .overlay(CutCorner(cut: 14, corners: [.topRight, .bottomLeft]).stroke(Theme.stroke, lineWidth: 1))
    }
}

// MARK: - Interval runner

struct IntervalRunnerView: View {
    @State var engine: IntervalEngine
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Theme.canvas.ignoresSafeArea()
            engine.phaseColor.opacity(0.14).ignoresSafeArea()
                .animation(.easeInOut, value: engine.phase)

            VStack(spacing: 0) {
                HStack {
                    IconButton(systemImage: "xmark") { Cue.tap(); dismiss() }
                    Spacer()
                    Text(engine.preset.title).eyebrow(engine.phaseColor)
                    Spacer()
                    IconButton(systemImage: "arrow.counterclockwise", action: engine.reset)
                }
                .padding(.horizontal, 18).padding(.vertical, 12)

                Spacer()

                Text(engine.phase == .done ? "Complete" : engine.phaseLabel)
                    .font(.display(34)).foregroundStyle(engine.phaseColor).textCase(.uppercase)

                ZStack {
                    AngularRing(progress: engine.progress, accent: engine.phaseColor)
                        .frame(width: 250, height: 250)
                    VStack(spacing: 2) {
                        Text(engine.phase == .done ? "✓" : mmss(engine.remaining))
                            .font(.tick(64)).foregroundStyle(Theme.textPrimary)
                            .contentTransition(.numericText())
                        if engine.phase != .done {
                            Text("Round \(engine.round) / \(engine.preset.rounds)")
                                .eyebrow(Theme.textMuted)
                        }
                    }
                }
                .padding(.vertical, 24)

                Spacer()

                if engine.phase == .done {
                    VStack(spacing: 12) {
                        PrimaryButton(title: "Done", systemImage: "checkmark", accent: engine.phaseColor) { dismiss() }
                        GhostButton(title: "Repeat", systemImage: "arrow.counterclockwise", action: engine.reset)
                    }
                    .padding(.horizontal, 24)
                } else {
                    Button(action: engine.toggle) {
                        Image(systemName: engine.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 32, weight: .black)).foregroundStyle(Theme.canvas)
                            .frame(width: 92, height: 92)
                            .background(CutCorner(cut: 20, corners: [.topRight, .bottomLeft]).fill(engine.phaseColor))
                            .shadow(color: engine.phaseColor.opacity(0.4), radius: 20, y: 8)
                    }
                    .buttonStyle(.plain)
                }
                Spacer().frame(height: 40)
            }
        }
        .statusBarHidden(true)
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false; engine.pause() }
    }
}
