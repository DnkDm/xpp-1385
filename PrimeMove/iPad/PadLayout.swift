import SwiftUI

// MARK: - Metrics

/// Layout constants shared by every iPad screen.
enum PadMetrics {
    static let pagePadding: CGFloat = 32           // horizontal page inset
    static let pageTop: CGFloat = 16
    static let pageBottom: CGFloat = 56
    static let contentMaxWidth: CGFloat = 1240     // keeps line lengths sane on 13"
    static let gridGap: CGFloat = 16

    /// Below this content width, side-by-side panes stack vertically.
    static let twoPaneBreakpoint: CGFloat = 780
    /// Grid + inspector column needs at least this much.
    static let inspectorBreakpoint: CGFloat = 1000

    /// Pinned (non-scrolling) side panes need at least this much height.
    static let pinnedPaneMinHeight: CGFloat = 640

    static let sidebarMin: CGFloat = 236
    static let sidebarIdeal: CGFloat = 272
    static let sidebarMax: CGFloat = 320

    /// Usable content width for a page given the column width it lives in.
    static func contentWidth(for width: CGFloat) -> CGFloat {
        min(max(0, width - pagePadding * 2), contentMaxWidth)
    }

    /// Equal columns that fit `minItem`-wide items into `width`.
    static func columns(fitting minItem: CGFloat, in width: CGFloat,
                        gap: CGFloat = gridGap, max cap: Int = 4) -> Int {
        max(1, min(cap, Int((width + gap) / (minItem + gap))))
    }

    static func grid(_ count: Int, gap: CGFloat = gridGap) -> [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: gap), count: count)
    }
}

// MARK: - Size / width readers

/// Fills its container and hands the available size to `content`.
/// Wrap whole pages in it (never place it inside a ScrollView).
struct SizeReader<Content: View>: View {
    @ViewBuilder var content: (CGSize) -> Content

    var body: some View {
        GeometryReader { geo in
            content(geo.size)
                .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

/// `SizeReader` for layouts that only care about width.
struct WidthReader<Content: View>: View {
    @ViewBuilder var content: (CGFloat) -> Content

    var body: some View {
        SizeReader { content($0.width) }
    }
}

// MARK: - Background

/// Big-canvas backdrop: same palette as `ScreenBackground`, but the accent wash
/// is pinned to the top-trailing corner and scaled for a 13" screen.
struct PadBackground: View {
    var asset: String? = "bg_home"
    var accent: Color = Theme.volt
    var dim: Double = 0.86

    var body: some View {
        ZStack {
            Theme.canvas
            if let asset {
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
            // Decorative glow. It lives in an overlay of a size-less Color so its
            // 640pt footprint can never become a minimum size for the page.
            Color.clear
                .overlay(alignment: .topTrailing) {
                    accent.opacity(0.12)
                        .frame(width: 640, height: 640)
                        .blur(radius: 190)
                        .offset(x: 220, y: -280)
                }
                .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Page

/// Standard scrolling page: backdrop + width-capped, centred content.
struct PadPage<Content: View>: View {
    var asset: String? = "bg_home"
    var accent: Color = Theme.volt
    var dim: Double = 0.86
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            PadBackground(asset: asset, accent: accent, dim: dim)
            ScrollView {
                content()
                    .frame(maxWidth: PadMetrics.contentMaxWidth, alignment: .leading)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, PadMetrics.pagePadding)
                    .padding(.top, PadMetrics.pageTop)
                    .padding(.bottom, PadMetrics.pageBottom)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

// MARK: - Two panes

/// Two panes side by side when there is room, stacked otherwise.
struct PadTwoPane<Leading: View, Trailing: View>: View {
    var width: CGFloat                              // available content width
    var breakpoint: CGFloat = PadMetrics.twoPaneBreakpoint
    var leadingFraction: CGFloat = 0.42
    var spacing: CGFloat = 32
    @ViewBuilder var leading: () -> Leading
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        if width >= breakpoint {
            HStack(alignment: .top, spacing: spacing) {
                leading()
                    .frame(width: ((width - spacing) * leadingFraction).rounded(.down))
                trailing()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            VStack(alignment: .leading, spacing: spacing) {
                leading()
                trailing()
            }
        }
    }
}

// MARK: - Shared blocks

/// Eyebrow + oversized display title + blurb, used at the top of root pages.
struct PadPageHeader: View {
    var eyebrow: String
    var title: String
    var blurb: String
    var accent: Color = Theme.volt
    var titleSize: CGFloat = 56

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(eyebrow).eyebrow(accent)
            Text(title)
                .font(.display(titleSize))
                .foregroundStyle(Theme.textPrimary)
                .textCase(.uppercase)
                .lineSpacing(-5)
            Text(blurb)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
                .frame(maxWidth: 560, alignment: .leading)
        }
    }
}

/// Photo hero card with gradient and text block. Either give it an aspect
/// ratio (width / height) or an explicit frame — it fills whatever it is given.
struct PadHero: View {
    var asset: String
    var accent: Color
    var tag: String? = nil
    var title: String
    var subtitle: String? = nil
    var titleSize: CGFloat = 44
    var aspect: CGFloat? = nil
    var cut: CGFloat = 24
    var textInset: CGFloat = 24

    var body: some View {
        base
            .overlay {
                Image(asset)
                    .resizable()
                    .scaledToFill()
            }
            .overlay {
                LinearGradient(colors: [Theme.canvas.opacity(0.10), .clear, Theme.canvas.opacity(0.97)],
                               startPoint: .top, endPoint: .bottom)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 10) {
                    if let tag { Tag(text: tag, color: accent, filled: true) }
                    Text(title)
                        .font(.display(titleSize))
                        .foregroundStyle(.white)
                        .textCase(.uppercase)
                        .lineSpacing(-3)
                        .minimumScaleFactor(0.7)
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }
                .padding(textInset)
            }
            .clipShape(CutCorner(cut: cut, corners: [.topRight, .bottomLeft]))
            .overlay(CutCorner(cut: cut, corners: [.topRight, .bottomLeft])
                .stroke(accent.opacity(0.5), lineWidth: 1.5))
    }

    @ViewBuilder private var base: some View {
        if let aspect {
            Color.clear.aspectRatio(aspect, contentMode: .fit)
        } else {
            Color.clear
        }
    }
}

/// Informational card: icon + text, optionally tinted with an accent.
struct PadNoteCard: View {
    var icon: String
    var text: String
    var accent: Color = Theme.volt
    var tinted: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(accent)
                .padding(.top, 1)
            Text(text)
                .font(.system(size: 15, weight: tinted ? .semibold : .medium))
                .foregroundStyle(Theme.textSecondary)
                .lineSpacing(3)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tinted ? accent.opacity(0.10) : Theme.surface)
        .clipShape(CutCorner(cut: 14, corners: [.topRight, .bottomLeft]))
        .overlay(CutCorner(cut: 14, corners: [.topRight, .bottomLeft])
            .stroke(tinted ? accent.opacity(0.4) : Theme.stroke, lineWidth: 1))
    }
}

/// Search box matching the app's angular inputs.
struct PadSearchField: View {
    @Binding var text: String
    var placeholder: String = "Search"
    var isFocused: FocusState<Bool>.Binding

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundStyle(Theme.textMuted)
            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Theme.textPrimary)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .focused(isFocused)
            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(Theme.textMuted)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 13)
        .background(Theme.surfaceHi)
        .clipShape(CutCorner(cut: 8, corners: [.topRight, .bottomLeft]))
        .overlay(CutCorner(cut: 8, corners: [.topRight, .bottomLeft])
            .stroke(isFocused.wrappedValue ? Theme.volt.opacity(0.6) : Theme.stroke, lineWidth: 1))
    }
}

// MARK: - Pointer

extension View {
    /// Hover feedback for trackpad / mouse users on iPad.
    func padHover() -> some View {
        self.hoverEffect(.lift)
    }
}
