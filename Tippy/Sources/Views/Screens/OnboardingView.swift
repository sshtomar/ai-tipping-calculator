import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var appeared = false
    @State private var artPhase: CGFloat = 0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.tippyOnboardingBg,
                    Color(red: 0.071, green: 0.133, blue: 0.204),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .overlay(alignment: .topLeading) {
                Circle()
                    .fill(Color.tippyYellow.opacity(0.22))
                    .frame(width: 260, height: 260)
                    .offset(x: -120, y: -120)
            }
            .overlay(alignment: .topTrailing) {
                Circle()
                    .fill(Color.tippySky.opacity(0.16))
                    .frame(width: 220, height: 220)
                    .offset(x: 90, y: -90)
            }

            VStack(spacing: 0) {
                // Abstract generative art — crystal/prism shapes
                GeometryReader { geo in
                    Canvas { context, size in
                        drawAbstractArt(context: context, size: size, phase: artPhase)
                    }
                    .frame(width: geo.size.width, height: geo.size.width * 1.1)
                    .clipped()
                    .mask(
                        LinearGradient(
                            stops: [
                                .init(color: .white, location: 0),
                                .init(color: .white, location: 0.6),
                                .init(color: .clear, location: 1.0),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .frame(height: UIScreen.main.bounds.width * 1.0)

                Spacer()

                // Text content
                VStack(alignment: .leading, spacing: TippySpacing.lg) {
                    Text("WELCOME")
                        .font(.tippyMono)
                        .foregroundStyle(.white.opacity(0.65))
                        .tracking(1.0)

                    Text("Tip Smart.\nConfidently.\nAlways.")
                        .font(.system(size: 42, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Know exactly what to tip in every situation — from restaurants to rideshares, powered by smart context.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.75))
                        .lineSpacing(4)

                    Button(action: onComplete) {
                        HStack {
                            Text("Get Started")
                            Spacer()
                            Image(systemName: "arrow.right")
                                .font(.body.weight(.medium))
                        }
                        .tippyPrimaryButton()
                    }
                    .padding(.top, TippySpacing.sm)
                }
                .padding(.horizontal, TippySpacing.xl + TippySpacing.xs)
                .padding(.bottom, TippySpacing.xxl + TippySpacing.xl)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 30)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                appeared = true
            }
            // Slow single-pass animation instead of perpetual fast loop
            withAnimation(.linear(duration: 60).repeatForever(autoreverses: true)) {
                artPhase = 1
            }
        }
    }

    // MARK: - Abstract Art Drawing

    private func drawAbstractArt(context: GraphicsContext, size: CGSize, phase: CGFloat) {
        let cx = size.width / 2
        let cy = size.height / 2

        let tintColor = Color(red: 1.0, green: 0.408, blue: 0.251)

        // Background glow
        let glowRect = CGRect(x: cx - 180, y: cy - 200, width: 360, height: 400)
        context.fill(
            Path(ellipseIn: glowRect),
            with: .color(tintColor.opacity(0.03))
        )

        // Draw crystalline geometric shapes
        let shapes: [(CGPoint, CGSize, Double, Double)] = [
            (CGPoint(x: cx - 20, y: cy - 60), CGSize(width: 200, height: 280), -12, 0.08),
            (CGPoint(x: cx + 40, y: cy + 20), CGSize(width: 160, height: 240), 8, 0.06),
            (CGPoint(x: cx - 60, y: cy + 40), CGSize(width: 120, height: 200), -25, 0.05),
            (CGPoint(x: cx + 20, y: cy - 90), CGSize(width: 180, height: 140), 15, 0.07),
            (CGPoint(x: cx, y: cy), CGSize(width: 100, height: 320), -5, 0.04),
        ]

        for (center, shapeSize, rotation, opacity) in shapes {
            var ctx = context
            ctx.translateBy(x: center.x, y: center.y)
            ctx.rotate(by: .degrees(rotation + Double(phase) * 2))

            let rect = CGRect(
                x: -shapeSize.width / 2,
                y: -shapeSize.height / 2,
                width: shapeSize.width,
                height: shapeSize.height
            )

            // Crystal face — terracotta tint
            ctx.fill(
                Path(roundedRect: rect, cornerRadius: TippyRadius.accent),
                with: .linearGradient(
                    Gradient(colors: [
                        tintColor.opacity(opacity * 1.5),
                        .white.opacity(opacity * 0.5),
                        tintColor.opacity(opacity),
                    ]),
                    startPoint: CGPoint(x: rect.minX, y: rect.minY),
                    endPoint: CGPoint(x: rect.maxX, y: rect.maxY)
                )
            )

            // Edge highlight
            ctx.stroke(
                Path(roundedRect: rect, cornerRadius: TippyRadius.accent),
                with: .color(tintColor.opacity(opacity * 0.8)),
                lineWidth: 0.5
            )
        }

        // Light ray lines — terracotta tinted
        let rays: [(CGPoint, CGPoint, Double)] = [
            (CGPoint(x: cx - 100, y: cy - 150), CGPoint(x: cx + 80, y: cy + 120), 0.06),
            (CGPoint(x: cx + 60, y: cy - 180), CGPoint(x: cx - 40, y: cy + 100), 0.04),
            (CGPoint(x: cx - 30, y: cy - 200), CGPoint(x: cx + 30, y: cy + 150), 0.08),
        ]

        for (start, end, opacity) in rays {
            var path = Path()
            path.move(to: start)
            path.addLine(to: end)
            context.stroke(
                path,
                with: .color(tintColor.opacity(opacity)),
                lineWidth: 1.5
            )
        }

        // Scattered noise dots for texture
        let noiseCount = 80
        for i in 0..<noiseCount {
            let seed = Double(i) * 7.3 + Double(phase) * 0.1
            let nx = cx + CGFloat(sin(seed * 3.7) * 140)
            let ny = cy + CGFloat(cos(seed * 2.3) * 180)
            let dotSize: CGFloat = CGFloat(1 + sin(seed * 5.1) * 1.5)

            context.fill(
                Path(ellipseIn: CGRect(x: nx, y: ny, width: dotSize, height: dotSize)),
                with: .color(tintColor.opacity(0.04 + sin(seed) * 0.02))
            )
        }
    }
}

#Preview {
    OnboardingView { }
}
