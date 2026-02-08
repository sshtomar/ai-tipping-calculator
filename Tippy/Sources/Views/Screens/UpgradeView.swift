import SwiftUI
import StoreKit

struct UpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var manager = SubscriptionManager()
    @State private var selectedPlan: Plan = .annual
    @State private var appeared = false

    enum Plan { case monthly, annual }

    // MARK: - Computed pricing

    private var monthlyProduct: Product? {
        manager.products.first { $0.id == "tippy_pro_monthly" }
    }

    private var annualProduct: Product? {
        manager.products.first { $0.id == "tippy_pro_annual" }
    }

    private var monthlyPrice: String {
        monthlyProduct?.displayPrice ?? "$2.99"
    }

    private var annualPrice: String {
        annualProduct?.displayPrice ?? "$19.99"
    }

    private var savingsPercent: Int {
        guard let mp = monthlyProduct, let ap = annualProduct else { return 44 }
        let monthlyTotal = mp.price * 12
        guard monthlyTotal > 0 else { return 44 }
        let fraction = (monthlyTotal - ap.price) / monthlyTotal
        return NSDecimalNumber(decimal: fraction * 100).intValue
    }

    private var hasProducts: Bool { !manager.products.isEmpty }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: TippySpacing.xxl) {
                    heroSection
                    featureCards
                    pricingSection
                    continueButton
                    restoreLink
                }
                .padding(.horizontal, TippySpacing.xl)
                .padding(.top, TippySpacing.lg)
                .padding(.bottom, TippySpacing.xxl + TippySpacing.sm)
            }
            .tippyScreenBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(.tippyTextSecondary)
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    appeared = true
                }
            }
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: TippySpacing.md) {
            TippyLogoMark(size: 64)
                .shadow(color: .tippyPrimary.opacity(0.35), radius: 16, y: 4)
                .scaleEffect(appeared ? 1.0 : 0.95)
                .modifier(PulseModifier())

            Text("Tippy Pro")
                .font(.tippyTitle)
                .foregroundStyle(.tippyText)

            Text("Unlimited AI-powered tip recommendations")
                .font(.subheadline)
                .foregroundStyle(.tippyTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, TippySpacing.xl)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
    }

    // MARK: - Feature Cards

    private var featureCards: some View {
        VStack(spacing: TippySpacing.md) {
            featureCard(
                icon: "brain",
                title: "Unlimited AI Tips",
                caption: "No daily limits on smart calculations",
                gradient: [.tippyYellow.opacity(0.18), .tippyRose.opacity(0.18)]
            )
            featureCard(
                icon: "location",
                title: "Location-Aware",
                caption: "Regional customs built into every suggestion",
                gradient: [.tippySky.opacity(0.15), .tippyGreen.opacity(0.15)]
            )
            featureCard(
                icon: "heart",
                title: "Support Indie Dev",
                caption: "Keep Tippy ad-free and improving",
                gradient: [.tippyPrimary.opacity(0.14), .tippyYellow.opacity(0.14)]
            )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .animation(.easeOut(duration: 0.5).delay(0.15), value: appeared)
    }

    private func featureCard(
        icon: String,
        title: String,
        caption: String,
        gradient: [Color]
    ) -> some View {
        HStack(spacing: TippySpacing.base) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.tippyPrimary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.bold))
                    .foregroundStyle(.tippyText)
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(.tippyTextSecondary)
            }

            Spacer()
        }
        .padding(TippySpacing.base)
        .background(
            LinearGradient(
                colors: gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .tippyCard()
    }

    // MARK: - Pricing Section

    private var pricingSection: some View {
        HStack(spacing: TippySpacing.md) {
            pricingCard(
                plan: .monthly,
                label: "Monthly",
                price: monthlyPrice,
                period: "/ month",
                badge: nil,
                isRecommended: false
            )

            pricingCard(
                plan: .annual,
                label: "Annual",
                price: annualPrice,
                period: "/ year",
                badge: "BEST VALUE",
                isRecommended: true
            )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .animation(.easeOut(duration: 0.5).delay(0.30), value: appeared)
    }

    private func pricingCard(
        plan: Plan,
        label: String,
        price: String,
        period: String,
        badge: String?,
        isRecommended: Bool
    ) -> some View {
        let isSelected = selectedPlan == plan

        return Button {
            guard hasProducts else { return }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                selectedPlan = plan
            }
        } label: {
            VStack(spacing: TippySpacing.sm) {
                if let badge {
                    Text(badge)
                        .font(.tippyLabel)
                        .foregroundStyle(.white)
                        .padding(.horizontal, TippySpacing.sm)
                        .padding(.vertical, TippySpacing.xs)
                        .background(Capsule().fill(Color.tippyGreen))
                } else {
                    // Spacer to keep cards aligned
                    Color.clear
                        .frame(height: TippySpacing.lg)
                }

                Text(label)
                    .font(.tippyLabel)
                    .foregroundStyle(.tippyTextTertiary)
                    .textCase(.uppercase)

                Text(price)
                    .font(.tippyMoney)
                    .foregroundStyle(.tippyText)

                Text(period)
                    .font(.caption)
                    .foregroundStyle(.tippyTextSecondary)

                if isRecommended {
                    Text("Save \(savingsPercent)%")
                        .font(.tippyLabel)
                        .foregroundStyle(.tippyGreen)
                        .padding(.horizontal, TippySpacing.sm)
                        .padding(.vertical, TippySpacing.xs)
                        .background(
                            Capsule().fill(Color.tippyGreenLight)
                        )
                }
            }
            .padding(TippySpacing.base)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: isRecommended
                        ? [Color.tippyGreen.opacity(0.06), Color.tippySky.opacity(0.04)]
                        : [Color.tippySurface.opacity(0.5), Color.tippySurfaceSecondary.opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: TippyRadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: TippyRadius.card, style: .continuous)
                    .stroke(
                        isSelected
                            ? (isRecommended ? Color.tippyGreen : Color.tippyPrimary)
                            : Color.tippyBorder,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? Color.tippyInk.opacity(0.12) : Color.tippyInk.opacity(0.06),
                radius: isSelected ? 12 : 6,
                y: isSelected ? 4 : 2
            )
            .scaleEffect(isSelected ? 1.0 : 0.97)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: selectedPlan)
    }

    // MARK: - Continue Button

    private var continueButton: some View {
        Button {
            Task {
                let product: Product? = selectedPlan == .annual ? annualProduct : monthlyProduct
                if let product { await manager.purchase(product) }
            }
        } label: {
            HStack(spacing: TippySpacing.sm) {
                Text("Continue")
                Image(systemName: "arrow.right")
                    .font(.subheadline.weight(.semibold))
            }
            .tippyPrimaryButton(enabled: hasProducts)
        }
        .buttonStyle(.plain)
        .disabled(!hasProducts)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.30), value: appeared)
    }

    // MARK: - Restore

    private var restoreLink: some View {
        Button {
            Task { await manager.restorePurchases() }
        } label: {
            Text("Restore Purchases")
                .font(.caption)
                .foregroundStyle(.tippyTextTertiary)
        }
    }
}

// MARK: - Pulse Animation Modifier

private struct PulseModifier: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.03 : 1.0)
            .animation(
                .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
    }
}

#Preview {
    UpgradeView()
}
