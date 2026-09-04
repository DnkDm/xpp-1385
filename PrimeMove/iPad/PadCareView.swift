import SwiftUI

// MARK: - Care (first aid)

struct PadCareView: View {
    var body: some View {
        WidthReader { width in
            let w = PadMetrics.contentWidth(for: width)
            PadPage(asset: "emergency_hero", accent: Theme.danger, dim: 0.9) {
                VStack(alignment: .leading, spacing: 32) {
                    PadTwoPane(width: w, leadingFraction: 0.5, spacing: 32) {
                        PadHero(asset: "emergency_hero", accent: Theme.danger, tag: "Emergency",
                                title: "Care &\nFirst Aid", titleSize: 48)
                            .frame(height: 300)
                    } trailing: {
                        VStack(alignment: .leading, spacing: 14) {
                            PadNoteCard(icon: "exclamationmark.triangle.fill",
                                        text: EmergencyLibrary.globalDisclaimer,
                                        accent: Theme.danger, tinted: true)
                            PadNoteCard(icon: "phone.fill",
                                        text: "In a real emergency call your local emergency number first. These guides cover the minutes before help arrives — they are not a substitute for medical care.",
                                        accent: Theme.danger)
                        }
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(eyebrow: "Before the ambulance", title: "First-Aid Guides",
                                      accent: Theme.danger, trailing: "\(EmergencyLibrary.protocols.count)")
                        let cols = PadMetrics.columns(fitting: 340, in: w, max: 3)
                        LazyVGrid(columns: PadMetrics.grid(cols), spacing: PadMetrics.gridGap) {
                            ForEach(EmergencyLibrary.protocols) { proto in
                                NavigationLink(value: proto.id) { CareCard(proto: proto).padHover() }
                                    .buttonStyle(.plain)
                            }
                        }
                    }

                    redFlags
                }
            }
        }
        .navigationDestination(for: String.self) { id in
            if let proto = EmergencyLibrary.protocols.first(where: { $0.id == id }) {
                PadCareDetailView(proto: proto)
            }
        }
    }

    private var redFlags: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(eyebrow: "Always call if", title: "Red Flags", accent: Theme.danger)
            VStack(alignment: .leading, spacing: 12) {
                ForEach(EmergencyLibrary.universalRedFlags, id: \.self) { flag in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "phone.fill.arrow.up.right")
                            .font(.system(size: 13)).foregroundStyle(Theme.danger)
                            .padding(.top, 3)
                        Text(flag)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface)
            .clipShape(CutCorner(cut: 14, corners: [.topRight, .bottomLeft]))
            .overlay(CutCorner(cut: 14, corners: [.topRight, .bottomLeft]).stroke(Theme.stroke, lineWidth: 1))
        }
        .frame(maxWidth: 820, alignment: .leading)
    }
}

// MARK: - Care detail

/// Wide: the numbered actions on the left, the "call if" / avoid / sources rail
/// on the right. Narrow: one column in the same order.
struct PadCareDetailView: View {
    let proto: EmergencyProtocol
    @Environment(\.openURL) private var openURL

    var body: some View {
        WidthReader { width in
            let w = PadMetrics.contentWidth(for: width)
            PadPage(asset: "bg_home", accent: proto.severityColor, dim: 0.92) {
                VStack(alignment: .leading, spacing: 30) {
                    header
                    Text(proto.overview)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                        .lineSpacing(4)
                        .frame(maxWidth: 760, alignment: .leading)

                    PadTwoPane(width: w, leadingFraction: 0.56, spacing: 36) {
                        doNowBlock
                    } trailing: {
                        VStack(alignment: .leading, spacing: 28) {
                            callBlock
                            avoidBlock
                            sourcesBlock
                        }
                    }

                    Text(EmergencyLibrary.globalDisclaimer)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.textMuted)
                        .lineSpacing(2)
                        .frame(maxWidth: 760, alignment: .leading)
                }
            }
        }
        .navigationTitle(proto.title)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 18) {
            ZStack {
                proto.severityColor.opacity(0.16)
                Image(systemName: proto.icon)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(proto.severityColor)
            }
            .frame(width: 92, height: 92)
            .clipShape(CutCorner(cut: 12, corners: [.topRight, .bottomLeft]))
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 8) {
                Tag(text: proto.severity, color: proto.severityColor, filled: true)
                Text(proto.title)
                    .font(.display(44)).foregroundStyle(Theme.textPrimary)
                    .textCase(.uppercase).lineSpacing(-3)
                Text(proto.tagline)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(.top, 4)
    }

    private var doNowBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(eyebrow: "Act now", title: "Do This", accent: proto.severityColor)
            VStack(spacing: 10) {
                ForEach(Array(proto.doNow.enumerated()), id: \.offset) { i, phase in
                    HStack(alignment: .top, spacing: 16) {
                        Text("\(i + 1)")
                            .font(.display(26)).foregroundStyle(proto.severityColor)
                            .frame(width: 30, alignment: .leading)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(phase.title)
                                .font(.heavy(18)).foregroundStyle(Theme.textPrimary)
                            Text(phase.detail)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Theme.textSecondary)
                                .lineSpacing(3)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.surface)
                    .clipShape(CutCorner(cut: 10, corners: [.topRight, .bottomLeft]))
                    .overlay(CutCorner(cut: 10, corners: [.topRight, .bottomLeft]).stroke(Theme.stroke, lineWidth: 1))
                }
            }
        }
    }

    private var avoidBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(eyebrow: "Don't", title: "Avoid", accent: Theme.signal)
            VStack(alignment: .leading, spacing: 12) {
                ForEach(proto.avoid, id: \.self) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "xmark.octagon.fill")
                            .font(.system(size: 15)).foregroundStyle(Theme.signal)
                            .padding(.top, 2)
                        Text(item)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Theme.textSecondary)
                            .lineSpacing(3)
                    }
                }
            }
        }
    }

    private var callBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "phone.fill").foregroundStyle(Theme.danger)
                Text("Call emergency services if").eyebrow(Theme.danger)
            }
            VStack(alignment: .leading, spacing: 12) {
                ForEach(proto.callEmergencyIf, id: \.self) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 13)).foregroundStyle(Theme.danger)
                            .padding(.top, 3)
                        Text(item)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Theme.textPrimary)
                            .lineSpacing(3)
                    }
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.danger.opacity(0.10))
            .clipShape(CutCorner(cut: 14, corners: [.topRight, .bottomLeft]))
            .overlay(CutCorner(cut: 14, corners: [.topRight, .bottomLeft]).stroke(Theme.danger.opacity(0.4), lineWidth: 1))
        }
    }

    private var sourcesBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(eyebrow: "Where this comes from", title: "Sources", accent: proto.severityColor)
            VStack(spacing: 10) {
                ForEach(proto.sources) { src in
                    Button { openURL(src.url) } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "doc.text.fill")
                                .foregroundStyle(proto.severityColor)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(src.publisher).eyebrow(proto.severityColor)
                                Text(src.title)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Theme.textPrimary)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 13, weight: .heavy))
                                .foregroundStyle(Theme.textMuted)
                        }
                        .padding(14)
                        .background(Theme.surface)
                        .clipShape(CutCorner(cut: 10, corners: [.topRight, .bottomLeft]))
                        .overlay(CutCorner(cut: 10, corners: [.topRight, .bottomLeft]).stroke(Theme.stroke, lineWidth: 1))
                        .padHover()
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Opens in the browser")
                }
            }
        }
    }
}
