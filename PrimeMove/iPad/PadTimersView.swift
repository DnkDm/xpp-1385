import SwiftUI
import UIKit

// MARK: - Timers

/// Wide: interval presets and the stopwatch sit side by side.
/// Narrow: the phone's segmented toggle.
struct PadTimersView: View {
    @Environment(PadSessionPresenter.self) private var presenter
    @State private var stopwatch = Stopwatch()
    @State private var mode: TimersView.Mode = .intervals

    var body: some View {
        WidthReader { width in
            let w = PadMetrics.contentWidth(for: width)
            PadPage(asset: "bg_home") {
                VStack(alignment: .leading, spacing: 32) {
                    PadPageHeader(eyebrow: "Train by the clock", title: "Timers",
                                  blurb: "Interval engines for conditioning and stretch holds, plus a precision stopwatch.")
                    if w >= PadMetrics.twoPaneBreakpoint {
                        HStack(alignment: .top, spacing: 36) {
                            intervals.frame(maxWidth: .infinity, alignment: .leading)
                            PadStopwatchPanel(stopwatch: stopwatch)
                                .frame(width: min(460, (w * 0.42).rounded()))
                        }
                    } else {
                        HStack(spacing: 8) {
                            ForEach(TimersView.Mode.allCases, id: \.self) { m in
                                FilterChip(text: m.rawValue, selected: mode == m) { Cue.tap(); mode = m }
                            }
                        }
                        if mode == .intervals { intervals } else { PadStopwatchPanel(stopwatch: stopwatch) }
                    }
                    FooterNote()
                }
            }
        }
    }

    private var intervals: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(eyebrow: "Work / rest", title: "Interval Presets",
                          trailing: "\(Library.intervalPresets.count)")
            VStack(spacing: 12) {
                ForEach(Library.intervalPresets) { preset in
                    Button { presenter.start(preset) } label: {
                        IntervalPresetCard(preset: preset).padHover()
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(preset.title), \(preset.rounds) rounds")
                    .accessibilityHint("Starts the interval timer")
                }
            }
        }
    }
}

// MARK: - Stopwatch panel

struct PadStopwatchPanel: View {
    let stopwatch: Stopwatch

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(eyebrow: "Precision", title: "Stopwatch")
            VStack(spacing: 18) {
                Text(mmssMillis(stopwatch.elapsed))
                    .font(.tick(64)).foregroundStyle(Theme.textPrimary)
                    .contentTransition(.numericText())
                    .lineLimit(1).minimumScaleFactor(0.5)
                    .padding(.vertical, 30).padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                    .background(Theme.surface)
                    .clipShape(CutCorner(cut: 18, corners: [.topRight, .bottomLeft]))
                    .overlay(CutCorner(cut: 18, corners: [.topRight, .bottomLeft]).stroke(Theme.stroke, lineWidth: 1))
                    .accessibilityLabel("Stopwatch \(mmssMillis(stopwatch.elapsed))")

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
}

// MARK: - Interval runner (full screen)

struct PadIntervalRunnerView: View {
    @State var engine: IntervalEngine
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geo in
            let ring = min(360, max(150, (geo.size.height * 0.34).rounded()))
            let short = geo.size.height < 600
            ZStack {
                Theme.canvas.ignoresSafeArea()
                engine.phaseColor.opacity(0.14).ignoresSafeArea()
                    .animation(.easeInOut, value: engine.phase)

                VStack(spacing: 0) {
                    HStack {
                        PadSquareButton(systemImage: "xmark", shortcut: KeyboardShortcut(.escape, modifiers: [])) {
                            Cue.tap(); dismiss()
                        }
                        .accessibilityLabel("Close")
                        Spacer()
                        Text(engine.preset.title).eyebrow(engine.phaseColor)
                        Spacer()
                        PadSquareButton(systemImage: "arrow.counterclockwise",
                                        shortcut: KeyboardShortcut("r", modifiers: []), action: engine.reset)
                            .accessibilityLabel("Reset")
                    }
                    .padding(.horizontal, 28).padding(.vertical, 16)

                    Spacer()

                    Text(engine.phase == .done ? "Complete" : engine.phaseLabel)
                        .font(.display(short ? 32 : 44)).foregroundStyle(engine.phaseColor).textCase(.uppercase)

                    ZStack {
                        AngularRing(progress: engine.progress, accent: engine.phaseColor)
                            .frame(width: ring, height: ring)
                        VStack(spacing: 4) {
                            Text(engine.phase == .done ? "✓" : mmss(engine.remaining))
                                .font(.tick(ring * 0.28)).foregroundStyle(Theme.textPrimary)
                                .contentTransition(.numericText())
                            if engine.phase != .done {
                                Text("Round \(engine.round) / \(engine.preset.rounds)").eyebrow(Theme.textMuted)
                            }
                        }
                    }
                    .padding(.vertical, short ? 10 : 28)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(engine.phase == .done
                                        ? "Complete"
                                        : "\(engine.phaseLabel), \(engine.remaining) seconds, round \(engine.round) of \(engine.preset.rounds)")

                    roundDots

                    Spacer()

                    Group {
                        if engine.phase == .done {
                            VStack(spacing: 12) {
                                PrimaryButton(title: "Done", systemImage: "checkmark", accent: engine.phaseColor) { dismiss() }
                                    .keyboardShortcut(.return, modifiers: [])
                                GhostButton(title: "Repeat", systemImage: "arrow.counterclockwise", action: engine.reset)
                            }
                        } else {
                            PadPlayButton(isRunning: engine.isRunning, accent: engine.phaseColor, size: short ? 76 : 104,
                                          shortcut: KeyboardShortcut(.space, modifiers: []), action: engine.toggle)
                                .padding(.vertical, short ? 2 : 8)
                        }
                    }
                    .frame(maxWidth: 460)
                    .padding(.horizontal, 28)
                    .padding(.bottom, short ? 16 : 40)
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                Color.clear.frame(height: geo.safeAreaInsets.top < 1 ? 36 : 0)
            }
        }
        .statusBarHidden(true)
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false; engine.pause() }
    }

    private var roundDots: some View {
        HStack(spacing: 6) {
            ForEach(1...max(1, engine.preset.rounds), id: \.self) { r in
                Rectangle()
                    .fill(r < engine.round || engine.phase == .done ? engine.phaseColor
                          : r == engine.round ? engine.phaseColor.opacity(0.55) : Theme.surfaceHi)
                    .frame(width: 22, height: 6)
                    .clipShape(CutCorner(cut: 3, corners: [.topRight, .bottomLeft]))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: engine.round)
        .accessibilityHidden(true)
    }
}
