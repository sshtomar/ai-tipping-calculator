import SwiftUI

// MARK: - Color Palette

extension Color {
    static let tippyBg = Color("TippyBg", bundle: nil)

    // Warm terracotta primary
    static let tippyPrimary = Color(red: 0.757, green: 0.498, blue: 0.349)
    static let tippyPrimaryLight = Color(red: 0.961, green: 0.929, blue: 0.906)
    static let tippyPrimaryDark = Color(red: 0.651, green: 0.420, blue: 0.286)

    // Backgrounds
    static let tippyBackground = Color(red: 0.980, green: 0.976, blue: 0.965)
    static let tippySurface = Color.white
    static let tippySurfaceSecondary = Color(red: 0.953, green: 0.945, blue: 0.933)

    // Text
    static let tippyText = Color(red: 0.110, green: 0.110, blue: 0.118)
    static let tippyTextSecondary = Color(red: 0.420, green: 0.420, blue: 0.420)
    static let tippyTextTertiary = Color(red: 0.604, green: 0.604, blue: 0.604)

    // Borders
    static let tippyBorder = Color(red: 0.929, green: 0.922, blue: 0.910)
    static let tippyBorderLight = Color(red: 0.953, green: 0.945, blue: 0.933)

    // Semantic
    static let tippyGreen = Color(red: 0.357, green: 0.549, blue: 0.416)
    static let tippyGreenLight = Color(red: 0.922, green: 0.961, blue: 0.933)
    static let tippyYellow = Color(red: 0.831, green: 0.659, blue: 0.263)
}

// MARK: - ShapeStyle Convenience (enables .foregroundStyle(.tippyPrimary) syntax)

extension ShapeStyle where Self == Color {
    static var tippyPrimary: Color { Color.tippyPrimary }
    static var tippyPrimaryLight: Color { Color.tippyPrimaryLight }
    static var tippyPrimaryDark: Color { Color.tippyPrimaryDark }
    static var tippyBackground: Color { Color.tippyBackground }
    static var tippySurface: Color { Color.tippySurface }
    static var tippySurfaceSecondary: Color { Color.tippySurfaceSecondary }
    static var tippyText: Color { Color.tippyText }
    static var tippyTextSecondary: Color { Color.tippyTextSecondary }
    static var tippyTextTertiary: Color { Color.tippyTextTertiary }
    static var tippyBorder: Color { Color.tippyBorder }
    static var tippyBorderLight: Color { Color.tippyBorderLight }
    static var tippyGreen: Color { Color.tippyGreen }
    static var tippyGreenLight: Color { Color.tippyGreenLight }
    static var tippyYellow: Color { Color.tippyYellow }
}

// MARK: - Typography

extension Font {
    static let tippySerif = Font.custom("Georgia", size: 32)
    static let tippySerifLarge = Font.custom("Georgia", size: 48)
    static let tippySerifHuge = Font.custom("Georgia", size: 42)
    static let tippySerifMedium = Font.custom("Georgia", size: 24)
    static let tippySerifSmall = Font.custom("Georgia", size: 20)

    static let tippyLabel = Font.system(size: 13, weight: .semibold)
    static let tippyBody = Font.system(size: 16)
    static let tippyCaption = Font.system(size: 13)
    static let tippySmall = Font.system(size: 12, weight: .medium)
}

// MARK: - Shared Styles

struct TippyCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.tippySurface)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.tippyBorder, lineWidth: 1.5)
            )
    }
}

extension View {
    func tippyCard() -> some View {
        modifier(TippyCardStyle())
    }
}
