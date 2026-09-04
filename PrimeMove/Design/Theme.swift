import SwiftUI

/// PrimeMove visual language: near-black canvas, acid-volt + signal-orange accents,
/// heavy condensed type and hard angular geometry. Aggressive, modern, reliable.
enum Theme {

    // MARK: Core palette
    static let canvas       = Color(hex: 0x0A0B0D)   // app background
    static let surface      = Color(hex: 0x131418)   // cards
    static let surfaceHi     = Color(hex: 0x1C1E24)   // elevated cards / inputs
    static let stroke       = Color(hex: 0x2A2D35)   // hairlines
    static let strokeSoft   = Color(hex: 0x1F2228)

    static let textPrimary  = Color(hex: 0xF4F5F2)
    static let textSecondary = Color(hex: 0x9BA1A9)
    static let textMuted    = Color(hex: 0x6A7078)

    // MARK: Accents
    static let volt   = Color(hex: 0xC8FF2E)   // primary
    static let signal = Color(hex: 0xFF5A1F)   // secondary
    static let cyan   = Color(hex: 0x18E0FF)
    static let magenta = Color(hex: 0xFF2E7E)
    static let violet = Color(hex: 0xA98BFF)
    static let danger = Color(hex: 0xFF3B30)   // emergency

    // MARK: Gradients
    static let voltGradient = LinearGradient(
        colors: [Color(hex: 0xD6FF3A), Color(hex: 0x9BE000)],
        startPoint: .topLeading, endPoint: .bottomTrailing)

    static func glow(_ c: Color) -> Color { c.opacity(0.55) }
}

// MARK: - Typography

extension Font {
    /// Massive condensed display headline.
    static func display(_ size: CGFloat, _ weight: Font.Weight = .black) -> Font {
        .system(size: size, weight: weight).width(.condensed)
    }
    /// Heavy label, slightly condensed.
    static func heavy(_ size: CGFloat, _ weight: Font.Weight = .heavy) -> Font {
        .system(size: size, weight: weight).width(.condensed)
    }
    /// Monospaced digits for timers.
    static func tick(_ size: CGFloat) -> Font {
        .system(size: size, weight: .black, design: .rounded).monospacedDigit()
    }
}

extension Text {
    /// Uppercased eyebrow / tag label.
    func eyebrow(_ color: Color = Theme.textMuted) -> some View {
        self.font(.system(size: 12, weight: .heavy))
            .tracking(2.2)
            .textCase(.uppercase)
            .foregroundStyle(color)
    }
}

// MARK: - Angular geometry

/// Which corners a `CutCorner` slices.
struct CornerSet: OptionSet {
    let rawValue: Int
    static let topLeft     = CornerSet(rawValue: 1 << 0)
    static let topRight    = CornerSet(rawValue: 1 << 1)
    static let bottomRight = CornerSet(rawValue: 1 << 2)
    static let bottomLeft  = CornerSet(rawValue: 1 << 3)
}

/// Rectangle with two opposite corners sliced off — the app's signature sharp card.
struct CutCorner: Shape {
    var cut: CGFloat = 18
    var corners: CornerSet = [.topRight, .bottomLeft]

    func path(in rect: CGRect) -> Path {
        let c = min(cut, min(rect.width, rect.height) / 2)
        var p = Path()
        let tl = corners.contains(.topLeft) ? c : 0
        let tr = corners.contains(.topRight) ? c : 0
        let br = corners.contains(.bottomRight) ? c : 0
        let bl = corners.contains(.bottomLeft) ? c : 0

        p.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        if tr > 0 { p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + tr)) }
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
        if br > 0 { p.addLine(to: CGPoint(x: rect.maxX - br, y: rect.maxY)) }
        p.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
        if bl > 0 { p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - bl)) }
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
        if tl > 0 { p.addLine(to: CGPoint(x: rect.minX + tl, y: rect.minY)) }
        p.closeSubpath()
        return p
    }
}

/// A thin diagonal slash used as decoration.
struct Slash: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.maxX * 0.32, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX * 0.68, y: rect.minY))
        p.closeSubpath()
        return p
    }
}

// MARK: - Color hex

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue:  Double(hex & 0xFF) / 255,
            opacity: alpha)
    }
}
