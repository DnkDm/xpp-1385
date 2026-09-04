import SwiftUI

struct RoutineDetailView: View {
    let routine: Routine
    @State private var showSession = false

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
        ZStack(alignment: .bottom) {
            ScreenBackground(asset: routine.banner, accent: routine.accent, dim: 0.9)

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    hero
                    stats
                    muscleCoverage
                    stepList
                    Color.clear.frame(height: 96) // room for sticky button
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 20)
            }

            startBar
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $showSession) {
            SessionView(engine: SessionEngine(steps: routine.steps,
                                              accent: routine.accent,
                                              title: routine.title))
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            Image(routine.banner)
                .resizable().scaledToFill()
                .frame(maxWidth: .infinity).frame(height: 260).clipped()
            LinearGradient(colors: [.clear, Theme.canvas],
                           startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 8) {
                Tag(text: routine.category.short, color: routine.accent, filled: true)
                Text(routine.title)
                    .font(.display(38)).foregroundStyle(.white).textCase(.uppercase)
                Text(routine.subtitle)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(18)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 260)
        .clipShape(CutCorner(cut: 20, corners: [.topRight, .bottomLeft]))
        .overlay(CutCorner(cut: 20, corners: [.topRight, .bottomLeft])
            .stroke(routine.accent.opacity(0.5), lineWidth: 1.5))
    }

    private var stats: some View {
        HStack(spacing: 10) {
            StatPill(icon: "clock.fill", value: "\(routine.minutes)", label: "Min", accent: routine.accent)
            StatPill(icon: "figure.run", value: "\(routine.moveCount)", label: "Moves", accent: routine.accent)
            StatPill(icon: "flame.fill", value: routine.intensity.label, label: "Effort", accent: routine.intensity.color)
        }
    }

    private var muscleCoverage: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(eyebrow: "What you'll work", title: "Muscle Coverage", accent: routine.accent)
            FlowTags(items: muscles.map { $0.title }, accent: routine.accent)
        }
    }

    private var stepList: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(eyebrow: "The sequence", title: "Moves", accent: routine.accent,
                          trailing: durationLabel(routine.totalSeconds))
            VStack(spacing: 10) {
                ForEach(Array(routine.steps.enumerated()), id: \.offset) { idx, step in
                    NavigationLink {
                        ExerciseDetailView(exercise: step.exercise, accent: routine.accent)
                    } label: {
                        StepRow(index: idx + 1, step: step, accent: routine.accent)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var startBar: some View {
        VStack(spacing: 0) {
            LinearGradient(colors: [.clear, Theme.canvas], startPoint: .top, endPoint: .bottom)
                .frame(height: 24).allowsHitTesting(false)
            PrimaryButton(title: "Start Warm-Up", systemImage: "play.fill", accent: routine.accent) {
                Cue.tap(); showSession = true
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 14)
            .background(Theme.canvas)
        }
    }
}

// MARK: - Step row

struct StepRow: View {
    let index: Int
    let step: RoutineStep
    let accent: Color
    var body: some View {
        HStack(spacing: 14) {
            Text("\(index)")
                .font(.display(20)).foregroundStyle(accent)
                .frame(width: 30, alignment: .leading)
            Image(step.exercise.asset)
                .resizable().scaledToFill()
                .frame(width: 56, height: 56).clipped()
                .clipShape(CutCorner(cut: 7, corners: [.topRight, .bottomLeft]))
            VStack(alignment: .leading, spacing: 3) {
                Text(step.exercise.name)
                    .font(.heavy(17)).foregroundStyle(Theme.textPrimary)
                Text(step.exercise.kind.label)
                    .font(.system(size: 11, weight: .heavy)).tracking(1)
                    .foregroundStyle(Theme.textMuted).textCase(.uppercase)
            }
            Spacer()
            Text(durationLabel(step.seconds))
                .font(.tick(16)).foregroundStyle(Theme.textSecondary)
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .heavy)).foregroundStyle(Theme.textMuted)
        }
        .padding(12)
        .background(Theme.surface)
        .clipShape(CutCorner(cut: 10, corners: [.topRight, .bottomLeft]))
        .overlay(CutCorner(cut: 10, corners: [.topRight, .bottomLeft])
            .stroke(Theme.stroke, lineWidth: 1))
    }
}

// MARK: - Simple wrapping tag flow

struct FlowTags: View {
    let items: [String]
    var accent: Color = Theme.volt

    var body: some View {
        FlowLayout(spacing: 8, lineSpacing: 8) {
            ForEach(items, id: \.self) { Tag(text: $0, color: accent) }
        }
    }
}

/// Minimal flow layout that wraps its children onto multiple lines.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        // When the proposed width is unspecified/infinite (ideal-size query),
        // we must NOT report the full single-line width — that would balloon the
        // enclosing scroll content. Fall back to the widest single child instead.
        let hasWidth = (proposal.width != nil) && (proposal.width != .infinity)
        let maxWidth = hasWidth ? proposal.width! : .greatestFiniteMagnitude
        var x: CGFloat = 0, y: CGFloat = 0, lineHeight: CGFloat = 0, widestChild: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            widestChild = max(widestChild, size.width)
            if x + size.width > maxWidth, x > 0 {
                x = 0; y += lineHeight + lineSpacing; lineHeight = 0
            }
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        return CGSize(width: hasWidth ? maxWidth : widestChild, height: y + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, lineHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX; y += lineHeight + lineSpacing; lineHeight = 0
            }
            sub.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}
