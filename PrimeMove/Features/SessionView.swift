import SwiftUI
import UIKit

struct SessionView: View {
    @State var engine: SessionEngine
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Theme.canvas.ignoresSafeArea()
            GeometryReader { geo in
                Image("bg_session").resizable().scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .opacity(0.4)
                    .overlay(Theme.canvas.opacity(0.6))
            }
            .ignoresSafeArea()

            if engine.isComplete {
                CompletionView(engine: engine, onDone: { dismiss() })
                    .transition(.opacity)
            } else {
                activeSession
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: engine.isComplete)
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            engine.start()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            engine.pause()
        }
        .statusBarHidden(true)
    }

    // MARK: Active

    private var activeSession: some View {
        VStack(spacing: 0) {
            topBar
            ScrollView {
                VStack(spacing: 20) {
                    exerciseImage
                    timerBlock
                    cueBlock
                    upNext
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 150)   // let content run under the controls
            }
            // Content dissolves as it passes behind the control bar.
            .mask(
                VStack(spacing: 0) {
                    Rectangle().fill(.black)
                    LinearGradient(colors: [.black, .clear],
                                   startPoint: .top, endPoint: .bottom)
                        .frame(height: 140)
                }
                .ignoresSafeArea()
            )
        }
        // Controls float above the fading content.
        .overlay(alignment: .bottom) { controls }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            IconButton(systemImage: "xmark", action: { Cue.tap(); dismiss() })
            VStack(alignment: .leading, spacing: 2) {
                Text(engine.title).eyebrow(engine.accent)
                Text("Move \(engine.index + 1) of \(engine.steps.count)")
                    .font(.heavy(16)).foregroundStyle(Theme.textPrimary)
            }
            Spacer()
            Text(mmss(engine.totalSeconds - engine.elapsed))
                .font(.tick(20)).foregroundStyle(Theme.textSecondary)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            AngularProgress(progress: engine.totalProgress, accent: engine.accent, height: 5)
                .padding(.horizontal, 18)
        }
    }

    private var exerciseImage: some View {
        ZStack(alignment: .topLeading) {
            Image(engine.exercise.asset)
                .resizable().scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .clipped()
            LinearGradient(colors: [Theme.canvas.opacity(0.5), .clear, Theme.canvas.opacity(0.6)],
                           startPoint: .top, endPoint: .bottom)
            Tag(text: engine.exercise.kind.label, color: engine.accent, filled: true)
                .padding(14)
        }
        .frame(height: 300)
        .clipShape(CutCorner(cut: 20, corners: [.topRight, .bottomLeft]))
        .overlay(CutCorner(cut: 20, corners: [.topRight, .bottomLeft])
            .stroke(engine.accent.opacity(0.45), lineWidth: 1.5))
        .shadow(color: engine.accent.opacity(0.18), radius: 24, y: 10)
    }

    private var timerBlock: some View {
        VStack(spacing: 6) {
            Text(engine.exercise.name)
                .font(.display(30)).foregroundStyle(Theme.textPrimary)
                .textCase(.uppercase).multilineTextAlignment(.center)

            ZStack {
                AngularRing(progress: engine.stepProgress, accent: engine.accent)
                    .frame(width: 188, height: 188)
                VStack(spacing: 0) {
                    Text(mmss(engine.remaining))
                        .font(.tick(52)).foregroundStyle(Theme.textPrimary)
                        .contentTransition(.numericText())
                    Text("seconds").eyebrow(Theme.textMuted)
                }
            }
            .padding(.top, 4)
        }
    }

    private var cueBlock: some View {
        HStack(spacing: 12) {
            Rectangle().fill(engine.accent).frame(width: 4)
                .clipShape(CutCorner(cut: 2, corners: [.topRight, .bottomLeft]))
            Text(engine.exercise.cue)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.textSecondary)
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface)
        .clipShape(CutCorner(cut: 10, corners: [.topRight, .bottomLeft]))
    }

    @ViewBuilder private var upNext: some View {
        if let next = engine.next {
            HStack(spacing: 12) {
                Text("Up Next").eyebrow(Theme.textMuted)
                Image(next.exercise.asset)
                    .resizable().scaledToFill().frame(width: 40, height: 40).clipped()
                    .clipShape(CutCorner(cut: 5, corners: [.topRight, .bottomLeft]))
                Text(next.exercise.name)
                    .font(.heavy(15)).foregroundStyle(Theme.textPrimary)
                Spacer()
                Text(durationLabel(next.seconds))
                    .font(.tick(14)).foregroundStyle(Theme.textSecondary)
            }
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(Theme.surfaceHi.opacity(0.6))
            .clipShape(CutCorner(cut: 8, corners: [.topRight, .bottomLeft]))
        }
    }

    private var controls: some View {
        HStack(spacing: 16) {
            IconButton(systemImage: "backward.fill", accent: Theme.textSecondary, action: engine.back)
            Button(action: engine.toggle) {
                Image(systemName: engine.isRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: 30, weight: .black))
                    .foregroundStyle(Theme.canvas)
                    .frame(width: 84, height: 84)
                    .background(CutCorner(cut: 18, corners: [.topRight, .bottomLeft]).fill(engine.accent))
                    .shadow(color: engine.accent.opacity(0.4), radius: 20, y: 8)
            }
            .buttonStyle(.plain)
            IconButton(systemImage: "forward.fill", accent: Theme.textSecondary, action: engine.skip)
        }
        .padding(.vertical, 16)
    }
}

// MARK: - Angular progress ring

struct AngularRing: View {
    var progress: Double
    var accent: Color
    var body: some View {
        ZStack {
            Circle().stroke(Theme.surfaceHi, lineWidth: 12)
            Circle()
                .trim(from: 0, to: max(0.001, min(1, progress)))
                .stroke(accent, style: StrokeStyle(lineWidth: 12, lineCap: .butt))
                .rotationEffect(.degrees(-90))
                .shadow(color: accent.opacity(0.6), radius: 8)
                .animation(.linear(duration: 0.25), value: progress)
        }
    }
}

// MARK: - Completion

struct CompletionView: View {
    let engine: SessionEngine
    var onDone: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 72, weight: .black))
                .foregroundStyle(engine.accent)
                .shadow(color: engine.accent.opacity(0.5), radius: 20)
            VStack(spacing: 6) {
                Text("Primed").font(.display(48)).foregroundStyle(Theme.textPrimary).textCase(.uppercase)
                Text("You're warm and ready to move.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
            }
            HStack(spacing: 10) {
                StatPill(icon: "clock.fill", value: mmss(engine.totalSeconds), label: "Time", accent: engine.accent)
                StatPill(icon: "figure.run", value: "\(engine.steps.count)", label: "Moves", accent: engine.accent)
                StatPill(icon: "checkmark", value: "100%", label: "Done", accent: engine.accent)
            }
            Spacer()
            VStack(spacing: 12) {
                PrimaryButton(title: "Done", systemImage: "checkmark", accent: engine.accent, action: onDone)
                GhostButton(title: "Repeat", systemImage: "arrow.counterclockwise", action: engine.restart)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 30)
    }
}
