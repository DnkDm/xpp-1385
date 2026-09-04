import SwiftUI

struct PadMiniView: View {
    @Environment(PadSessionPresenter.self) private var presenter

    var body: some View {
        WidthReader { width in
            let w = PadMetrics.contentWidth(for: width)
            PadPage(asset: "banner_desk", accent: Theme.volt, dim: 0.9) {
                VStack(alignment: .leading, spacing: 32) {
                    PadPageHeader(eyebrow: "Anytime, anywhere", title: "Mini\nMoves",
                                  blurb: "Short resets for the desk, the commute and the in-between moments — no gym, no kit.")

                    let cols = PadMetrics.columns(fitting: 360, in: w, max: 3)
                    LazyVGrid(columns: PadMetrics.grid(cols), spacing: PadMetrics.gridGap) {
                        ForEach(Library.miniWarmups) { mini in
                            Button { presenter.start(mini) } label: {
                                MiniCard(mini: mini).padHover()
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("\(mini.title), \(mini.minutes) minutes")
                            .accessibilityHint("Starts the mini warm-up")
                        }
                    }

                    PadNoteCard(icon: "lightbulb.fill",
                                text: "Aim for one mini-move every hour you sit. Small, frequent movement beats one big stretch.")
                        .frame(maxWidth: 720, alignment: .leading)

                    FooterNote()
                }
            }
        }
    }
}
