import SwiftUI

struct TrainView: View {
    @State private var durationFilter: DurationFilter = .all

    enum DurationFilter: String, CaseIterable, Identifiable {
        case all, short, medium, long
        var id: String { rawValue }
        var label: String {
            switch self {
            case .all: "All"
            case .short: "≤4 min"
            case .medium: "5–8 min"
            case .long: "9+ min"
            }
        }
        func matches(_ r: Routine) -> Bool {
            switch self {
            case .all: true
            case .short: r.minutes <= 4
            case .medium: r.minutes >= 5 && r.minutes <= 8
            case .long: r.minutes >= 9
            }
        }
    }

    private var filtered: [Routine] {
        Library.routines.filter { durationFilter.matches($0) }
    }
    private var featured: Routine { Library.routines[1] } // Universal 5

    var body: some View {
        NavigationStack {
            ZStack {
                ScreenBackground(asset: "bg_home")
                ScrollView {
                    VStack(alignment: .leading, spacing: 26) {
                        header
                        FeaturedRoutineCard(routine: featured)
                        categoriesSection
                        routinesSection
                        FooterNote()
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Rectangle().fill(Theme.volt).frame(width: 14, height: 28)
                    .clipShape(CutCorner(cut: 6, corners: [.bottomLeft, .topRight]))
                Text("PRIMEMOVE").eyebrow(Theme.textSecondary)
                Spacer()
            }
            Text("Warm up.\nMove sharp.")
                .font(.display(44))
                .foregroundStyle(Theme.textPrimary)
                .textCase(.uppercase)
                .lineSpacing(-4)
            Text("Targeted routines to prime the body, protect the joints and move without injury.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
                .padding(.top, 2)
        }
    }

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(eyebrow: "Pick your arena", title: "Categories")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(WarmupCategory.allCases) { cat in
                        NavigationLink(value: cat) { CategoryCard(category: cat) }
                            .buttonStyle(.plain)
                    }
                }
            }
            .scrollClipDisabled()
        }
        .navigationDestination(for: WarmupCategory.self) { CategoryRoutinesView(category: $0) }
        .navigationDestination(for: Routine.self) { RoutineDetailView(routine: $0) }
    }

    private var routinesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(eyebrow: "Ready to go", title: "All Routines",
                          trailing: "\(filtered.count)")
            HStack(spacing: 8) {
                ForEach(DurationFilter.allCases) { f in
                    FilterChip(text: f.label, selected: durationFilter == f) {
                        Cue.tap(); durationFilter = f
                    }
                }
            }
            VStack(spacing: 12) {
                ForEach(filtered) { routine in
                    NavigationLink(value: routine) { RoutineRow(routine: routine) }
                        .buttonStyle(.plain)
                }
            }
        }
    }
}

// Routine conforms to Hashable for navigation.
extension Routine: Hashable {
    static func == (l: Routine, r: Routine) -> Bool { l.id == r.id }
    func hash(into h: inout Hasher) { h.combine(id) }
}

// MARK: - Featured card

struct FeaturedRoutineCard: View {
    let routine: Routine
    var body: some View {
        NavigationLink(value: routine) {
            ZStack(alignment: .bottomLeading) {
                Image(routine.banner)
                    .resizable().scaledToFill()
                    .frame(maxWidth: .infinity).frame(height: 230)
                    .clipped()
                LinearGradient(colors: [.clear, Theme.canvas.opacity(0.95)],
                               startPoint: .top, endPoint: .bottom)
                // accent slash
                Slash().fill(routine.accent).frame(width: 90, height: 230)
                    .opacity(0.9).blendMode(.overlay)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                VStack(alignment: .leading, spacing: 8) {
                    Tag(text: "Recommended", color: routine.accent, filled: true)
                    Text(routine.title)
                        .font(.display(34)).foregroundStyle(.white).textCase(.uppercase)
                    HStack(spacing: 14) {
                        Label("\(routine.minutes) min", systemImage: "clock.fill")
                        Label("\(routine.moveCount) moves", systemImage: "figure.run")
                        Label(routine.intensity.label, systemImage: "flame.fill")
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white.opacity(0.9))
                }
                .padding(18)
            }
            .frame(height: 230)
            .clipShape(CutCorner(cut: 22, corners: [.topRight, .bottomLeft]))
            .overlay(CutCorner(cut: 22, corners: [.topRight, .bottomLeft])
                .stroke(routine.accent.opacity(0.5), lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Category card

struct CategoryCard: View {
    let category: WarmupCategory
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(category.banner)
                .resizable().scaledToFill()
                .frame(width: 200, height: 250)
                .clipped()
            LinearGradient(colors: [.clear, Theme.canvas.opacity(0.92)],
                           startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(category.accent)
                Spacer()
                Text(category.short)
                    .font(.display(24)).foregroundStyle(.white).textCase(.uppercase)
                Text("\(Library.routines(for: category).count) routines")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white.opacity(0.75))
            }
            .padding(14)
        }
        .frame(width: 200, height: 250)
        .clipShape(CutCorner(cut: 16, corners: [.topRight, .bottomLeft]))
        .overlay(CutCorner(cut: 16, corners: [.topRight, .bottomLeft])
            .stroke(category.accent.opacity(0.4), lineWidth: 1))
    }
}

// MARK: - Routine row

struct RoutineRow: View {
    let routine: Routine
    var body: some View {
        HStack(spacing: 0) {
            Rectangle().fill(routine.accent).frame(width: 5)
            HStack(spacing: 14) {
                Image(routine.steps.first?.exercise.asset ?? routine.banner)
                    .resizable().scaledToFill()
                    .frame(width: 64, height: 64)
                    .clipped()
                    .clipShape(CutCorner(cut: 8, corners: [.topRight, .bottomLeft]))
                VStack(alignment: .leading, spacing: 4) {
                    Text(routine.title)
                        .font(.heavy(19)).foregroundStyle(Theme.textPrimary).textCase(.uppercase)
                    Text(routine.subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.textSecondary).lineLimit(1)
                    HStack(spacing: 10) {
                        Text("\(routine.minutes) MIN").foregroundStyle(routine.accent)
                        Text("\(routine.moveCount) MOVES").foregroundStyle(Theme.textMuted)
                        Text(routine.intensity.label.uppercased()).foregroundStyle(Theme.textMuted)
                    }
                    .font(.system(size: 11, weight: .heavy)).tracking(1)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(Theme.textMuted)
                    .padding(.trailing, 14)
            }
            .padding(.vertical, 12)
            .padding(.leading, 12)
        }
        .background(Theme.surface)
        .clipShape(CutCorner(cut: 12, corners: [.topRight, .bottomLeft]))
        .overlay(CutCorner(cut: 12, corners: [.topRight, .bottomLeft])
            .stroke(Theme.stroke, lineWidth: 1))
    }
}

// MARK: - Chips

struct FilterChip: View {
    var text: String
    var selected: Bool
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 13, weight: .heavy)).tracking(0.5)
                .foregroundStyle(selected ? Theme.canvas : Theme.textSecondary)
                .padding(.horizontal, 14).padding(.vertical, 9)
                .background(CutCorner(cut: 7, corners: [.topRight, .bottomLeft])
                    .fill(selected ? Theme.volt : Theme.surfaceHi))
                .overlay(CutCorner(cut: 7, corners: [.topRight, .bottomLeft])
                    .stroke(selected ? .clear : Theme.stroke, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct FooterNote: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "info.circle")
                .foregroundStyle(Theme.textMuted)
            Text("Warm up before activity and ease into harder moves. Stop if you feel sharp pain.")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Theme.textMuted)
        }
        .padding(.top, 8)
    }
}

// MARK: - Category routines list

struct CategoryRoutinesView: View {
    let category: WarmupCategory
    var body: some View {
        ZStack {
            ScreenBackground(asset: category.banner, accent: category.accent, dim: 0.9)
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Tag(text: category.short, color: category.accent, filled: true)
                        Text(category.title)
                            .font(.display(36)).foregroundStyle(Theme.textPrimary).textCase(.uppercase)
                        Text(category.blurb)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .padding(.top, 4)

                    ForEach(Library.routines(for: category)) { routine in
                        NavigationLink(value: routine) { RoutineRow(routine: routine) }
                            .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle(category.short)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}
