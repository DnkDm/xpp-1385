import SwiftUI
import UIKit

// MARK: - Session (full screen)

/// Timed routine runner for iPad. Landscape: photo on the left, timer and
/// controls on the right. Portrait / narrow: one centred column. Space, ←, →
/// and Esc work from a hardware keyboard.
struct PadSessionView: View {
    @State var engine: SessionEngine
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let landscape = size.width > size.height && size.width >= 900
            ZStack {
                Theme.canvas.ignoresSafeArea()
                GeometryReader { bg in
                    Image("bg_session").resizable().scaledToFill()
                        .frame(width: bg.size.width, height: bg.size.height)
                        .clipped()
                        .opacity(0.4)
                        .overlay(Theme.canvas.opacity(0.6))
                }
                .ignoresSafeArea()

                if engine.isComplete {
                    CompletionView(engine: engine, onDone: { dismiss() })
                        .frame(maxWidth: 560)
                        .transition(.opacity)
                } else if landscape {
                    landscapeLayout(size).transition(.opacity)
                } else {
                    portraitLayout(size).transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.35), value: engine.isComplete)
            .animation(.easeInOut(duration: 0.3), value: engine.index)
            // No status bar (hidden, or a windowed scene): keep the top bar clear
            // of the window controls and give the layout some air.
            .safeAreaInset(edge: .top, spacing: 0) {
                Color.clear.frame(height: geo.safeAreaInsets.top < 1 ? 36 : 0)
            }
        }
        .statusBarHidden(true)
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            engine.start()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            engine.pause()
        }
    }

    // MARK: Landscape

    private func landscapeLayout(_ size: CGSize) -> some View {
        let inset: CGFloat = 36
        let gap: CGFloat = 40
        let contentWidth = min(size.width - inset * 2, 1320)
        let photoWidth = ((contentWidth - gap) * 0.44).rounded(.down)
        let short = size.height < 600          // windowed / very flat scenes
        return VStack(spacing: 0) {
            topBar
            HStack(alignment: .top, spacing: gap) {
                photo
                    .frame(width: photoWidth)
                    .frame(maxHeight: .infinity)
                VStack(spacing: 0) {
                    ViewThatFits(in: .vertical) {
                        info(ring: 300, showUpNext: true)
                        info(ring: 240, showUpNext: false)
                        info(ring: 190, showUpNext: false)
                        infoRow(ring: 150)
                        infoRow(ring: 120)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    if !short {
                        PadStepStrip(engine: engine)
                            .padding(.bottom, 14)
                    }
                    controls(compact: short)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.top, short ? 10 : 20)
            .padding(.bottom, short ? 8 : 20)
        }
        .frame(maxWidth: contentWidth)
        .padding(.horizontal, inset)
    }

    private func info(ring: CGFloat, showUpNext: Bool) -> some View {
        VStack(spacing: 18) {
            exerciseTitle(size: 44)
            timerRing(ring)
            cueCard
            if showUpNext { upNext }
        }
    }

    /// Flattest variant: the ring sits beside the cue so it fits a short window.
    private func infoRow(ring: CGFloat) -> some View {
        VStack(spacing: 12) {
            exerciseTitle(size: 34)
            HStack(alignment: .center, spacing: 20) {
                timerRing(ring)
                cueCard
            }
        }
    }

    private func exerciseTitle(size: CGFloat) -> some View {
        Text(engine.exercise.name)
            .font(.display(size)).foregroundStyle(Theme.textPrimary)
            .textCase(.uppercase).lineSpacing(-3)
            .multilineTextAlignment(.center)
            .lineLimit(2).minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity)
    }

    // MARK: Portrait

    private func portraitLayout(_ size: CGSize) -> some View {
        let inset: CGFloat = 28
        let contentWidth = min(size.width - inset * 2, 680)
        let photoHeight = min(max((size.height * 0.36).rounded(), 240), 500)
        return VStack(spacing: 0) {
            topBar
            ScrollView {
                VStack(spacing: 22) {
                    photo.frame(height: photoHeight)
                    VStack(spacing: 10) {
                        Text(engine.exercise.name)
                            .font(.display(38)).foregroundStyle(Theme.textPrimary)
                            .textCase(.uppercase).multilineTextAlignment(.center)
                        timerRing(min(240, (size.width * 0.32).rounded()))
                    }
                    cueCard
                    upNext
                    PadStepStrip(engine: engine)
                }
                .padding(.top, 16)
                .padding(.bottom, 170)   // content runs under the floating controls
            }
            .mask(
                VStack(spacing: 0) {
                    Rectangle().fill(.black)
                    LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                        .frame(height: 150)
                }
                .ignoresSafeArea()
            )
        }
        .frame(maxWidth: contentWidth)
        .padding(.horizontal, inset)
        .overlay(alignment: .bottom) { controls.padding(.bottom, 16) }
    }

    // MARK: Pieces

    private var topBar: some View {
        HStack(spacing: 14) {
            PadSquareButton(systemImage: "xmark", shortcut: KeyboardShortcut(.escape, modifiers: [])) {
                Cue.tap(); dismiss()
            }
            .accessibilityLabel("End session")
            VStack(alignment: .leading, spacing: 2) {
                Text(engine.title).eyebrow(engine.accent)
                Text("Move \(engine.index + 1) of \(engine.steps.count)")
                    .font(.heavy(17)).foregroundStyle(Theme.textPrimary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("Remaining").eyebrow(Theme.textMuted)
                Text(mmss(engine.totalSeconds - engine.elapsed))
                    .font(.tick(22)).foregroundStyle(Theme.textSecondary)
                    .contentTransition(.numericText())
            }
        }
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) {
            AngularProgress(progress: engine.totalProgress, accent: engine.accent, height: 5)
        }
    }

    private var photo: some View {
        let shape = CutCorner(cut: 22, corners: [.topRight, .bottomLeft])
        return Color.clear
            // Photos are 3:4 portraits — anchor to the top so a wide crop keeps the head in frame.
            .overlay(alignment: .top) { Image(engine.exercise.asset).resizable().scaledToFill() }
            .overlay {
                LinearGradient(colors: [Theme.canvas.opacity(0.5), .clear, Theme.canvas.opacity(0.6)],
                               startPoint: .top, endPoint: .bottom)
            }
            .overlay(alignment: .topLeading) {
                Tag(text: engine.exercise.kind.label, color: engine.accent, filled: true).padding(16)
            }
            .clipShape(shape)
            .overlay(shape.stroke(engine.accent.opacity(0.45), lineWidth: 1.5))
            .shadow(color: engine.accent.opacity(0.18), radius: 24, y: 10)
            .id(engine.exercise.id)
            .transition(.opacity)
            .accessibilityHidden(true)
    }

    private func timerRing(_ ring: CGFloat) -> some View {
        ZStack {
            AngularRing(progress: engine.stepProgress, accent: engine.accent)
                .frame(width: ring, height: ring)
            VStack(spacing: 0) {
                Text(mmss(engine.remaining))
                    .font(.tick(max(30, (ring * 0.28).rounded()))).foregroundStyle(Theme.textPrimary)
                    .contentTransition(.numericText())
                if ring >= 150 { Text("seconds").eyebrow(Theme.textMuted) }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(engine.remaining) seconds remaining")
    }

    private var cueCard: some View {
        HStack(spacing: 14) {
            Rectangle().fill(engine.accent).frame(width: 4)
                .clipShape(CutCorner(cut: 2, corners: [.topRight, .bottomLeft]))
            Text(engine.exercise.cue)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.textSecondary)
                .lineSpacing(3)
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface)
        .clipShape(CutCorner(cut: 10, corners: [.topRight, .bottomLeft]))
    }

    @ViewBuilder private var upNext: some View {
        if let next = engine.next {
            HStack(spacing: 12) {
                Text("Up Next").eyebrow(Theme.textMuted)
                Image(next.exercise.asset)
                    .resizable().scaledToFill().frame(width: 44, height: 44).clipped()
                    .clipShape(CutCorner(cut: 5, corners: [.topRight, .bottomLeft]))
                Text(next.exercise.name)
                    .font(.heavy(16)).foregroundStyle(Theme.textPrimary)
                Spacer()
                Text(durationLabel(next.seconds))
                    .font(.tick(15)).foregroundStyle(Theme.textSecondary)
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surfaceHi.opacity(0.6))
            .clipShape(CutCorner(cut: 8, corners: [.topRight, .bottomLeft]))
        }
    }

    private var controls: some View { controls(compact: false) }

    private func controls(compact: Bool) -> some View {
        HStack(spacing: compact ? 18 : 24) {
            PadSquareButton(systemImage: "backward.fill", size: compact ? 48 : 56, accent: Theme.textSecondary,
                            shortcut: KeyboardShortcut(.leftArrow, modifiers: []), action: engine.back)
                .accessibilityLabel("Back")
            PadPlayButton(isRunning: engine.isRunning, accent: engine.accent, size: compact ? 72 : 96,
                          shortcut: KeyboardShortcut(.space, modifiers: []), action: engine.toggle)
            PadSquareButton(systemImage: "forward.fill", size: compact ? 48 : 56, accent: Theme.textSecondary,
                            shortcut: KeyboardShortcut(.rightArrow, modifiers: []), action: engine.skip)
                .accessibilityLabel("Skip")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, compact ? 6 : 12)
    }
}

// MARK: - Step strip

/// Thumbnails of the whole sequence: done ones ticked, the current one framed.
struct PadStepStrip: View {
    let engine: SessionEngine

    private let shape = CutCorner(cut: 7, corners: [.topRight, .bottomLeft])

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(engine.steps.enumerated()), id: \.offset) { i, step in
                        thumb(step, done: i < engine.index, current: i == engine.index)
                            .id(i)
                    }
                }
                .padding(.vertical, 2)
                .padding(.horizontal, 2)
            }
            .onChange(of: engine.index) { _, new in
                withAnimation(.easeInOut(duration: 0.3)) { proxy.scrollTo(new, anchor: .center) }
            }
            .onAppear { proxy.scrollTo(engine.index, anchor: .center) }
        }
        .frame(height: 58)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Sequence, move \(engine.index + 1) of \(engine.steps.count)")
    }

    private func thumb(_ step: RoutineStep, done: Bool, current: Bool) -> some View {
        Color.clear
            .frame(width: 52, height: 52)
            .overlay { Image(step.exercise.asset).resizable().scaledToFill() }
            .overlay { if done { Theme.canvas.opacity(0.62) } }
            .overlay(alignment: .bottomTrailing) {
                if done {
                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(Theme.canvas)
                        .padding(3)
                        .background(engine.accent)
                        .padding(4)
                }
            }
            .clipShape(shape)
            .overlay(shape.stroke(current ? engine.accent : Theme.stroke, lineWidth: current ? 2 : 1))
            .opacity(done || current ? 1 : 0.7)
    }
}

// MARK: - Buttons

/// Square icon button with an optional hardware-keyboard shortcut.
struct PadSquareButton: View {
    var systemImage: String
    var size: CGFloat = 48
    var accent: Color = Theme.textPrimary
    var shortcut: KeyboardShortcut? = nil
    var action: () -> Void

    var body: some View {
        let shape = CutCorner(cut: size * 0.18, corners: [.topRight, .bottomLeft])
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: size * 0.36, weight: .bold))
                .foregroundStyle(accent)
                .frame(width: size, height: size)
                .background(shape.fill(Theme.surfaceHi))
                .overlay(shape.stroke(Theme.stroke, lineWidth: 1))
                .contentShape(shape)
                .padHover()
        }
        .buttonStyle(.plain)
        .keyboardShortcut(shortcut)
    }
}

/// The big play / pause control.
struct PadPlayButton: View {
    var isRunning: Bool
    var accent: Color
    var size: CGFloat = 96
    var shortcut: KeyboardShortcut? = nil
    var action: () -> Void

    var body: some View {
        let shape = CutCorner(cut: size * 0.21, corners: [.topRight, .bottomLeft])
        Button(action: action) {
            Image(systemName: isRunning ? "pause.fill" : "play.fill")
                .font(.system(size: size * 0.34, weight: .black))
                .foregroundStyle(Theme.canvas)
                .frame(width: size, height: size)
                .background(shape.fill(accent))
                .shadow(color: accent.opacity(0.4), radius: 22, y: 8)
                .contentShape(shape)
                .padHover()
        }
        .buttonStyle(.plain)
        .keyboardShortcut(shortcut)
        .accessibilityLabel(isRunning ? "Pause" : "Play")
    }
}
