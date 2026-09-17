import SwiftUI

/// The check-in. Four questions, then a routine assembled from the library
/// for exactly this session — time, sport, tight areas and available space.
struct BuilderView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var brief = PrimeBrief()
    @State private var built: Routine?

    private let log = TrainingLog.shared

    var body: some View {
        NavigationStack {
            ZStack {
                ScreenBackground(asset: "bg_home", dim: 0.88)
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        intro
                        activitySection
                        timeSection
                        bodySection
                        spaceSection
                        effortSection
                        Color.clear.frame(height: 96)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 4)
                }
                .scrollDismissesKeyboard(.immediately)

                VStack {
                    Spacer()
                    buildBar
                }
            }
            .navigationTitle("Prime Builder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { Cue.tap(); dismiss() }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .navigationDestination(item: $built) { routine in
                BuiltRoutineView(routine: routine, onRebuild: rebuild)
            }
        }
    }

    // MARK: Sections

    private var intro: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Four questions").eyebrow(Theme.volt)
            Text("Build today's\nwarm-up")
                .font(.display(38))
                .foregroundStyle(Theme.textPrimary)
                .textCase(.uppercase)
                .lineSpacing(-4)
            Text("No two sessions are the same. Tell us what you're about to do and how your body feels, and we'll assemble the movements to match.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(eyebrow: "Step 1", title: "What's next?")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(WarmupCategory.allCases) { category in
                        choiceChip(title: category.short,
                                   icon: category.icon,
                                   accent: category.accent,
                                   selected: brief.activity == category) {
                            brief.activity = category
                        }
                    }
                }
                .padding(.vertical, 2)
            }
            .scrollClipDisabled()
        }
    }

    private var timeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(eyebrow: "Step 2", title: "How long?",
                          trailing: "\(brief.minutes) min")
            AngledCard {
                VStack(spacing: 10) {
                    Slider(value: Binding(
                        get: { Double(brief.minutes) },
                        set: { newValue in
                            let rounded = Int(newValue.rounded())
                            if rounded != brief.minutes {
                                brief.minutes = rounded
                                Cue.tick()
                            }
                        }), in: 2...15, step: 1)
                    .tint(Theme.volt)

                    HStack {
                        Text("2 min").font(.system(size: 12, weight: .bold))
                        Spacer()
                        Text("\(RoutineBuilder.plannedMoveCount(for: brief)) moves planned")
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundStyle(Theme.volt)
                        Spacer()
                        Text("15 min").font(.system(size: 12, weight: .bold))
                    }
                    .foregroundStyle(Theme.textMuted)
                }
                .padding(16)
            }
        }
    }

    private var bodySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(eyebrow: "Step 3", title: "Anything tight?",
                          trailing: brief.tightAreas.isEmpty ? "Optional" : "\(brief.tightAreas.count)")
            AngledCard {
                BodyMap(selection: $brief.tightAreas)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
            }
            // Only meaningful once there is history to read.
            if !log.records.isEmpty, !log.neglectedMuscles.isEmpty, brief.tightAreas.isEmpty {
                hint("Your log is light on \(log.neglectedMuscles.prefix(2).map(\.title).joined(separator: " and ").lowercased()). We'll work some in.")
            }
        }
    }

    private var spaceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(eyebrow: "Step 4", title: "Where are you?")
            VStack(spacing: 8) {
                ForEach(PrimeSpace.allCases) { space in
                    spaceRow(space)
                }
            }
        }
    }

    private var effortSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(eyebrow: "Fine tune", title: "Effort")
            HStack(spacing: 8) {
                ForEach([Intensity.easy, .moderate, .hard], id: \.rawValue) { level in
                    choiceChip(title: level.label,
                               icon: "flame.fill",
                               accent: level.color,
                               selected: brief.effort == level,
                               fillsWidth: true) {
                        brief.effort = level
                    }
                }
            }
        }
    }

    private var buildBar: some View {
        VStack(spacing: 0) {
            LinearGradient(colors: [.clear, Theme.canvas], startPoint: .top, endPoint: .bottom)
                .frame(height: 28)
            PrimaryButton(title: "Build my warm-up", systemImage: "wand.and.stars") {
                Cue.step()
                built = RoutineBuilder.build(brief, neglected: log.neglectedMuscles)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 14)
            .background(Theme.canvas)
        }
    }

    // MARK: Pieces

    private func rebuild() {
        Cue.tap()
        built = RoutineBuilder.build(brief, neglected: log.neglectedMuscles)
    }

    private func hint(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles").font(.system(size: 12, weight: .bold))
            Text(text).font(.system(size: 12, weight: .semibold))
        }
        .foregroundStyle(Theme.violet)
    }

    private func choiceChip(title: String, icon: String, accent: Color,
                            selected: Bool, fillsWidth: Bool = false,
                            action: @escaping () -> Void) -> some View {
        Button {
            Cue.tap()
            action()
        } label: {
            HStack(spacing: 7) {
                Image(systemName: icon).font(.system(size: 13, weight: .bold))
                Text(title)
                    .font(.system(size: 14, weight: .heavy)).tracking(0.6)
                    .textCase(.uppercase)
            }
            .foregroundStyle(selected ? Theme.canvas : Theme.textSecondary)
            .frame(maxWidth: fillsWidth ? .infinity : nil)
            .padding(.horizontal, fillsWidth ? 8 : 14)
            .padding(.vertical, 11)
            .background(CutCorner(cut: 8, corners: [.topRight, .bottomLeft])
                .fill(selected ? accent : Theme.surfaceHi))
            .overlay(CutCorner(cut: 8, corners: [.topRight, .bottomLeft])
                .stroke(selected ? .clear : Theme.stroke, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? [.isSelected] : [])
    }

    private func spaceRow(_ space: PrimeSpace) -> some View {
        let selected = brief.space == space
        let shape = CutCorner(cut: 10, corners: [.topRight, .bottomLeft])
        return Button {
            Cue.tap()
            brief.space = space
        } label: {
            HStack(spacing: 14) {
                Image(systemName: space.icon)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(selected ? Theme.canvas : Theme.volt)
                    .frame(width: 42, height: 42)
                    .background(CutCorner(cut: 7, corners: [.topRight, .bottomLeft])
                        .fill(selected ? Theme.canvas.opacity(0.15) : Theme.volt.opacity(0.12)))
                VStack(alignment: .leading, spacing: 2) {
                    Text(space.title)
                        .font(.heavy(17)).textCase(.uppercase).tracking(0.5)
                        .foregroundStyle(selected ? Theme.canvas : Theme.textPrimary)
                    Text(space.detail)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(selected ? Theme.canvas.opacity(0.75) : Theme.textMuted)
                }
                Spacer(minLength: 0)
                if selected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(Theme.canvas)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(shape.fill(selected ? Theme.volt : Theme.surface))
            .overlay(shape.stroke(selected ? .clear : Theme.stroke, lineWidth: 1))
            .contentShape(shape)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? [.isSelected] : [])
    }
}

// MARK: - The built result

/// Shows what the builder produced and why, then runs it.
struct BuiltRoutineView: View {
    let routine: Routine
    var onRebuild: () -> Void

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
                VStack(alignment: .leading, spacing: 20) {
                    header
                    stats
                    coverage
                    steps
                    Color.clear.frame(height: 110)
                }
                .padding(.horizontal, 18)
                .padding(.top, 6)
            }
            startBar
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $showSession) {
            SessionView(engine: SessionEngine(steps: routine.steps,
                                              accent: routine.accent,
                                              title: routine.title),
                        source: .custom)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Tag(text: "Built for you", color: routine.accent, filled: true)
            Text(routine.title)
                .font(.display(36)).foregroundStyle(Theme.textPrimary).textCase(.uppercase)
            Text(routine.subtitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private var stats: some View {
        HStack(spacing: 10) {
            StatPill(icon: "clock.fill", value: "\(routine.minutes) min",
                     label: "Duration", accent: routine.accent)
            StatPill(icon: "figure.run", value: "\(routine.moveCount)",
                     label: "Moves", accent: routine.accent)
            StatPill(icon: "flame.fill", value: routine.intensity.label,
                     label: "Effort", accent: routine.accent)
        }
    }

    private var coverage: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(eyebrow: "What it covers", title: "Coverage",
                          accent: routine.accent)
            FlowLayout(spacing: 8, lineSpacing: 8) {
                ForEach(muscles) { muscle in
                    Tag(text: muscle.title, color: routine.accent)
                }
            }
        }
    }

    private var steps: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(eyebrow: "In order", title: "The plan", accent: routine.accent)
            VStack(spacing: 8) {
                ForEach(Array(routine.steps.enumerated()), id: \.offset) { index, step in
                    HStack(spacing: 12) {
                        Text("\(index + 1)")
                            .font(.tick(15))
                            .foregroundStyle(routine.accent)
                            .frame(width: 26)
                        Image(step.exercise.asset)
                            .resizable().scaledToFill()
                            .frame(width: 46, height: 46).clipped()
                            .clipShape(CutCorner(cut: 6, corners: [.topRight, .bottomLeft]))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(step.exercise.name)
                                .font(.heavy(16)).foregroundStyle(Theme.textPrimary)
                            Text(step.exercise.kind.label)
                                .font(.system(size: 11, weight: .heavy)).tracking(1)
                                .textCase(.uppercase)
                                .foregroundStyle(Theme.textMuted)
                        }
                        Spacer()
                        Text(durationLabel(step.seconds))
                            .font(.tick(15)).foregroundStyle(Theme.textSecondary)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 9)
                    .background(CutCorner(cut: 9, corners: [.topRight, .bottomLeft])
                        .fill(Theme.surface))
                    .overlay(CutCorner(cut: 9, corners: [.topRight, .bottomLeft])
                        .stroke(Theme.stroke, lineWidth: 1))
                }
            }
        }
    }

    private var startBar: some View {
        VStack(spacing: 10) {
            PrimaryButton(title: "Start", systemImage: "play.fill", accent: routine.accent) {
                Cue.step()
                showSession = true
            }
            GhostButton(title: "Shuffle again", systemImage: "arrow.triangle.2.circlepath",
                        action: onRebuild)
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 16)
        .padding(.top, 12)
        .background(
            LinearGradient(colors: [.clear, Theme.canvas, Theme.canvas],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea())
    }
}
