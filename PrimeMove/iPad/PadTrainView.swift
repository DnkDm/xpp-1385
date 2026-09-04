import SwiftUI

// MARK: - Train (home)

struct PadTrainView: View {
    @Environment(\.horizontalSizeClass) private var hSize
    @State private var filter: TrainView.DurationFilter = .all

    private var filtered: [Routine] { Library.routines.filter { filter.matches($0) } }
    private var featured: Routine { Library.routines[1] }   // Universal 5, same pick as iPhone

    var body: some View {
        WidthReader { width in
            let w = PadMetrics.contentWidth(for: width)
            PadPage(asset: "bg_home") {
                VStack(alignment: .leading, spacing: 40) {
                    heroBand(w)
                    categories(w)
                    routines(w)
                    FooterNote()
                }
            }
        }
        .navigationDestination(for: WarmupCategory.self) { PadCategoryRoutinesView(category: $0) }
        .navigationDestination(for: Routine.self) { PadRoutineDetailView(routine: $0) }
    }

    // MARK: Hero band — headline left, recommended routine right

    private func heroBand(_ w: CGFloat) -> some View {
        let wide = w >= PadMetrics.twoPaneBreakpoint
        return PadTwoPane(width: w, leadingFraction: 0.40, spacing: 36) {
            VStack(alignment: .leading, spacing: 16) {
                if hSize == .compact {   // the sidebar already carries the wordmark
                    HStack(spacing: 8) {
                        Rectangle().fill(Theme.volt).frame(width: 14, height: 28)
                            .clipShape(CutCorner(cut: 6, corners: [.bottomLeft, .topRight]))
                        Text("PRIMEMOVE").eyebrow(Theme.textSecondary)
                    }
                } else {
                    Text("Today's prep").eyebrow(Theme.volt)
                }
                Text("Warm up.\nMove sharp.")
                    .font(.display(wide ? 64 : 52))
                    .foregroundStyle(Theme.textPrimary)
                    .textCase(.uppercase)
                    .lineSpacing(-6)
                Text("Targeted routines to prime the body, protect the joints and move without injury.")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
                    .frame(maxWidth: 460, alignment: .leading)
                FlowLayout(spacing: 10, lineSpacing: 10) {   // wraps instead of squeezing in narrow panes
                    StatPill(icon: "bolt.fill", value: "\(Library.routines.count)", label: "Routines")
                        .frame(width: 146)
                    StatPill(icon: "figure.flexibility", value: "\(Library.exercises.count)", label: "Movements")
                        .frame(width: 146)
                    StatPill(icon: "timer", value: "\(Library.miniWarmups.count)", label: "Mini moves")
                        .frame(width: 146)
                }
                .frame(maxWidth: 460, alignment: .leading)
            }
        } trailing: {
            PadFeaturedCard(routine: featured, height: wide ? 360 : 300)
        }
    }

    // MARK: Categories — one row when all five fit, otherwise a horizontal rail

    private func categories(_ w: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(eyebrow: "Pick your arena", title: "Categories")
            let all = WarmupCategory.allCases
            let cols = PadMetrics.columns(fitting: 150, in: w, max: all.count)
            if cols >= all.count {
                LazyVGrid(columns: PadMetrics.grid(cols), spacing: PadMetrics.gridGap) {
                    ForEach(all) { cat in
                        NavigationLink(value: cat) { PadCategoryTile(category: cat) }
                            .buttonStyle(.plain)
                    }
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: PadMetrics.gridGap) {
                        ForEach(all) { cat in
                            NavigationLink(value: cat) {
                                PadCategoryTile(category: cat, fixedSize: CGSize(width: 200, height: 250))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .scrollClipDisabled()
            }
        }
    }

    // MARK: All routines — filter chips + adaptive grid

    private func routines(_ w: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if w >= 640 {
                HStack(alignment: .center, spacing: 16) {
                    SectionHeader(eyebrow: "Ready to go", title: "All Routines", trailing: "\(filtered.count)")
                    chips
                }
            } else {
                SectionHeader(eyebrow: "Ready to go", title: "All Routines", trailing: "\(filtered.count)")
                chips
            }
            let cols = PadMetrics.columns(fitting: 330, in: w, max: 3)
            LazyVGrid(columns: PadMetrics.grid(cols, gap: 14), spacing: 14) {
                ForEach(filtered) { routine in
                    NavigationLink(value: routine) { PadRoutineRow(routine: routine).padHover() }
                        .buttonStyle(.plain)
                }
            }
            .animation(.snappy(duration: 0.25), value: filter)
        }
    }

    private var chips: some View {
        HStack(spacing: 8) {
            ForEach(TrainView.DurationFilter.allCases) { f in
                FilterChip(text: f.label, selected: filter == f) { Cue.tap(); filter = f }
            }
        }
    }
}

// MARK: - Routine row (grid-friendly: the meta line shrinks instead of wrapping)

struct PadRoutineRow: View {
    let routine: Routine

    private let shape = CutCorner(cut: 12, corners: [.topRight, .bottomLeft])

    var body: some View {
        HStack(spacing: 0) {
            Rectangle().fill(routine.accent).frame(width: 5)
            HStack(spacing: 14) {
                Image(routine.steps.first?.exercise.asset ?? routine.banner)
                    .resizable().scaledToFill()
                    .frame(width: 68, height: 68)
                    .clipped()
                    .clipShape(CutCorner(cut: 8, corners: [.topRight, .bottomLeft]))
                VStack(alignment: .leading, spacing: 4) {
                    Text(routine.title)
                        .font(.heavy(19)).foregroundStyle(Theme.textPrimary).textCase(.uppercase)
                        .lineLimit(1).minimumScaleFactor(0.8)
                    Text(routine.subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.textSecondary).lineLimit(1)
                    (Text("\(routine.minutes) MIN").foregroundColor(routine.accent)
                     + Text("   \(routine.moveCount) MOVES   \(routine.intensity.label.uppercased())")
                        .foregroundColor(Theme.textMuted))
                        .font(.system(size: 11, weight: .heavy)).tracking(1)
                        .lineLimit(1).minimumScaleFactor(0.75)
                }
                Spacer(minLength: 6)
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(Theme.textMuted)
                    .padding(.trailing, 14)
            }
            .padding(.vertical, 12)
            .padding(.leading, 12)
        }
        .background(Theme.surface)
        .clipShape(shape)
        .overlay(shape.stroke(Theme.stroke, lineWidth: 1))
        .contentShape(shape)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(routine.title), \(routine.minutes) minutes, \(routine.moveCount) moves, \(routine.intensity.label)")
    }
}

// MARK: - Featured card (wide poster)

struct PadFeaturedCard: View {
    let routine: Routine
    var height: CGFloat = 340

    private let shape = CutCorner(cut: 26, corners: [.topRight, .bottomLeft])

    var body: some View {
        NavigationLink(value: routine) {
            Color.clear
                .frame(height: height)
                .frame(maxWidth: .infinity)
                .overlay { Image(routine.banner).resizable().scaledToFill() }
                .overlay {
                    LinearGradient(colors: [.clear, Theme.canvas.opacity(0.95)],
                                   startPoint: .top, endPoint: .bottom)
                }
                .overlay(alignment: .trailing) {
                    Slash().fill(routine.accent).frame(width: 110)
                        .opacity(0.9).blendMode(.overlay)
                }
                .overlay(alignment: .bottom) {
                    HStack(alignment: .bottom, spacing: 16) {
                        VStack(alignment: .leading, spacing: 10) {
                            Tag(text: "Recommended", color: routine.accent, filled: true)
                            Text(routine.title)
                                .font(.display(44)).foregroundStyle(.white)
                                .textCase(.uppercase).lineSpacing(-3)
                            Text(routine.subtitle)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.85))
                                .lineLimit(2)
                            HStack(spacing: 16) {
                                Label("\(routine.minutes) min", systemImage: "clock.fill")
                                Label("\(routine.moveCount) moves", systemImage: "figure.run")
                                Label(routine.intensity.label, systemImage: "flame.fill")
                            }
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white.opacity(0.9))
                        }
                        Spacer(minLength: 0)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20, weight: .black))
                            .foregroundStyle(Theme.canvas)
                            .frame(width: 56, height: 56)
                            .background(CutCorner(cut: 12, corners: [.topRight, .bottomLeft]).fill(routine.accent))
                            .shadow(color: routine.accent.opacity(0.4), radius: 16, y: 6)
                    }
                    .padding(26)
                }
                .clipShape(shape)
                .overlay(shape.stroke(routine.accent.opacity(0.5), lineWidth: 1.5))
                .contentShape(shape)
                .padHover()
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Recommended: \(routine.title), \(routine.minutes) minutes")
    }
}

// MARK: - Category tile (flexible 4:5, or a fixed size for the rail)

struct PadCategoryTile: View {
    let category: WarmupCategory
    var fixedSize: CGSize? = nil

    private let shape = CutCorner(cut: 16, corners: [.topRight, .bottomLeft])

    var body: some View {
        base
            .overlay { Image(category.banner).resizable().scaledToFill() }
            .overlay {
                LinearGradient(colors: [.clear, Theme.canvas.opacity(0.92)],
                               startPoint: .center, endPoint: .bottom)
            }
            .overlay(alignment: .topLeading) {
                Image(systemName: category.icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(category.accent)
                    .padding(16)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.short)
                        .font(.display(26)).foregroundStyle(.white).textCase(.uppercase)
                    Text("\(Library.routines(for: category).count) routines")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white.opacity(0.75))
                }
                .padding(16)
            }
            .clipShape(shape)
            .overlay(shape.stroke(category.accent.opacity(0.4), lineWidth: 1))
            .contentShape(shape)
            .padHover()
            .accessibilityElement(children: .combine)
    }

    @ViewBuilder private var base: some View {
        if let fixedSize {
            Color.clear.frame(width: fixedSize.width, height: fixedSize.height)
        } else {
            Color.clear.aspectRatio(0.8, contentMode: .fit)
        }
    }
}

// MARK: - Category routines

struct PadCategoryRoutinesView: View {
    let category: WarmupCategory

    private var routines: [Routine] { Library.routines(for: category) }

    var body: some View {
        WidthReader { width in
            let w = PadMetrics.contentWidth(for: width)
            let wide = w >= PadMetrics.twoPaneBreakpoint
            PadPage(asset: category.banner, accent: category.accent, dim: 0.9) {
                VStack(alignment: .leading, spacing: 32) {
                    PadTwoPane(width: w, leadingFraction: 0.46, spacing: 32) {
                        PadHero(asset: category.banner, accent: category.accent, tag: category.short,
                                title: category.title, subtitle: category.blurb, titleSize: 46)
                            .frame(height: wide ? 380 : 280)
                    } trailing: {
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(eyebrow: "In this arena", title: "Routines",
                                          accent: category.accent, trailing: "\(routines.count)")
                            VStack(spacing: 12) {
                                ForEach(routines) { routine in
                                    NavigationLink(value: routine) { PadRoutineRow(routine: routine).padHover() }
                                        .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    FooterNote()
                }
            }
        }
        .navigationTitle(category.short)
    }
}
