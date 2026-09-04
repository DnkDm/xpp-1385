import SwiftUI

struct ExercisesView: View {
    @State private var muscle: MuscleGroup? = nil
    @State private var query: String = ""

    private var results: [Exercise] {
        Library.exercises.filter { ex in
            (muscle == nil || ex.primaryMuscles.contains(muscle!)) &&
            (query.isEmpty || ex.name.localizedCaseInsensitiveContains(query))
        }
    }

    private let columns = [GridItem(.flexible(), spacing: 12),
                           GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            ZStack {
                ScreenBackground(asset: "bg_home")
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Exercise Library").eyebrow(Theme.volt)
                            Text("Know Your\nMovements")
                                .font(.display(40)).foregroundStyle(Theme.textPrimary).textCase(.uppercase)
                            Text("Every move — the muscles it targets and why it keeps you injury-free.")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Theme.textSecondary)
                        }

                        searchField
                        muscleFilter

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(results) { ex in
                                NavigationLink(value: ex) { ExerciseCard(exercise: ex) }
                                    .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
                .navigationDestination(for: Exercise.self) {
                    ExerciseDetailView(exercise: $0, accent: Theme.volt)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundStyle(Theme.textMuted)
            TextField("Search movements", text: $query)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Theme.textPrimary)
                .autocorrectionDisabled()
            if !query.isEmpty {
                Button { query = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(Theme.textMuted)
                }
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .background(Theme.surfaceHi)
        .clipShape(CutCorner(cut: 8, corners: [.topRight, .bottomLeft]))
        .overlay(CutCorner(cut: 8, corners: [.topRight, .bottomLeft]).stroke(Theme.stroke, lineWidth: 1))
    }

    private var muscleFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(text: "All", selected: muscle == nil) { Cue.tap(); muscle = nil }
                ForEach(MuscleGroup.allCases) { m in
                    FilterChip(text: m.title, selected: muscle == m) {
                        Cue.tap(); muscle = (muscle == m ? nil : m)
                    }
                }
            }
        }
        .scrollClipDisabled()
    }
}

// MARK: - Exercise card

struct ExerciseCard: View {
    let exercise: Exercise
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                Image(exercise.asset)
                    .resizable().scaledToFill()
                    .frame(height: 150).frame(maxWidth: .infinity).clipped()
                LinearGradient(colors: [.clear, Theme.surface], startPoint: .center, endPoint: .bottom)
                Tag(text: exercise.kind.label, color: Theme.volt, filled: true).padding(10)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.heavy(16)).foregroundStyle(Theme.textPrimary)
                    .lineLimit(1).minimumScaleFactor(0.8)
                Text(exercise.primaryMuscles.first?.title ?? "")
                    .font(.system(size: 11, weight: .heavy)).tracking(1)
                    .foregroundStyle(Theme.textMuted).textCase(.uppercase)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Theme.surface)
        .clipShape(CutCorner(cut: 12, corners: [.topRight, .bottomLeft]))
        .overlay(CutCorner(cut: 12, corners: [.topRight, .bottomLeft]).stroke(Theme.stroke, lineWidth: 1))
    }
}

// MARK: - Exercise detail

struct ExerciseDetailView: View {
    let exercise: Exercise
    var accent: Color = Theme.volt

    var body: some View {
        ZStack {
            ScreenBackground(asset: "bg_home", accent: accent)
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    hero
                    muscleTags
                    summaryBlock
                    whyBlock
                    stepsBlock
                    mistakesBlock
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            Image(exercise.asset)
                .resizable().scaledToFill()
                .frame(maxWidth: .infinity).frame(height: 320).clipped()
            LinearGradient(colors: [.clear, Theme.canvas], startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 8) {
                Tag(text: exercise.kind.label, color: accent, filled: true)
                Text(exercise.name)
                    .font(.display(36)).foregroundStyle(.white).textCase(.uppercase)
                Text(exercise.cue)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(18)
        }
        .frame(height: 320)
        .clipShape(CutCorner(cut: 20, corners: [.topRight, .bottomLeft]))
        .overlay(CutCorner(cut: 20, corners: [.topRight, .bottomLeft]).stroke(accent.opacity(0.5), lineWidth: 1.5))
    }

    private var muscleTags: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Target muscles").eyebrow(accent)
            FlowTags(items: exercise.primaryMuscles.map { $0.title }, accent: accent)
        }
    }

    private var summaryBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(eyebrow: "The movement", title: "What It Does", accent: accent)
            Text(exercise.summary)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
                .lineSpacing(3)
        }
    }

    private var whyBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "shield.lefthalf.filled").foregroundStyle(accent)
                Text("Why it matters").eyebrow(accent)
            }
            Text(exercise.whyItMatters)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
                .lineSpacing(3)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(accent.opacity(0.10))
        .clipShape(CutCorner(cut: 14, corners: [.topRight, .bottomLeft]))
        .overlay(CutCorner(cut: 14, corners: [.topRight, .bottomLeft]).stroke(accent.opacity(0.4), lineWidth: 1))
    }

    private var stepsBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(eyebrow: "Technique", title: "How To", accent: accent)
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(exercise.steps.enumerated()), id: \.offset) { i, s in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(i + 1)")
                            .font(.display(18)).foregroundStyle(accent)
                            .frame(width: 24, alignment: .leading)
                        Text(s).font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Theme.textSecondary).lineSpacing(2)
                    }
                }
            }
        }
    }

    @ViewBuilder private var mistakesBlock: some View {
        if !exercise.mistakes.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(eyebrow: "Stay safe", title: "Avoid", accent: Theme.signal)
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(exercise.mistakes, id: \.self) { m in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "xmark.octagon.fill")
                                .font(.system(size: 14)).foregroundStyle(Theme.signal)
                                .padding(.top, 2)
                            Text(m).font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
            }
        }
    }
}
