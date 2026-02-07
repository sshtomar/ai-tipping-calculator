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

    // Coastline Citrus palette
    static let tippyInk = Color(
        light: Color(red: 0.063, green: 0.145, blue: 0.247),   // #10253F
        dark: Color(red: 0.875, green: 0.925, blue: 0.984)
    )
    static let tippyInkSecondary = Color(
        light: Color(red: 0.141, green: 0.278, blue: 0.404),   // #244767
        dark: Color(red: 0.710, green: 0.804, blue: 0.910)
    )
    static let tippyMutedInk = Color(
        light: Color(red: 0.420, green: 0.514, blue: 0.604),   // #6B839A
        dark: Color(red: 0.553, green: 0.635, blue: 0.722)
    )
    static let tippyPrimary = Color(
        light: Color(red: 1.0, green: 0.408, blue: 0.251),     // #FF6840
        dark: Color(red: 1.0, green: 0.490, blue: 0.320)
    )
    static let tippyPrimaryLight = Color(
        light: Color(red: 1.0, green: 0.408, blue: 0.251).opacity(0.12),
        dark: Color(red: 1.0, green: 0.490, blue: 0.320).opacity(0.18)
    )
    static let tippyPrimaryDark = Color(
        light: Color(red: 0.808, green: 0.286, blue: 0.173),
        dark: Color(red: 0.902, green: 0.384, blue: 0.255)
    )
    static let tippyYellow = Color(
        light: Color(red: 0.965, green: 0.702, blue: 0.110),   // #F6B31C
        dark: Color(red: 0.965, green: 0.776, blue: 0.255)
    )
    static let tippySky = Color(
        light: Color(red: 0.302, green: 0.565, blue: 1.0),     // #4D90FF
        dark: Color(red: 0.463, green: 0.647, blue: 1.0)
    )
    static let tippyGreen = Color(
        light: Color(red: 0.141, green: 0.702, blue: 0.604),   // #24B39A
        dark: Color(red: 0.239, green: 0.784, blue: 0.686)
    )
    static let tippyGreenLight = Color(
        light: Color(red: 0.800, green: 0.957, blue: 0.922),   // #CCF4EB
        dark: Color(red: 0.102, green: 0.267, blue: 0.239)
    )
    static let tippyRose = Color(
        light: Color(red: 1.0, green: 0.784, blue: 0.725),     // #FFC8B9
        dark: Color(red: 0.420, green: 0.271, blue: 0.243)
    )

    // Backgrounds
    static let tippyBackground = Color(
        light: Color(red: 1.0, green: 0.973, blue: 0.933),     // #FFF8EE
        dark: Color(red: 0.039, green: 0.086, blue: 0.157)
    )
    static let tippySurface = Color(
        light: .white,
        dark: Color(red: 0.071, green: 0.133, blue: 0.204)
    )
    static let tippySurfaceSecondary = Color(
        light: Color(red: 0.949, green: 0.961, blue: 0.980),   // #F2F5FA
        dark: Color(red: 0.102, green: 0.176, blue: 0.263)
    )

    // Text
    static let tippyText = tippyInk
    static let tippyTextSecondary = tippyInkSecondary
    static let tippyTextTertiary = tippyMutedInk

    // Borders
    static let tippyBorder = Color(
        light: Color(red: 0.839, green: 0.867, blue: 0.910),   // #D6DDE8
        dark: Color(red: 0.192, green: 0.278, blue: 0.380)
    )
    static let tippyBorderLight = Color(
        light: Color(red: 0.910, green: 0.929, blue: 0.961),
        dark: Color(red: 0.165, green: 0.235, blue: 0.329)
    )

    // Onboarding-specific deep ink
    static let tippyOnboardingBg = Color(
        light: Color(red: 0.063, green: 0.145, blue: 0.247),
        dark: Color(red: 0.039, green: 0.086, blue: 0.157)
    )
}

// MARK: - Backgrounds

struct TippyBackgroundView: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.985, blue: 0.961),
                Color(red: 0.985, green: 0.953, blue: 0.914),
                Color(red: 0.953, green: 0.973, blue: 1.0),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(alignment: .topLeading) {
            Circle()
                .fill(Color.tippyYellow.opacity(0.18))
                .frame(width: 280, height: 280)
                .offset(x: -120, y: -120)
        }
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(Color.tippySky.opacity(0.15))
                .frame(width: 260, height: 260)
                .offset(x: 100, y: -80)
        }
    }
}

private struct TippyScreenBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            TippyBackgroundView().ignoresSafeArea()
            content
        }
    }
}

// MARK: - ShapeStyle Convenience

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
    static var tippySky: Color { Color.tippySky }
    static var tippyRose: Color { Color.tippyRose }
}

// MARK: - Spacing Scale (4px grid)

enum TippySpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let base: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 40
}

// MARK: - Corner Radius Scale

enum TippyRadius {
    static let accent: CGFloat = 4
    static let chip: CGFloat = 11
    static let card: CGFloat = 16
    static let panel: CGFloat = 24
    // Use Capsule() for badges
}

// MARK: - Typography — Role-Based

extension Font {
    static let tippyHero = Font.system(size: 48, weight: .heavy, design: .rounded).monospacedDigit()
    static let tippyTitle = Font.system(size: 28, weight: .bold, design: .rounded)

    static let tippyMoneyLarge = Font.system(size: 40, weight: .heavy, design: .rounded).monospacedDigit()
    static let tippyMoney = Font.system(size: 20, weight: .bold, design: .rounded).monospacedDigit()
    static let tippyMono = Font.system(size: 12, weight: .medium, design: .monospaced)

    static let tippyLabel = Font.system(size: 11, weight: .semibold, design: .rounded)

    static let tippyBody = Font.system(.body)
    static let tippyCaption = Font.system(.footnote)
    static let tippySmall = Font.system(.caption).weight(.medium)
}

// MARK: - Shared Styles

struct TippyPrimaryButtonStyle: ViewModifier {
    var enabled: Bool = true

    func body(content: Content) -> some View {
        content
            .font(.body.weight(.semibold))
            .foregroundStyle(enabled ? .white : .tippyTextTertiary)
            .padding(.horizontal, TippySpacing.xl)
            .padding(.vertical, TippySpacing.base)
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if enabled {
                        LinearGradient(
                            colors: [.tippyPrimary, .tippyPrimaryDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color.tippySurfaceSecondary
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: TippyRadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: TippyRadius.card, style: .continuous)
                    .stroke(enabled ? Color.clear : Color.tippyBorder, lineWidth: 1)
            )
            .shadow(
                color: enabled ? Color.tippyPrimary.opacity(0.20) : Color.clear,
                radius: 12,
                y: 4
            )
    }
}

struct TippySecondaryButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.body.weight(.semibold))
            .foregroundStyle(.tippyTextSecondary)
            .padding(.horizontal, TippySpacing.xl)
            .padding(.vertical, TippySpacing.base)
            .frame(maxWidth: .infinity)
            .background(Color.tippySurface)
            .clipShape(RoundedRectangle(cornerRadius: TippyRadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: TippyRadius.card, style: .continuous)
                    .stroke(Color.tippyBorder, lineWidth: 1)
            )
    }
}

// MARK: - Unified Card Style

struct TippyCardStyle: ViewModifier {
    var isActive: Bool = false

    func body(content: Content) -> some View {
        content
            .background(Color.tippySurface.opacity(0.98))
            .clipShape(RoundedRectangle(cornerRadius: TippyRadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: TippyRadius.card, style: .continuous)
                    .stroke(
                        isActive ? Color.tippyPrimary.opacity(0.85) : Color.tippyBorder,
                        lineWidth: isActive ? 1.5 : 1
                    )
            )
            .shadow(
                color: Color.tippyInk.opacity(isActive ? 0.14 : 0.08),
                radius: isActive ? 14 : 8,
                y: isActive ? 6 : 3
            )
    }
}

extension View {
    func tippyScreenBackground() -> some View {
        modifier(TippyScreenBackgroundModifier())
    }

    func tippyPrimaryButton(enabled: Bool = true) -> some View {
        modifier(TippyPrimaryButtonStyle(enabled: enabled))
    }

    func tippySecondaryButton() -> some View {
        modifier(TippySecondaryButtonStyle())
    }

    func tippyCard(isActive: Bool = false) -> some View {
        modifier(TippyCardStyle(isActive: isActive))
    }

    // Keep old name as alias so call sites compile during migration
    func tippyCardBordered(isActive: Bool = false) -> some View {
        modifier(TippyCardStyle(isActive: isActive))
    }
}
