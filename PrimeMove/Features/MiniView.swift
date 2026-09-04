import SwiftUI

struct MiniView: View {
    @State private var active: MiniWarmup? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                ScreenBackground(asset: "banner_desk", accent: Theme.volt, dim: 0.9)
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        header
                        ForEach(Library.miniWarmups) { mini in
                            Button { Cue.tap(); active = mini } label: { MiniCard(mini: mini) }
                                .buttonStyle(.plain)
                        }
                        tipCard
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .fullScreenCover(item: $active) { mini in
                SessionView(engine: SessionEngine(steps: mini.steps, accent: mini.accent, title: mini.title))
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Anytime, anywhere").eyebrow(Theme.volt)
            Text("Mini\nMoves")
                .font(.display(42)).foregroundStyle(Theme.textPrimary).textCase(.uppercase)
            Text("Short resets for the desk, the commute and the in-between moments — no gym, no kit.")
                .font(.system(size: 14, weight: .medium)).foregroundStyle(Theme.textSecondary)
        }
    }

    private var tipCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb.fill").foregroundStyle(Theme.volt)
            Text("Aim for one mini-move every hour you sit. Small, frequent movement beats one big stretch.")
                .font(.system(size: 13, weight: .medium)).foregroundStyle(Theme.textSecondary)
        }
        .padding(14)
        .background(Theme.surface)
        .clipShape(CutCorner(cut: 10, corners: [.topRight, .bottomLeft]))
        .overlay(CutCorner(cut: 10, corners: [.topRight, .bottomLeft]).stroke(Theme.stroke, lineWidth: 1))
    }
}

struct MiniCard: View {
    let mini: MiniWarmup
    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                mini.accent.opacity(0.16)
                Image(systemName: mini.icon)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(mini.accent)
            }
            .frame(width: 76)
            .frame(maxHeight: .infinity)

            VStack(alignment: .leading, spacing: 4) {
                Text(mini.context).eyebrow(mini.accent)
                Text(mini.title)
                    .font(.heavy(20)).foregroundStyle(Theme.textPrimary).textCase(.uppercase)
                HStack(spacing: 10) {
                    Text("\(mini.minutes) MIN").foregroundStyle(mini.accent)
                    Text("\(mini.steps.count) MOVES").foregroundStyle(Theme.textMuted)
                }
                .font(.system(size: 11, weight: .heavy)).tracking(1)
            }
            .padding(.vertical, 16).padding(.leading, 14)
            Spacer()
            Image(systemName: "play.fill")
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(Theme.canvas)
                .frame(width: 44, height: 44)
                .background(CutCorner(cut: 8, corners: [.topRight, .bottomLeft]).fill(mini.accent))
                .padding(.trailing, 14)
        }
        .frame(height: 96)
        .background(Theme.surface)
        .clipShape(CutCorner(cut: 14, corners: [.topRight, .bottomLeft]))
        .overlay(CutCorner(cut: 14, corners: [.topRight, .bottomLeft]).stroke(Theme.stroke, lineWidth: 1))
    }
}
