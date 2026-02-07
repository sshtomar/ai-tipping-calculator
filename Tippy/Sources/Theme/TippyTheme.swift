import SwiftUI
import UIKit

// MARK: - Adaptive Color Helper

extension Color {
    init(light: Color, dark: Color) {
        self.init(UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

// MARK: - Color Palette

extension Color {
    static let tippyBg = Color("TippyBg", bundle: nil)

    // Warm terracotta primary
    static let tippyPrimary = Color(
        light: Color(red: 0.757, green: 0.498, blue: 0.349),
        dark: Color(red: 0.820, green: 0.576, blue: 0.447)
    )
    static let tippyPrimaryLight = Color(
        light: Color(red: 0.961, green: 0.929, blue: 0.906),
        dark: Color(red: 0.239, green: 0.180, blue: 0.141)
    )
    static let tippyPrimaryDark = Color(
        light: Color(red: 0.651, green: 0.420, blue: 0.286),
        dark: Color(red: 0.878, green: 0.647, blue: 0.502)
    )

    // Backgrounds
    static let tippyBackground = Color(
        light: Color(red: 0.980, green: 0.976, blue: 0.965),
        dark: Color(red: 0.110, green: 0.110, blue: 0.118)
    )
    static let tippySurface = Color(
        light: .white,
        dark: Color(red: 0.173, green: 0.173, blue: 0.180)
    )
    static let tippySurfaceSecondary = Color(
        light: Color(red: 0.953, green: 0.945, blue: 0.933),
        dark: Color(red: 0.227, green: 0.227, blue: 0.235)
    )

    // Text
    static let tippyText = Color(
        light: Color(red: 0.110, green: 0.110, blue: 0.118),
        dark: Color(red: 0.961, green: 0.961, blue: 0.969)
    )
    static let tippyTextSecondary = Color(
        light: Color(red: 0.420, green: 0.420, blue: 0.420),
        dark: Color(red: 0.627, green: 0.627, blue: 0.627)
    )
    static let tippyTextTertiary = Color(
        light: Color(red: 0.604, green: 0.604, blue: 0.604),
        dark: Color(red: 0.420, green: 0.420, blue: 0.420)
    )

    // Borders
    static let tippyBorder = Color(
        light: Color(red: 0.929, green: 0.922, blue: 0.910),
        dark: Color(red: 0.227, green: 0.227, blue: 0.235)
    )
    static let tippyBorderLight = Color(
        light: Color(red: 0.953, green: 0.945, blue: 0.933),
        dark: Color(red: 0.173, green: 0.173, blue: 0.180)
    )

    // Semantic
    static let tippyGreen = Color(
        light: Color(red: 0.357, green: 0.549, blue: 0.416),
        dark: Color(red: 0.420, green: 0.639, blue: 0.478)
    )
    static let tippyGreenLight = Color(
        light: Color(red: 0.922, green: 0.961, blue: 0.933),
        dark: Color(red: 0.118, green: 0.200, blue: 0.141)
    )
    static let tippyYellow = Color(
        light: Color(red: 0.831, green: 0.659, blue: 0.263),
        dark: Color(red: 0.878, green: 0.722, blue: 0.302)
    )
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
    static let tippySerif = Font.custom("Georgia", size: 32, relativeTo: .largeTitle)
    static let tippySerifLarge = Font.custom("Georgia", size: 48, relativeTo: .largeTitle)
    static let tippySerifHuge = Font.custom("Georgia", size: 42, relativeTo: .largeTitle)
    static let tippySerifMedium = Font.custom("Georgia", size: 24, relativeTo: .title2)
    static let tippySerifSmall = Font.custom("Georgia", size: 20, relativeTo: .title3)

    static let tippyLabel = Font.system(.footnote).weight(.semibold)
    static let tippyBody = Font.system(.body)
    static let tippyCaption = Font.system(.footnote)
    static let tippySmall = Font.system(.caption).weight(.medium)
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
