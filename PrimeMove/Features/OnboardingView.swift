import SwiftUI

// MARK: - Metrics

private enum OnboardMetrics {
    /// The widest a line of onboarding copy is allowed to get.
    static let columnWidth: CGFloat = 620
}

// MARK: - A single page

/// One screen of the first-run tour. Content is data so the pages stay
/// consistent and the layout code is written once.
private struct OnboardPage: Identifiable {
    let id: Int
    let asset: String
    let accent: Color
    let eyebrow: String
    let title: String
    let blurb: String
    /// Short feature lines shown as a stack of rows.
    let points: [(icon: String, text: String)]
    /// Optional numbers band, used on the opening page.
    let stats: [(value: String, label: String)]

    init(id: Int, asset: String, accent: Color, eyebrow: String, title: String,
         blurb: String,
         points: [(icon: String, text: String)] = [],
         stats: [(value: String, label: String)] = []) {
        self.id = id
        self.asset = asset
        self.accent = accent
        self.eyebrow = eyebrow
        self.title = title
        self.blurb = blurb
        self.points = points
        self.stats = stats
    }
}

private let onboardPages: [OnboardPage] = [
    OnboardPage(
        id: 0, asset: "banner_football", accent: Theme.volt,
        eyebrow: "Welcome to PrimeMove",
        title: "Warm up.\nMove sharp.",
        blurb: "Everything you need before you train, and the help you need when something goes wrong. All of it works offline.",
        stats: [
            (value: "\(Library.routines.count)", label: "Routines"),
            (value: "\(Library.exercises.count)", label: "Movements"),
            (value: "\(Library.miniWarmups.count)", label: "Mini moves"),
            (value: "\(Library.intervalPresets.count)", label: "Timers"),
            (value: "\(EmergencyLibrary.protocols.count)", label: "First-aid guides")
        ]),

    OnboardPage(
        id: 1, asset: "banner_quick", accent: Theme.volt,
        eyebrow: "Prime Builder",
        title: "A warm-up\nmade for today",
        blurb: "Answer four questions and the app assembles a routine from its movement library. Never the same session twice.",
        points: [
            ("clock.fill", "Set any length from 2 to 15 minutes and it fits the movements to your time."),
            ("figure.stand", "Tap the body map to flag what feels tight, and those areas get the work."),
            ("chair.fill", "Say where you are and it drops anything that won't fit the room.")
        ]),

    OnboardPage(
        id: 2, asset: "banner_running", accent: Theme.signal,
        eyebrow: "Motion check",
        title: "Your phone checks\nthe movement",
        blurb: "Hold your phone or keep it in a pocket, and the app tells you whether the movement on screen is actually happening.",
        points: [
            ("gyroscope", "Reads only the accelerometer and gyroscope. No camera, microphone or location."),
            ("number", "Counts your reps and taps you if the movement stalls."),
            ("lock.fill", "Everything stays on this phone. Nothing is uploaded, and you can switch it off.")
        ]),

    OnboardPage(
        id: 3, asset: "banner_gym", accent: Theme.cyan,
        eyebrow: "Your log",
        title: "Every session\ncounts",
        blurb: "Finished sessions are saved on the device. Streaks, volume and the balance of what you train build from there.",
        points: [
            ("flame.fill", "Day streaks, weekly volume and a twelve-week consistency grid."),
            ("chart.bar.fill", "See which muscle groups you favour and which you keep skipping."),
            ("arrow.triangle.2.circlepath", "The groups you skip get priority next time the builder runs.")
        ]),

    OnboardPage(
        id: 4, asset: "emergency_hero", accent: Theme.danger,
        eyebrow: "Care",
        title: "First aid,\nno signal needed",
        blurb: "Step-by-step protocols for the injuries that actually happen in sport: what to do, what to avoid and when to call for help.",
        points: [
            ("cross.case.fill", "\(EmergencyLibrary.protocols.count) guides covering sprains, strains, knocks and heat."),
            ("exclamationmark.triangle.fill", "Clear red flags telling you when to stop and get medical help."),
            ("wifi.slash", "Stored in the app, so it works with no connection at all.")
        ])
]

// MARK: - Onboarding

/// First-run tour. Shown once, then never again unless the app is reinstalled.
struct OnboardingView: View {
    var onFinish: () -> Void

    @State private var page = 0

    private var current: OnboardPage { onboardPages[min(page, onboardPages.count - 1)] }
    private var isLast: Bool { page == onboardPages.count - 1 }

    var body: some View {
        ZStack {
            Theme.canvas.ignoresSafeArea()

            TabView(selection: $page) {
                ForEach(onboardPages) { item in
                    PageBody(page: item).tag(item.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(edges: .top)

            VStack {
                skipBar
                Spacer()
                controls
            }
        }
        .preferredColorScheme(.dark)
        .animation(.snappy(duration: 0.3), value: page)
    }

    // MARK: Chrome

    private var skipBar: some View {
        HStack {
            Spacer()
            if !isLast {
                Button {
                    Cue.tap()
                    onFinish()
                } label: {
                    Text("Skip")
                        .font(.system(size: 14, weight: .heavy)).tracking(1)
                        .textCase(.uppercase)
                        .foregroundStyle(Theme.textSecondary)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(CutCorner(cut: 6, corners: [.topRight, .bottomLeft])
                            .fill(Theme.canvas.opacity(0.55)))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 6)
    }

    private var controls: some View {
        VStack(spacing: 16) {
            indicator
            PrimaryButton(title: isLast ? "Start moving" : "Next",
                          systemImage: isLast ? "bolt.fill" : "arrow.right",
                          accent: current.accent) {
                Cue.tap()
                if isLast {
                    onFinish()
                } else {
                    page += 1
                }
            }
        }
        .frame(maxWidth: OnboardMetrics.columnWidth)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 22)
        .padding(.bottom, 22)
        .padding(.top, 16)
        .background(
            LinearGradient(colors: [.clear, Theme.canvas, Theme.canvas],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea())
    }

    /// Angular page indicator: the active page is a wide bar, the rest ticks.
    private var indicator: some View {
        HStack(spacing: 7) {
            ForEach(onboardPages) { item in
                CutCorner(cut: 2, corners: [.topRight, .bottomLeft])
                    .fill(item.id == page ? current.accent : Theme.surfaceHi)
                    .frame(width: item.id == page ? 26 : 9, height: 5)
            }
        }
    }
}

// MARK: - Page layout

private struct PageBody: View {
    let page: OnboardPage

    var body: some View {
        GeometryReader { geo in
            let imageHeight = min(max(geo.size.height * 0.33, 200), 340)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    hero(height: imageHeight, width: geo.size.width)
                    VStack(alignment: .leading, spacing: 16) {
                        heading
                        if !page.stats.isEmpty { statsBand }
                        if !page.points.isEmpty { pointRows }
                    }
                    // Wide screens: keep the column readable instead of
                    // stretching a line of text across a full iPad.
                    .frame(maxWidth: OnboardMetrics.columnWidth, alignment: .leading)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 22)
                    // Clear of the button bar.
                    Color.clear.frame(height: 172)
                }
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }

    private func hero(height: CGFloat, width: CGFloat) -> some View {
        ZStack(alignment: .bottomLeading) {
            Image(page.asset)
                .resizable().scaledToFill()
                .frame(width: width, height: height)
                .clipped()
            LinearGradient(colors: [Theme.canvas.opacity(0.35), .clear,
                                    Theme.canvas.opacity(0.9), Theme.canvas],
                           startPoint: .top, endPoint: .bottom)
            Slash().fill(page.accent).frame(width: 80, height: height)
                .opacity(0.85).blendMode(.overlay)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(width: width, height: height)
    }

    private var heading: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(page.eyebrow).eyebrow(page.accent)
            Text(page.title)
                .font(.display(38))
                .foregroundStyle(Theme.textPrimary)
                .textCase(.uppercase)
                .lineSpacing(-4)
                .fixedSize(horizontal: false, vertical: true)
            Text(page.blurb)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var statsBand: some View {
        FlowLayout(spacing: 8, lineSpacing: 8) {
            ForEach(Array(page.stats.enumerated()), id: \.offset) { _, stat in
                VStack(alignment: .leading, spacing: 0) {
                    Text(stat.value)
                        .font(.display(22))
                        .foregroundStyle(page.accent)
                    Text(stat.label)
                        .font(.system(size: 10, weight: .heavy))
                        .tracking(1.4)
                        .textCase(.uppercase)
                        .foregroundStyle(Theme.textMuted)
                        .lineLimit(1)
                }
                .frame(minWidth: 74, alignment: .leading)
                .padding(.horizontal, 10).padding(.vertical, 8)
                .background(CutCorner(cut: 8, corners: [.topRight, .bottomLeft])
                    .fill(Theme.surface))
                .overlay(CutCorner(cut: 8, corners: [.topRight, .bottomLeft])
                    .stroke(Theme.stroke, lineWidth: 1))
            }
        }
    }

    private var pointRows: some View {
        VStack(spacing: 9) {
            ForEach(Array(page.points.enumerated()), id: \.offset) { _, point in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: point.icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(page.accent)
                        .frame(width: 36, height: 36)
                        .background(CutCorner(cut: 7, corners: [.topRight, .bottomLeft])
                            .fill(page.accent.opacity(0.13)))
                    Text(point.text)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(11)
                .background(CutCorner(cut: 10, corners: [.topRight, .bottomLeft])
                    .fill(Theme.surface.opacity(0.75)))
                .overlay(CutCorner(cut: 10, corners: [.topRight, .bottomLeft])
                    .stroke(Theme.stroke, lineWidth: 1))
            }
        }
    }
}

#Preview("Onboarding") {
    OnboardingView(onFinish: {})
}
