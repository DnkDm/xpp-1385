import SwiftUI

// MARK: - Which side of the body is showing

enum BodySide: String, CaseIterable, Identifiable {
    case front, back
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}

// MARK: - One tappable zone

/// A muscle group placed on the silhouette in normalized coordinates,
/// so the map scales to any size without a single hard-coded pixel.
private struct BodyZone: Identifiable {
    let muscle: MuscleGroup
    let x: CGFloat      // center, 0...1 of width
    let y: CGFloat      // center, 0...1 of height
    let w: CGFloat
    let h: CGFloat

    var id: String { "\(muscle.rawValue)-\(x)-\(y)" }

    func rect(in size: CGSize) -> CGRect {
        CGRect(x: (x - w / 2) * size.width,
               y: (y - h / 2) * size.height,
               width: w * size.width,
               height: h * size.height)
    }
}

private let frontZones: [BodyZone] = [
    BodyZone(muscle: .neck,      x: 0.50, y: 0.135, w: 0.16, h: 0.05),
    BodyZone(muscle: .shoulders, x: 0.29, y: 0.198, w: 0.18, h: 0.07),
    BodyZone(muscle: .shoulders, x: 0.71, y: 0.198, w: 0.18, h: 0.07),
    BodyZone(muscle: .chest,     x: 0.50, y: 0.245, w: 0.34, h: 0.10),
    BodyZone(muscle: .core,      x: 0.50, y: 0.355, w: 0.32, h: 0.13),
    BodyZone(muscle: .wrists,    x: 0.15, y: 0.430, w: 0.12, h: 0.10),
    BodyZone(muscle: .wrists,    x: 0.85, y: 0.430, w: 0.12, h: 0.10),
    BodyZone(muscle: .hips,      x: 0.50, y: 0.470, w: 0.34, h: 0.08),
    BodyZone(muscle: .quads,     x: 0.40, y: 0.610, w: 0.17, h: 0.19),
    BodyZone(muscle: .quads,     x: 0.60, y: 0.610, w: 0.17, h: 0.19),
    BodyZone(muscle: .calves,    x: 0.40, y: 0.805, w: 0.14, h: 0.14),
    BodyZone(muscle: .calves,    x: 0.60, y: 0.805, w: 0.14, h: 0.14),
    BodyZone(muscle: .ankles,    x: 0.40, y: 0.925, w: 0.13, h: 0.06),
    BodyZone(muscle: .ankles,    x: 0.60, y: 0.925, w: 0.13, h: 0.06)
]

private let backZones: [BodyZone] = [
    BodyZone(muscle: .neck,       x: 0.50, y: 0.135, w: 0.16, h: 0.05),
    BodyZone(muscle: .shoulders,  x: 0.27, y: 0.198, w: 0.20, h: 0.07),
    BodyZone(muscle: .shoulders,  x: 0.73, y: 0.198, w: 0.20, h: 0.07),
    BodyZone(muscle: .upperBack,  x: 0.50, y: 0.270, w: 0.34, h: 0.13),
    BodyZone(muscle: .lowerBack,  x: 0.50, y: 0.395, w: 0.30, h: 0.10),
    BodyZone(muscle: .glutes,     x: 0.50, y: 0.490, w: 0.34, h: 0.09),
    BodyZone(muscle: .hamstrings, x: 0.40, y: 0.630, w: 0.17, h: 0.19),
    BodyZone(muscle: .hamstrings, x: 0.60, y: 0.630, w: 0.17, h: 0.19),
    BodyZone(muscle: .calves,     x: 0.40, y: 0.805, w: 0.14, h: 0.14),
    BodyZone(muscle: .calves,     x: 0.60, y: 0.805, w: 0.14, h: 0.14),
    BodyZone(muscle: .ankles,     x: 0.40, y: 0.925, w: 0.13, h: 0.06),
    BodyZone(muscle: .ankles,     x: 0.60, y: 0.925, w: 0.13, h: 0.06)
]

// MARK: - Silhouette

/// A blocky, angular figure drawn from primitives — no art assets needed.
private struct Silhouette: View {
    var body: some View {
        GeometryReader { geo in
            let s = geo.size
            ZStack(alignment: .topLeading) {
                block(s, x: 0.50, y: 0.055, w: 0.17, h: 0.085)   // head
                block(s, x: 0.50, y: 0.135, w: 0.10, h: 0.05)    // neck
                block(s, x: 0.50, y: 0.310, w: 0.40, h: 0.28)    // torso
                block(s, x: 0.20, y: 0.310, w: 0.11, h: 0.24)    // left arm
                block(s, x: 0.80, y: 0.310, w: 0.11, h: 0.24)    // right arm
                block(s, x: 0.15, y: 0.440, w: 0.10, h: 0.09)    // left hand
                block(s, x: 0.85, y: 0.440, w: 0.10, h: 0.09)    // right hand
                block(s, x: 0.50, y: 0.480, w: 0.38, h: 0.10)    // pelvis
                block(s, x: 0.40, y: 0.700, w: 0.16, h: 0.34)    // left leg
                block(s, x: 0.60, y: 0.700, w: 0.16, h: 0.34)    // right leg
                block(s, x: 0.40, y: 0.940, w: 0.15, h: 0.06)    // left foot
                block(s, x: 0.60, y: 0.940, w: 0.15, h: 0.06)    // right foot
            }
        }
    }

    private func block(_ size: CGSize, x: CGFloat, y: CGFloat,
                       w: CGFloat, h: CGFloat) -> some View {
        CutCorner(cut: 6, corners: [.topRight, .bottomLeft])
            .fill(Theme.surfaceHi)
            .frame(width: w * size.width, height: h * size.height)
            .offset(x: (x - w / 2) * size.width, y: (y - h / 2) * size.height)
    }
}

// MARK: - Body map

/// Tap the parts of the body that feel tight. Selection drives the builder.
struct BodyMap: View {
    @Binding var selection: Set<MuscleGroup>
    var accent: Color = Theme.volt

    @State private var side: BodySide = .front

    private var zones: [BodyZone] { side == .front ? frontZones : backZones }

    var body: some View {
        VStack(spacing: 14) {
            sideToggle

            GeometryReader { geo in
                ZStack(alignment: .topLeading) {
                    Silhouette()
                    ForEach(zones) { zone in
                        zoneView(zone, in: geo.size)
                    }
                }
            }
            .aspectRatio(0.52, contentMode: .fit)
            .frame(maxWidth: .infinity)

            Text(selection.isEmpty
                 ? "Tap anything that feels tight or stiff."
                 : selection.sorted { $0.title < $1.title }.map(\.title).joined(separator: " · "))
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(selection.isEmpty ? Theme.textMuted : accent)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .animation(.snappy(duration: 0.2), value: selection)
        }
    }

    private var sideToggle: some View {
        HStack(spacing: 8) {
            ForEach(BodySide.allCases) { s in
                Button {
                    guard side != s else { return }
                    Cue.tap()
                    side = s
                } label: {
                    Text(s.title)
                        .font(.system(size: 13, weight: .heavy)).tracking(1)
                        .textCase(.uppercase)
                        .foregroundStyle(side == s ? Theme.canvas : Theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(CutCorner(cut: 7, corners: [.topRight, .bottomLeft])
                            .fill(side == s ? accent : Theme.surfaceHi))
                        .overlay(CutCorner(cut: 7, corners: [.topRight, .bottomLeft])
                            .stroke(side == s ? .clear : Theme.stroke, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(side == s ? [.isSelected] : [])
            }
        }
    }

    private func zoneView(_ zone: BodyZone, in size: CGSize) -> some View {
        let rect = zone.rect(in: size)
        let on = selection.contains(zone.muscle)
        let shape = CutCorner(cut: 5, corners: [.topRight, .bottomLeft])

        return Button {
            Cue.tap()
            if on { selection.remove(zone.muscle) } else { selection.insert(zone.muscle) }
        } label: {
            shape
                .fill(on ? accent.opacity(0.85) : accent.opacity(0.07))
                .overlay(shape.stroke(on ? accent : accent.opacity(0.35),
                                      lineWidth: on ? 1.5 : 1))
                .shadow(color: on ? accent.opacity(0.5) : .clear, radius: 10)
                .frame(width: rect.width, height: rect.height)
        }
        .buttonStyle(.plain)
        .offset(x: rect.minX, y: rect.minY)
        .animation(.snappy(duration: 0.18), value: on)
        .accessibilityLabel(zone.muscle.title)
        .accessibilityAddTraits(on ? [.isSelected] : [])
    }
}

#Preview("Body map") {
    struct Wrapper: View {
        @State var picked: Set<MuscleGroup> = [.hips]
        var body: some View {
            ZStack {
                Theme.canvas.ignoresSafeArea()
                BodyMap(selection: $picked).padding(24)
            }
        }
    }
    return Wrapper().preferredColorScheme(.dark)
}
