import SwiftUI
import StoreKit

struct UpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var manager = SubscriptionManager()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 40))
                            .foregroundStyle(.tippyPrimary)

                        Text("Tippy Pro")
                            .font(.custom("Georgia", size: 32, relativeTo: .largeTitle))
                            .foregroundStyle(.tippyText)

                        Text("Unlimited AI-powered tip recommendations")
                            .font(.subheadline)
                            .foregroundStyle(.tippyTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                    // Benefits
                    VStack(alignment: .leading, spacing: 16) {
                        benefitRow(icon: "brain", text: "Unlimited AI tip calculations")
                        benefitRow(icon: "location", text: "Location-aware recommendations")
                        benefitRow(icon: "bolt", text: "Priority response times")
                        benefitRow(icon: "heart", text: "Support independent development")
                    }
                    .padding(20)
                    .background(Color.tippySurfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    // Purchase buttons
                    VStack(spacing: 12) {
                        ForEach(manager.products, id: \.id) { product in
                            Button {
                                Task { await manager.purchase(product) }
                            } label: {
                                VStack(spacing: 4) {
                                    Text(product.displayName)
                                        .font(.body.weight(.semibold))
                                    Text(product.displayPrice)
                                        .font(.custom("Georgia", size: 22, relativeTo: .title2))
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.tippyPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }

                        if manager.products.isEmpty {
                            Text("Loading plans...")
                                .font(.subheadline)
                                .foregroundStyle(.tippyTextTertiary)
                                .padding(.vertical, 16)
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
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .background(Color.tippyBackground)
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
    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.tippyPrimary)
                .frame(width: 28)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.tippyText)
        }
    }
}
