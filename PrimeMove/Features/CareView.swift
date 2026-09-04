import SwiftUI

struct CareView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                ScreenBackground(asset: "emergency_hero", accent: Theme.danger, dim: 0.9)
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        hero
                        disclaimerCard
                        SectionHeader(eyebrow: "Before the ambulance", title: "First-Aid Guides",
                                      accent: Theme.danger)
                        ForEach(EmergencyLibrary.protocols) { proto in
                            NavigationLink(value: proto.id) { CareCard(proto: proto) }
                                .buttonStyle(.plain)
                        }
                        emergencyCallNote
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
                .navigationDestination(for: String.self) { id in
                    if let proto = EmergencyLibrary.protocols.first(where: { $0.id == id }) {
                        CareDetailView(proto: proto)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            Image("emergency_hero")
                .resizable().scaledToFill()
                .frame(maxWidth: .infinity).frame(height: 220).clipped()
            LinearGradient(colors: [.clear, Theme.canvas], startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 8) {
                Tag(text: "Emergency", color: Theme.danger, filled: true)
                Text("Care &\nFirst Aid")
                    .font(.display(36)).foregroundStyle(.white).textCase(.uppercase)
            }
            .padding(18)
        }
        .frame(height: 220)
        .clipShape(CutCorner(cut: 20, corners: [.topRight, .bottomLeft]))
        .overlay(CutCorner(cut: 20, corners: [.topRight, .bottomLeft]).stroke(Theme.danger.opacity(0.5), lineWidth: 1.5))
    }

    private var disclaimerCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 18)).foregroundStyle(Theme.danger)
            Text(EmergencyLibrary.globalDisclaimer)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.textSecondary).lineSpacing(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.danger.opacity(0.10))
        .clipShape(CutCorner(cut: 14, corners: [.topRight, .bottomLeft]))
        .overlay(CutCorner(cut: 14, corners: [.topRight, .bottomLeft]).stroke(Theme.danger.opacity(0.4), lineWidth: 1))
    }

    private var emergencyCallNote: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(eyebrow: "Always call if", title: "Red Flags", accent: Theme.danger)
            VStack(alignment: .leading, spacing: 10) {
                ForEach(EmergencyLibrary.universalRedFlags, id: \.self) { flag in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "phone.fill.arrow.up.right")
                            .font(.system(size: 13)).foregroundStyle(Theme.danger).padding(.top, 2)
                        Text(flag).font(.system(size: 14, weight: .medium)).foregroundStyle(Theme.textSecondary)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface)
            .clipShape(CutCorner(cut: 14, corners: [.topRight, .bottomLeft]))
            .overlay(CutCorner(cut: 14, corners: [.topRight, .bottomLeft]).stroke(Theme.stroke, lineWidth: 1))
        }
    }
}

// MARK: - Care card

struct CareCard: View {
    let proto: EmergencyProtocol
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                proto.severityColor.opacity(0.16)
                Image(systemName: proto.icon)
                    .font(.system(size: 24, weight: .bold)).foregroundStyle(proto.severityColor)
            }
            .frame(width: 64, height: 64)
            .clipShape(CutCorner(cut: 8, corners: [.topRight, .bottomLeft]))

            VStack(alignment: .leading, spacing: 4) {
                Text(proto.title)
                    .font(.heavy(18)).foregroundStyle(Theme.textPrimary).textCase(.uppercase)
                Text(proto.tagline)
                    .font(.system(size: 12, weight: .medium)).foregroundStyle(Theme.textSecondary)
                    .lineLimit(2)
                Tag(text: proto.severity, color: proto.severityColor)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .heavy)).foregroundStyle(Theme.textMuted)
        }
        .padding(12)
        .background(Theme.surface)
        .clipShape(CutCorner(cut: 12, corners: [.topRight, .bottomLeft]))
        .overlay(CutCorner(cut: 12, corners: [.topRight, .bottomLeft]).stroke(Theme.stroke, lineWidth: 1))
    }
}

// MARK: - Care detail

struct CareDetailView: View {
    let proto: EmergencyProtocol
    @Environment(\.openURL) private var openURL

    var body: some View {
        ZStack {
            ScreenBackground(asset: "bg_home", accent: proto.severityColor, dim: 0.92)
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    overview
                    doNowBlock
                    avoidBlock
                    callBlock
                    sourcesBlock
                    footerDisclaimer
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                ZStack {
                    proto.severityColor.opacity(0.16)
                    Image(systemName: proto.icon)
                        .font(.system(size: 30, weight: .bold)).foregroundStyle(proto.severityColor)
                }
                .frame(width: 76, height: 76)
                .clipShape(CutCorner(cut: 10, corners: [.topRight, .bottomLeft]))
                VStack(alignment: .leading, spacing: 6) {
                    Tag(text: proto.severity, color: proto.severityColor, filled: true)
                    Text(proto.title)
                        .font(.display(30)).foregroundStyle(Theme.textPrimary).textCase(.uppercase)
                }
            }
            .padding(.top, 6)
        }
    }

    private var overview: some View {
        Text(proto.overview)
            .font(.system(size: 15, weight: .medium)).foregroundStyle(Theme.textSecondary).lineSpacing(3)
    }

    private var doNowBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(eyebrow: "Act now", title: "Do This", accent: proto.severityColor)
            VStack(spacing: 10) {
                ForEach(Array(proto.doNow.enumerated()), id: \.offset) { i, phase in
                    HStack(alignment: .top, spacing: 14) {
                        Text("\(i + 1)")
                            .font(.display(22)).foregroundStyle(proto.severityColor)
                            .frame(width: 28, alignment: .leading)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(phase.title)
                                .font(.heavy(16)).foregroundStyle(Theme.textPrimary)
                            Text(phase.detail)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Theme.textSecondary).lineSpacing(2)
                        }
                    }
                    .padding(14)
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
            VStack(alignment: .leading, spacing: 10) {
                ForEach(proto.avoid, id: \.self) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "xmark.octagon.fill")
                            .font(.system(size: 14)).foregroundStyle(Theme.signal).padding(.top, 2)
                        Text(item).font(.system(size: 14, weight: .medium)).foregroundStyle(Theme.textSecondary)
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
            VStack(alignment: .leading, spacing: 10) {
                ForEach(proto.callEmergencyIf, id: \.self) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 13)).foregroundStyle(Theme.danger).padding(.top, 2)
                        Text(item).font(.system(size: 14, weight: .semibold)).foregroundStyle(Theme.textPrimary)
                    }
                }
            }
            .padding(16)
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
                                    .foregroundStyle(Theme.textPrimary).multilineTextAlignment(.leading)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 13, weight: .heavy)).foregroundStyle(Theme.textMuted)
                        }
                        .padding(14)
                        .background(Theme.surface)
                        .clipShape(CutCorner(cut: 10, corners: [.topRight, .bottomLeft]))
                        .overlay(CutCorner(cut: 10, corners: [.topRight, .bottomLeft]).stroke(Theme.stroke, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var footerDisclaimer: some View {
        Text(EmergencyLibrary.globalDisclaimer)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Theme.textMuted).lineSpacing(2)
            .padding(.top, 6)
    }
}
