import SwiftUI

// MARK: - Library browser

/// Exercise library. On wide layouts a card selects into a right-hand
/// inspector; on narrower ones it pushes the detail like the phone does.
struct PadExercisesView: View {
    @State private var muscle: MuscleGroup? = nil
    @State private var query = ""
    @State private var selected: Exercise? = nil
    @FocusState private var searchFocused: Bool

    private var results: [Exercise] {
        Library.exercises.filter { ex in
            (muscle == nil || ex.primaryMuscles.contains(muscle!)) &&
            (query.isEmpty || ex.name.localizedCaseInsensitiveContains(query))
        }
    }

    var body: some View {
        WidthReader { width in
            let inspector = width >= PadMetrics.inspectorBreakpoint
            ZStack {
                PadBackground(asset: "bg_home")
                if inspector {
                    let paneWidth = min(460, (width * 0.36).rounded())
                    HStack(spacing: 0) {
                        browser(width: PadMetrics.contentWidth(for: width - paneWidth - 1), pushes: false)
                        Rectangle().fill(Theme.stroke).frame(width: 1).ignoresSafeArea()
                        inspectorPane(width: paneWidth)
                    }
                } else {
                    browser(width: PadMetrics.contentWidth(for: width), pushes: true)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .navigationDestination(for: Exercise.self) {
            PadExerciseDetailView(exercise: $0, accent: Theme.volt)
        }
        .background {
            // ⌘F jumps to search for keyboard users.
            Button("") { searchFocused = true }
                .keyboardShortcut("f", modifiers: .command)
                .opacity(0)
                .frame(width: 0, height: 0)
                .accessibilityHidden(true)
        }
    }

    private func browser(width w: CGFloat, pushes: Bool) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                PadPageHeader(eyebrow: "Exercise Library", title: "Know Your\nMovements",
                              blurb: "Every move — the muscles it targets and why it keeps you injury-free.")
                PadSearchField(text: $query, placeholder: "Search movements", isFocused: $searchFocused)
                    .frame(maxWidth: 520)
                filters
                grid(width: w, pushes: pushes)
            }
            .frame(maxWidth: PadMetrics.contentMaxWidth, alignment: .leading)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, PadMetrics.pagePadding)
            .padding(.top, PadMetrics.pageTop)
            .padding(.bottom, PadMetrics.pageBottom)
        }
    }

    private var filters: some View {
        FlowLayout(spacing: 8, lineSpacing: 8) {
            FilterChip(text: "All", selected: muscle == nil) { Cue.tap(); muscle = nil }
            ForEach(MuscleGroup.allCases) { m in
                FilterChip(text: m.title, selected: muscle == m) {
                    Cue.tap(); muscle = (muscle == m ? nil : m)
                }
            }
        }
    }

    @ViewBuilder private func grid(width w: CGFloat, pushes: Bool) -> some View {
        if results.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("No movements match")
                    .font(.heavy(20)).foregroundStyle(Theme.textPrimary)
                Text("Try another muscle group or clear the search.")
                    .font(.system(size: 15, weight: .medium)).foregroundStyle(Theme.textSecondary)
            }
            .padding(.top, 12)
        } else {
            let cols = PadMetrics.columns(fitting: 210, in: w, max: 5)
            LazyVGrid(columns: PadMetrics.grid(cols), spacing: PadMetrics.gridGap) {
                ForEach(results) { ex in
                    if pushes {
                        NavigationLink(value: ex) { ExerciseCard(exercise: ex).padHover() }
                            .buttonStyle(.plain)
                    } else {
                        Button { Cue.tap(); selected = ex } label: {
                            ExerciseCard(exercise: ex)
                                .overlay(CutCorner(cut: 12, corners: [.topRight, .bottomLeft])
                                    .stroke(Theme.volt, lineWidth: selected == ex ? 2 : 0))
                                .padHover()
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(selected == ex ? [.isSelected] : [])
                    }
                }
            }
            .animation(.snappy(duration: 0.25), value: results.map(\.id))
        }
    }

    private func inspectorPane(width: CGFloat) -> some View {
        Group {
            if let selected {
                ScrollView {
                    PadExerciseDetailContent(exercise: selected, accent: Theme.volt,
                                             width: width - 48, showHero: true)
                        .padding(.horizontal, 24)
                        .padding(.top, PadMetrics.pageTop)
                        .padding(.bottom, PadMetrics.pageBottom)
                }
                .id(selected.id)   // new selection starts at the top
            } else {
                VStack(spacing: 14) {
                    Image(systemName: "figure.flexibility")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(Theme.volt.opacity(0.6))
                    Text("Pick a movement")
                        .font(.display(26)).foregroundStyle(Theme.textPrimary).textCase(.uppercase)
                    Text("Select any card to read what it does, why it matters and how to perform it.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 300)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(width: width)
        .background(Theme.surface.opacity(0.55).ignoresSafeArea())
    }
}

// MARK: - Pushed detail

struct PadExerciseDetailView: View {
    let exercise: Exercise
    var accent: Color = Theme.volt

    var body: some View {
        WidthReader { width in
            let w = PadMetrics.contentWidth(for: width)
            let wide = w >= PadMetrics.twoPaneBreakpoint
            PadPage(asset: "bg_home", accent: accent) {
                PadTwoPane(width: w, leadingFraction: 0.40, spacing: 36) {
                    PadHero(asset: exercise.asset, accent: accent, tag: exercise.kind.label,
                            title: exercise.name, subtitle: exercise.cue, titleSize: 40,
                            aspect: wide ? 3.0 / 4.0 : nil)
                        .frame(height: wide ? nil : 360)
                } trailing: {
                    PadExerciseDetailContent(exercise: exercise, accent: accent,
                                             width: wide ? ((w - 36) * 0.60).rounded(.down) : w,
                                             showHero: false)
                }
            }
        }
        .navigationTitle(exercise.name)
    }
}

// MARK: - Detail content (shared by inspector and pushed detail)

struct PadExerciseDetailContent: View {
    let exercise: Exercise
    var accent: Color = Theme.volt
    var width: CGFloat
    var showHero: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 26) {
            if showHero {
                PadHero(asset: exercise.asset, accent: accent, tag: exercise.kind.label,
                        title: exercise.name, subtitle: exercise.cue, titleSize: 34,
                        aspect: 3.0 / 4.0, cut: 18, textInset: 18)
            }
            VStack(alignment: .leading, spacing: 10) {
                Text("Target muscles").eyebrow(accent)
                FlowTags(items: exercise.primaryMuscles.map(\.title), accent: accent)
            }
            VStack(alignment: .leading, spacing: 8) {
                SectionHeader(eyebrow: "The movement", title: "What It Does", accent: accent)
                Text(exercise.summary)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
                    .lineSpacing(4)
            }
            whyBlock
            if !exercise.mistakes.isEmpty && width >= 720 {
                HStack(alignment: .top, spacing: 28) {
                    stepsBlock.frame(maxWidth: .infinity, alignment: .leading)
                    mistakesBlock.frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                stepsBlock
                if !exercise.mistakes.isEmpty { mistakesBlock }
            }
        }
    }

    private var whyBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "shield.lefthalf.filled").foregroundStyle(accent)
                Text("Why it matters").eyebrow(accent)
            }
            Text(exercise.whyItMatters)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
                .lineSpacing(4)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(accent.opacity(0.10))
        .clipShape(CutCorner(cut: 14, corners: [.topRight, .bottomLeft]))
        .overlay(CutCorner(cut: 14, corners: [.topRight, .bottomLeft]).stroke(accent.opacity(0.4), lineWidth: 1))
    }

    private var stepsBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(eyebrow: "Technique", title: "How To", accent: accent)
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(exercise.steps.enumerated()), id: \.offset) { i, s in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(i + 1)")
                            .font(.display(20)).foregroundStyle(accent)
                            .frame(width: 26, alignment: .leading)
                        Text(s)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Theme.textSecondary)
                            .lineSpacing(3)
                    }
                }
            }
        }
    }

    private var mistakesBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(eyebrow: "Stay safe", title: "Avoid", accent: Theme.signal)
            VStack(alignment: .leading, spacing: 12) {
                ForEach(exercise.mistakes, id: \.self) { m in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "xmark.octagon.fill")
                            .font(.system(size: 15)).foregroundStyle(Theme.signal)
                            .padding(.top, 2)
                        Text(m)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Theme.textSecondary)
                            .lineSpacing(3)
                    }
                }
            }
        }
    }
}
