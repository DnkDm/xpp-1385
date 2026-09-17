import SwiftUI

/// Live motion readout shown under the timer while a session runs.
/// Hidden entirely on hardware without motion sensors, or when switched off.
struct MotionStrip: View {
    let coach: MotionCoach
    /// Opens the explainer sheet describing how the reading works.
    var onExplain: () -> Void

    private let shape = CutCorner(cut: 10, corners: [.topRight, .bottomLeft])

    private var accent: Color { coach.expectation.accent }

    var body: some View {
        VStack(spacing: 10) {
            headline
            meter
            footer
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(shape.fill(Theme.surface.opacity(0.85)))
        .overlay(shape.stroke(coach.isOffTarget ? Theme.signal.opacity(0.6) : Theme.stroke,
                              lineWidth: 1))
        .animation(.snappy(duration: 0.25), value: coach.isOffTarget)
    }

    private var headline: some View {
        HStack(spacing: 9) {
            Image(systemName: coach.expectation.icon)
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(accent)
            Text(coach.isOffTarget ? coach.expectation.nudge : coach.expectation.title)
                .font(.system(size: 13, weight: .heavy))
                .tracking(0.6)
                .textCase(.uppercase)
                .foregroundStyle(coach.isOffTarget ? Theme.signal : Theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 0)
            Button {
                Cue.tap()
                onExplain()
            } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.textMuted)
                    .padding(6)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("How motion check works")
        }
    }

    /// The live meter. For a hold, the safe zone is the low end, so the band
    /// that means "good" is drawn at the left rather than filling to the right.
    private var meter: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle().fill(Theme.surfaceHi)

                if coach.expectation == .hold {
                    Rectangle()
                        .fill(accent.opacity(0.18))
                        .frame(width: geo.size.width * 0.12)
                } else {
                    Rectangle()
                        .fill(accent.opacity(0.18))
                        .frame(width: geo.size.width * (1 - lowerBoundFraction))
                        .offset(x: geo.size.width * lowerBoundFraction)
                }

                Rectangle()
                    .fill(coach.isOffTarget ? Theme.signal : accent)
                    .frame(width: max(3, geo.size.width * coach.level))
                    .shadow(color: accent.opacity(0.5), radius: 6)
                    .animation(.linear(duration: 0.08), value: coach.level)
            }
        }
        .frame(height: 10)
        .clipShape(CutCorner(cut: 5, corners: [.topRight, .bottomLeft]))
    }

    /// Where the "moving" threshold sits on a meter that tops out at 0.8 g.
    private var lowerBoundFraction: Double {
        min(0.9, coach.expectation.lowerBound / 0.8)
    }

    private var footer: some View {
        HStack(spacing: 14) {
            if coach.expectation.countsReps {
                Label("\(coach.reps) reps", systemImage: "number")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer(minLength: 0)
            if coach.hasReading {
                Text("\(coach.compliance.executionPercent) on target")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(coach.compliance.executionColor)
            } else {
                Text("Get into position")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.textMuted)
            }
        }
    }
}

// MARK: - Completion summary

/// Execution result shown on the finish screen when motion data was captured.
struct ExecutionSummary: View {
    let score: Double

    private let shape = CutCorner(cut: 10, corners: [.topRight, .bottomLeft])

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(score.executionColor)
                .frame(width: 44, height: 44)
                .background(CutCorner(cut: 8, corners: [.topRight, .bottomLeft])
                    .fill(score.executionColor.opacity(0.14)))
            VStack(alignment: .leading, spacing: 2) {
                Text("Motion check").eyebrow(Theme.textMuted)
                Text("\(score.executionGrade) · \(score.executionPercent) on target")
                    .font(.heavy(17))
                    .foregroundStyle(Theme.textPrimary)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14).padding(.vertical, 11)
        .background(shape.fill(Theme.surface))
        .overlay(shape.stroke(Theme.stroke, lineWidth: 1))
    }
}


// MARK: - Explainer

/// Tells the user what Motion Check needs from them and what it reads.
/// Shown automatically the first time, and from the info button after that.
struct MotionCheckIntro: View {
    /// Keeps the feature on and closes the sheet.
    var onKeep: () -> Void
    /// Switches the feature off for every future session.
    var onTurnOff: () -> Void

    var body: some View {
        ZStack {
            ScreenBackground(asset: nil, dim: 1)
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    heading
                    points
                    privacyNote
                }
                .padding(.horizontal, 22)
                .padding(.top, 28)
                .padding(.bottom, 24)
            }
            .safeAreaInset(edge: .bottom) { buttons }
        }
        .preferredColorScheme(.dark)
    }

    private var heading: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 34, weight: .black))
                .foregroundStyle(Theme.volt)
            Text("Motion check").eyebrow(Theme.volt)
            Text("Your phone checks\nthe movement")
                .font(.display(34))
                .foregroundStyle(Theme.textPrimary)
                .textCase(.uppercase)
                .lineSpacing(-3)
            Text("During a session the app watches the phone's own motion and tells you whether the movement on screen is actually happening.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private var points: some View {
        VStack(spacing: 10) {
            row(icon: "hand.raised.fill",
                title: "Hold the phone or pocket it",
                detail: "Keep it in your hand, an armband or a trouser pocket. Left on a bench or the floor it cannot read you, and the session will simply show nothing on target.")
            row(icon: "gyroscope",
                title: "What it reads",
                detail: "Only the built-in accelerometer and gyroscope, thirty readings a second. No camera, no microphone, no location.")
            row(icon: "figure.run",
                title: "What it does with it",
                detail: "Each reading is compared against what the current movement should feel like. Jumping jacks should be rhythmic, a stretch should be still. The raw signal is thrown away and only one number per movement is kept.")
            row(icon: "hand.tap.fill",
                title: "It nudges you",
                detail: "A short tap if you have clearly stopped moving mid-movement, and a count of your reps on the faster exercises.")
        }
    }

    private var privacyNote: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "lock.fill")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Theme.cyan)
            Text("Everything stays on this phone. No motion data is uploaded, shared or stored beyond the score in your own log, and you can switch this off at any time.")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(14)
        .background(CutCorner(cut: 10, corners: [.topRight, .bottomLeft])
            .fill(Theme.cyan.opacity(0.08)))
        .overlay(CutCorner(cut: 10, corners: [.topRight, .bottomLeft])
            .stroke(Theme.cyan.opacity(0.28), lineWidth: 1))
    }

    private func row(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 13) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Theme.volt)
                .frame(width: 40, height: 40)
                .background(CutCorner(cut: 8, corners: [.topRight, .bottomLeft])
                    .fill(Theme.volt.opacity(0.12)))
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.heavy(16)).foregroundStyle(Theme.textPrimary)
                Text(detail)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(CutCorner(cut: 10, corners: [.topRight, .bottomLeft]).fill(Theme.surface))
        .overlay(CutCorner(cut: 10, corners: [.topRight, .bottomLeft])
            .stroke(Theme.stroke, lineWidth: 1))
    }

    private var buttons: some View {
        VStack(spacing: 0) {
            // A clean fade so scrolled text never shows through the buttons.
            LinearGradient(colors: [.clear, Theme.canvas],
                           startPoint: .top, endPoint: .bottom)
                .frame(height: 36)
            VStack(spacing: 10) {
                PrimaryButton(title: "Got it", systemImage: "checkmark", action: onKeep)
                GhostButton(title: "Turn motion check off", action: onTurnOff)
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 18)
            .padding(.top, 4)
            .background(Theme.canvas)
        }
    }
}
