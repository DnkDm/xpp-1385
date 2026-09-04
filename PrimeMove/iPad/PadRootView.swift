import SwiftUI
import UIKit

// MARK: - Sections

/// The five areas of the app as shown in the iPad sidebar / compact tab bar.
enum PadSection: String, CaseIterable, Identifiable, Hashable {
    case train, exercises, mini, timers, care
    var id: String { rawValue }

    var title: String {
        switch self {
        case .train: "Train"
        case .exercises: "Exercises"
        case .mini: "Mini Moves"
        case .timers: "Timers"
        case .care: "Care"
        }
    }

    var subtitle: String {
        switch self {
        case .train: "\(Library.routines.count) routines"
        case .exercises: "\(Library.exercises.count) movements"
        case .mini: "\(Library.miniWarmups.count) quick resets"
        case .timers: "Intervals & stopwatch"
        case .care: "First-aid guides"
        }
    }

    var icon: String {
        switch self {
        case .train: "bolt.fill"
        case .exercises: "figure.flexibility"
        case .mini: "timer"
        case .timers: "stopwatch.fill"
        case .care: "cross.case.fill"
        }
    }

    var accent: Color { self == .care ? Theme.danger : Theme.volt }

    /// ⌘1 … ⌘5
    var key: KeyEquivalent {
        switch self {
        case .train: "1"
        case .exercises: "2"
        case .mini: "3"
        case .timers: "4"
        case .care: "5"
        }
    }
}

// MARK: - Root

/// iPad entry point. Regular width → sidebar + detail; compact width
/// (Split View ⅓, Slide Over) → tab bar. Selection, navigation paths and the
/// running session all live here so nothing is lost when the layout flips.
struct PadRootView: View {
    @Environment(\.horizontalSizeClass) private var hSize
    @State private var section: PadSection = .train
    @State private var paths: [PadSection: NavigationPath] = [:]
    @State private var columns: NavigationSplitViewVisibility = .all
    @State private var presenter = PadSessionPresenter()

    var body: some View {
        Group {
            if hSize == .regular {
                PadSplitLayout(section: $section, paths: $paths, columns: $columns)
            } else {
                PadTabLayout(section: $section, paths: $paths)
            }
        }
        .environment(presenter)
        .fullScreenCover(item: $presenter.active) { item in
            switch item.kind {
            case .routine(let engine):
                PadSessionView(engine: engine)
            case .interval(let engine):
                PadIntervalRunnerView(engine: engine)
            }
        }
    }
}

/// Binding into the per-section navigation path dictionary.
private func pathBinding(_ paths: Binding<[PadSection: NavigationPath]>,
                         _ section: PadSection) -> Binding<NavigationPath> {
    Binding(
        get: { paths.wrappedValue[section] ?? NavigationPath() },
        set: { paths.wrappedValue[section] = $0 })
}

/// Root content of a section (inside its own NavigationStack).
struct PadSectionRoot: View {
    let section: PadSection
    var body: some View {
        switch section {
        case .train: PadTrainView()
        case .exercises: PadExercisesView()
        case .mini: PadMiniView()
        case .timers: PadTimersView()
        case .care: PadCareView()
        }
    }
}

// MARK: - Regular width: sidebar + detail

struct PadSplitLayout: View {
    @Binding var section: PadSection
    @Binding var paths: [PadSection: NavigationPath]
    @Binding var columns: NavigationSplitViewVisibility

    var body: some View {
        NavigationSplitView(columnVisibility: $columns) {
            PadSidebar(section: $section)
                .navigationSplitViewColumnWidth(
                    min: PadMetrics.sidebarMin, ideal: PadMetrics.sidebarIdeal, max: PadMetrics.sidebarMax)
                .toolbarBackground(.hidden, for: .navigationBar)
        } detail: {
            NavigationStack(path: pathBinding($paths, section)) {
                PadSectionRoot(section: section)
            }
            .id(section)   // a fresh stack per section — paths never bleed across
        }
        .navigationSplitViewStyle(.balanced)
    }
}

// MARK: - Compact width: tab bar

struct PadTabLayout: View {
    @Binding var section: PadSection
    @Binding var paths: [PadSection: NavigationPath]

    init(section: Binding<PadSection>, paths: Binding<[PadSection: NavigationPath]>) {
        _section = section
        _paths = paths
        // Same opaque dark bar the iPhone layout uses.
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Theme.canvas)
        appearance.shadowColor = UIColor(Theme.stroke)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $section) {
            ForEach(PadSection.allCases) { s in
                NavigationStack(path: pathBinding($paths, s)) {
                    PadSectionRoot(section: s)
                }
                .tabItem { Label(s.title, systemImage: s.icon) }
                .tag(s)
            }
        }
        .tint(Theme.volt)
    }
}

// MARK: - Sidebar

struct PadSidebar: View {
    @Binding var section: PadSection

    private let rowShape = CutCorner(cut: 12, corners: [.topRight, .bottomLeft])

    var body: some View {
        ZStack {
            Theme.canvas.ignoresSafeArea()
            Color.clear
                .overlay(alignment: .bottomLeading) {
                    Theme.volt.opacity(0.08)
                        .frame(width: 320, height: 320)
                        .blur(radius: 120)
                        .offset(x: -120, y: 120)
                }
                .allowsHitTesting(false)

            GeometryReader { geo in
                VStack(alignment: .leading, spacing: 0) {
                    brand
                        .padding(.horizontal, 22)
                        .padding(.top, 12)
                        .padding(.bottom, 24)

                    ScrollView {
                        VStack(spacing: 6) {
                            ForEach(PadSection.allCases) { row($0) }
                        }
                        .padding(.horizontal, 12)
                        .animation(.snappy(duration: 0.25), value: section)
                    }

                    if geo.size.height >= 560 {   // short windows: give the rows the room
                        FooterNote()
                            .padding(.horizontal, 22)
                            .padding(.bottom, 20)
                    }
                }
            }
        }
        .overlay(alignment: .trailing) {
            Rectangle().fill(Theme.stroke).frame(width: 1).ignoresSafeArea()
        }
    }

    private var brand: some View {
        HStack(spacing: 10) {
            Rectangle().fill(Theme.volt).frame(width: 16, height: 34)
                .clipShape(CutCorner(cut: 7, corners: [.bottomLeft, .topRight]))
            Text("PRIMEMOVE")
                .font(.display(22))
                .tracking(3)
                .foregroundStyle(Theme.textPrimary)
        }
        .accessibilityAddTraits(.isHeader)
    }

    private func row(_ s: PadSection) -> some View {
        let selected = s == section
        return Button {
            guard section != s else { return }
            Cue.tap()
            section = s
        } label: {
            HStack(spacing: 14) {
                Image(systemName: s.icon)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(selected ? Theme.canvas : s.accent)
                    .frame(width: 40, height: 40)
                    .background(
                        CutCorner(cut: 8, corners: [.topRight, .bottomLeft])
                            .fill(selected ? Theme.canvas.opacity(0.14) : s.accent.opacity(0.12)))
                VStack(alignment: .leading, spacing: 2) {
                    Text(s.title)
                        .font(.heavy(17)).tracking(0.5).textCase(.uppercase)
                        .foregroundStyle(selected ? Theme.canvas : Theme.textPrimary)
                    Text(s.subtitle)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(selected ? Theme.canvas.opacity(0.72) : Theme.textMuted)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(rowShape.fill(selected ? s.accent : Color.clear))
            .contentShape(rowShape)
            .padHover()
        }
        .buttonStyle(.plain)
        .keyboardShortcut(s.key, modifiers: .command)
        .accessibilityLabel(s.title)
        .accessibilityHint(s.subtitle)
        .accessibilityAddTraits(selected ? [.isSelected] : [])
    }
}

#Preview("iPad root") {
    PadRootView()
        .preferredColorScheme(.dark)
        .tint(Theme.volt)
}
