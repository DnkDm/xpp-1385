import SwiftUI

// MARK: - Backgrounds

/// Full-screen dark backdrop with an optional decorative asset and angular glow.
struct ScreenBackground: View {
    var asset: String? = "bg_home"
    var accent: Color = Theme.volt
    var dim: Double = 0.82

    var body: some View {
        ZStack {
            Theme.canvas
            if let asset {
                // Exact-size frame + clip so the image NEVER overflows its bounds
                // and leaks its intrinsic width into the layout.
                GeometryReader { geo in
                    Image(asset)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .opacity(0.5)
                        .overlay(Theme.canvas.opacity(dim))
                }
            }
            // Angular accent wash, top-trailing
            accent.opacity(0.10)
                .frame(width: 360, height: 360)
                .blur(radius: 120)
                .offset(x: 150, y: -260)
        }
        .ignoresSafeArea()
    }
}

/// Subtle film grain to add grit over flat surfaces.
struct GrainOverlay: View {
    var opacity: Double = 0.05
    var body: some View {
        Canvas { ctx, size in
            for _ in 0..<900 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let r = CGFloat.random(in: 0.3...0.9)
                ctx.fill(Path(ellipseIn: CGRect(x: x, y: y, width: r, height: r)),
                         with: .color(.white.opacity(.random(in: 0.2...0.6))))
            }
        }
        .blendMode(.overlay)
        .opacity(opacity)
        .allowsHitTesting(false)
    }
}

// MARK: - Angular card surface

struct AngledCard<Content: View>: View {
    var fill: Color = Theme.surface
    var stroke: Color = Theme.stroke
    var cut: CGFloat = 16
    var corners: CornerSet = [.topRight, .bottomLeft]
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .background(
                CutCorner(cut: cut, corners: corners).fill(fill))
            .overlay(
                CutCorner(cut: cut, corners: corners)
                    .stroke(stroke, lineWidth: 1))
    }
}

// MARK: - Tags & chips

struct Tag: View {
    var text: String
    var color: Color = Theme.volt
    var filled: Bool = false

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .heavy))
            .tracking(1.4)
            .textCase(.uppercase)
            .foregroundStyle(filled ? Theme.canvas : color)
            .padding(.horizontal, 9).padding(.vertical, 5)
            .background(
                CutCorner(cut: 5, corners: [.topRight, .bottomLeft])
                    .fill(filled ? AnyShapeStyle(color) : AnyShapeStyle(color.opacity(0.14))))
    }
}

/// Section title with an accent slash, used across screens.
struct SectionHeader: View {
    var eyebrow: String
    var title: String
    var accent: Color = Theme.volt
    var trailing: String? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(eyebrow).eyebrow(accent)
                Text(title)
                    .font(.display(26))
                    .foregroundStyle(Theme.textPrimary)
                    .textCase(.uppercase)
            }
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.textSecondary)
            }
        }
    }
}

// MARK: - Buttons

struct PrimaryButton: View {
    var title: String
    var systemImage: String? = nil
    var accent: Color = Theme.volt
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let systemImage { Image(systemName: systemImage) }
                Text(title)
                    .font(.heavy(18))
                    .textCase(.uppercase)
                    .tracking(1)
            }
            .foregroundStyle(Theme.canvas)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(CutCorner(cut: 12, corners: [.topRight, .bottomLeft]).fill(accent))
            .shadow(color: accent.opacity(0.35), radius: 18, y: 8)
        }
        .buttonStyle(.plain)
    }
}

struct GhostButton: View {
    var title: String
    var systemImage: String? = nil
    var accent: Color = Theme.textPrimary
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage { Image(systemName: systemImage) }
                Text(title).font(.heavy(16)).textCase(.uppercase).tracking(1)
            }
            .foregroundStyle(accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(CutCorner(cut: 10, corners: [.topRight, .bottomLeft]).fill(Theme.surfaceHi))
            .overlay(CutCorner(cut: 10, corners: [.topRight, .bottomLeft]).stroke(Theme.stroke, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

/// Square icon button with angular cut.
struct IconButton: View {
    var systemImage: String
    var accent: Color = Theme.textPrimary
    var bg: Color = Theme.surfaceHi
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(accent)
                .frame(width: 46, height: 46)
                .background(CutCorner(cut: 8, corners: [.topRight, .bottomLeft]).fill(bg))
                .overlay(CutCorner(cut: 8, corners: [.topRight, .bottomLeft]).stroke(Theme.stroke, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Progress

/// Hard-edged segmented progress bar.
struct AngularProgress: View {
    var progress: Double          // 0...1
    var accent: Color = Theme.volt
    var height: CGFloat = 8

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle().fill(Theme.surfaceHi)
                Rectangle()
                    .fill(accent)
                    .frame(width: max(0, min(1, progress)) * geo.size.width)
                    .shadow(color: accent.opacity(0.6), radius: 8)
            }
        }
        .frame(height: height)
        .clipShape(CutCorner(cut: height/2, corners: [.topRight, .bottomLeft]))
    }
}

// MARK: - Stat pill

struct StatPill: View {
    var icon: String
    var value: String
    var label: String
    var accent: Color = Theme.volt
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(accent)
            VStack(alignment: .leading, spacing: 0) {
                Text(value).font(.heavy(17)).foregroundStyle(Theme.textPrimary)
                    .lineLimit(1).minimumScaleFactor(0.7)
                Text(label).eyebrow()
                    .lineLimit(1).minimumScaleFactor(0.7)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12).padding(.vertical, 10)
        .background(CutCorner(cut: 8, corners: [.topRight, .bottomLeft]).fill(Theme.surface))
        .overlay(CutCorner(cut: 8, corners: [.topRight, .bottomLeft]).stroke(Theme.stroke, lineWidth: 1))
    }
}
