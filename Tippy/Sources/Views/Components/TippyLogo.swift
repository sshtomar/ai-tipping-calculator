import SwiftUI

struct TippyLogoMark: View {
    var size: CGFloat = 52

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.545, blue: 0.337),
                            Color(red: 0.831, green: 0.373, blue: 0.220),
                            Color(red: 0.647, green: 0.271, blue: 0.157),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .fill(.white.opacity(0.18))
                .frame(width: size * 0.82, height: size * 0.82)
                .blur(radius: size * 0.025)
                .offset(x: -size * 0.07, y: -size * 0.08)

            Circle()
                .fill(Color(red: 1.0, green: 0.972, blue: 0.933))
                .frame(width: size * 0.74, height: size * 0.74)
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.85), lineWidth: size * 0.015)
                }

            Text("$")
                .font(.system(size: size * 0.43, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 0.682, green: 0.373, blue: 0.220))

            Image(systemName: "sparkle")
                .font(.system(size: size * 0.20, weight: .bold))
                .foregroundStyle(.white.opacity(0.95))
                .shadow(color: .white.opacity(0.35), radius: size * 0.06, y: size * 0.01)
                .offset(x: size * 0.24, y: -size * 0.22)

            Circle()
                .fill(.white.opacity(0.95))
                .frame(width: size * 0.07, height: size * 0.07)
                .offset(x: size * 0.32, y: -size * 0.34)
        }
        .frame(width: size, height: size)
        .shadow(color: Color.black.opacity(0.16), radius: size * 0.10, x: 0, y: size * 0.06)
        .accessibilityHidden(true)
    }
}

struct TippyLogoLockup: View {
    var iconSize: CGFloat = 52
    var titleFont: Font = .tippyTitle
    var titleColor: Color = .tippyText
    var subtitle: String? = nil
    var subtitleColor: Color = .tippyTextSecondary

    var body: some View {
        HStack(spacing: TippySpacing.md) {
            TippyLogoMark(size: iconSize)

            VStack(alignment: .leading, spacing: 2) {
                Text("Tippy")
                    .font(titleFont)
                    .foregroundStyle(titleColor)

                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(subtitleColor)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Tippy")
    }
}

#Preview {
    VStack(spacing: 20) {
        TippyLogoLockup(subtitle: "Know what to tip, always.")
        TippyLogoMark(size: 120)
    }
    .padding(24)
    .tippyScreenBackground()
}
