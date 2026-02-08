import SwiftUI
import StoreKit

struct UpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var manager = SubscriptionManager()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: TippySpacing.xxl) {
                    // Header
                    VStack(spacing: TippySpacing.md) {
                        Text("PRO PLAN")
                            .font(.tippyMono)
                            .foregroundStyle(.tippyTextTertiary)
                            .tracking(1.0)

                        Image(systemName: "sparkles")
                            .font(.system(size: TippySpacing.xxl + TippySpacing.xs))
                            .foregroundStyle(.tippyPrimary)

                        Text("Tippy Pro")
                            .font(.tippyTitle)
                            .foregroundStyle(.tippyText)

                        Text("Unlimited AI-powered tip recommendations")
                            .font(.subheadline)
                            .foregroundStyle(.tippyTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, TippySpacing.xl)

                    // Benefits
                    VStack(alignment: .leading, spacing: TippySpacing.base) {
                        benefitRow(icon: "brain", text: "Unlimited AI tip calculations")
                        benefitRow(icon: "location", text: "Location-aware recommendations")
                        benefitRow(icon: "bolt", text: "Priority response times")
                        benefitRow(icon: "heart", text: "Support independent development")
                    }
                    .padding(TippySpacing.lg)
                    .tippyCard()

                    // Purchase buttons
                    VStack(spacing: TippySpacing.md) {
                        if manager.products.isEmpty {
                            // Fallback display when StoreKit products unavailable
                            fallbackButton(name: "Monthly", price: "$2.99 / month")
                            fallbackButton(name: "Annual", price: "$19.99 / year")
                        } else {
                            ForEach(manager.products, id: \.id) { product in
                                Button {
                                    Task { await manager.purchase(product) }
                                } label: {
                                    VStack(spacing: TippySpacing.xs) {
                                        Text(product.displayName)
                                            .font(.body.weight(.semibold))
                                        Text(product.displayPrice)
                                            .font(.system(size: 22, weight: .bold, design: .rounded))
                                    }
                                    .tippyPrimaryButton()
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Restore
                    Button {
                        Task { await manager.restorePurchases() }
                    } label: {
                        Text("Restore Purchases")
                            .font(.subheadline)
                            .foregroundStyle(.tippyTextSecondary)
                    }
                }
                .padding(.horizontal, TippySpacing.xl)
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
        }
    }

    @ViewBuilder
    private func fallbackButton(name: String, price: String) -> some View {
        VStack(spacing: TippySpacing.xs) {
            Text(name)
                .font(.body.weight(.semibold))
            Text(price)
                .font(.system(size: 22, weight: .bold, design: .rounded))
        }
        .tippyPrimaryButton()
    }

    @ViewBuilder
    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: TippySpacing.md) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.tippyPrimary)
                .frame(width: TippySpacing.xl + TippySpacing.sm)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.tippyText)
        }
    }
}
