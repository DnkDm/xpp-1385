import SwiftUI

/// Routine detail. Wide: the poster, stats and Start button stay pinned on the
/// left while the sequence scrolls on the right. Narrow: one scrolling column.
struct PadRoutineDetailView: View {
    let routine: Routine
    @Environment(PadSessionPresenter.self) private var presenter

    private var muscles: [MuscleGroup] {
        var seen = Set<MuscleGroup>()
        var ordered: [MuscleGroup] = []
        for step in routine.steps {
            for m in step.exercise.primaryMuscles where !seen.contains(m) {
                seen.insert(m); ordered.append(m)
            }
        }
        return ordered
    }

    var body: some View {
        SizeReader { size in
            let w = PadMetrics.contentWidth(for: size.width)
            if w >= PadMetrics.twoPaneBreakpoint && size.height >= PadMetrics.pinnedPaneMinHeight {
                pinned(width: w)
            } else {
                stacked(width: w)
            }
        }
        .navigationTitle(routine.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    // MARK: Wide

    private func pinned(width w: CGFloat) -> some View {
        let spacing: CGFloat = 36
        let leftWidth = ((w - spacing) * 0.42).rounded(.down)
        return ZStack {
            PadBackground(asset: routine.banner, accent: routine.accent, dim: 0.9)
            HStack(alignment: .top, spacing: spacing) {
                VStack(spacing: 16) {
                    hero(titleSize: 46)
                        .frame(maxHeight: .infinity)
                    stats
                    startButton
                }
                .frame(width: leftWidth)
                .padding(.bottom, 28)

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        muscleCoverage
                        sequence
                        FooterNote()
                    }
                    .padding(.bottom, PadMetrics.pageBottom)
                }
            }
            .frame(maxWidth: PadMetrics.contentMaxWidth)
            .padding(.horizontal, PadMetrics.pagePadding)
            .padding(.top, 8)
        }
    }

    // MARK: Narrow

    private func stacked(width w: CGFloat) -> some View {
        PadPage(asset: routine.banner, accent: routine.accent, dim: 0.9) {
            VStack(alignment: .leading, spacing: 28) {
                hero(titleSize: 40).frame(height: 320)
                stats
                startButton
                muscleCoverage
                sequence
                FooterNote()
            }
        }
    }

    // MARK: Pieces

    private func hero(titleSize: CGFloat) -> some View {
        PadHero(asset: routine.banner, accent: routine.accent, tag: routine.category.short,
                title: routine.title, subtitle: routine.subtitle, titleSize: titleSize)
    }

    private var stats: some View {
        HStack(spacing: 10) {
            StatPill(icon: "clock.fill", value: "\(routine.minutes)", label: "Min", accent: routine.accent)
            StatPill(icon: "figure.run", value: "\(routine.moveCount)", label: "Moves", accent: routine.accent)
            StatPill(icon: "flame.fill", value: routine.intensity.label, label: "Effort", accent: routine.intensity.color)
        }
    }

    private var startButton: some View {
        PrimaryButton(title: "Start Warm-Up", systemImage: "play.fill", accent: routine.accent) {
            presenter.start(routine)
        }
        .keyboardShortcut(.return, modifiers: .command)
        .accessibilityHint("Starts the timed session")
    }

    private var muscleCoverage: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(eyebrow: "What you'll work", title: "Muscle Coverage", accent: routine.accent)
            FlowTags(items: muscles.map(\.title), accent: routine.accent)
        }
    }

    private var sequence: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(eyebrow: "The sequence", title: "Moves", accent: routine.accent,
                          trailing: durationLabel(routine.totalSeconds))
            VStack(spacing: 10) {
                ForEach(Array(routine.steps.enumerated()), id: \.offset) { idx, step in
                    NavigationLink {
                        PadExerciseDetailView(exercise: step.exercise, accent: routine.accent)
                    } label: {
                        StepRow(index: idx + 1, step: step, accent: routine.accent).padHover()
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
