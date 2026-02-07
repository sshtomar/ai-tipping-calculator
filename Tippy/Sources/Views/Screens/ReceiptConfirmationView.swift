import SwiftUI

struct ReceiptConfirmationView: View {
    @Bindable var state: TipState

    var body: some View {
        VStack(spacing: TippySpacing.xl) {
            // Back button
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        state.pendingScanResult = nil
                        state.currentScreen = .entry
                    }
                } label: {
                    HStack(spacing: TippySpacing.xs) {
                        Image(systemName: "chevron.left")
                            .font(.subheadline.weight(.semibold))
                        Text("Back")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.tippyTextSecondary)
                }
                Spacer()
            }

            VStack(spacing: TippySpacing.sm) {
                Text("RECEIPT SCAN")
                    .font(.tippyMono)
                    .foregroundStyle(.tippyTextTertiary)
                    .tracking(1.0)

                Text("Confirm the amount")
                    .font(.tippyTitle)
                    .foregroundStyle(.tippyText)

                Text("We found a few numbers on your receipt. Which one is the total?")
                    .font(.subheadline)
                    .foregroundStyle(.tippyTextSecondary)
                    .multilineTextAlignment(.center)
            }

            if let scanResult = state.pendingScanResult {
                // Primary amount
                VStack(spacing: TippySpacing.sm) {
                    Text("BEST MATCH")
                        .font(.tippyLabel)
                        .foregroundStyle(.tippyPrimary)
                        .tracking(1.2)

                    Text("$\(scanResult.amount, specifier: "%.2f")")
                        .font(.tippyHero)
                        .foregroundStyle(.tippyText)
                }
                .padding(.vertical, TippySpacing.sm)

                // Alternatives
                if scanResult.allAmounts.count > 1 {
                    VStack(alignment: .leading, spacing: TippySpacing.md) {
                        Text("OTHER AMOUNTS")
                            .font(.tippyLabel)
                            .foregroundStyle(.tippyTextSecondary)
                            .tracking(1.0)

                        FlowLayout(spacing: TippySpacing.sm) {
                            ForEach(scanResult.allAmounts.dropFirst(), id: \.self) { amount in
                                Button {
                                    selectAmount(amount, from: scanResult)
                                } label: {
                                    Text("$\(amount, specifier: "%.2f")")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.tippyText)
                                        .padding(.horizontal, TippySpacing.base)
                                        .padding(.vertical, TippySpacing.sm)
                                        .overlay(Capsule().stroke(Color.tippyBorder, lineWidth: 1))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                Spacer()

                Button {
                    selectAmount(scanResult.amount, from: scanResult)
                } label: {
                    HStack {
                        Text("Use this amount")
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.body.weight(.medium))
                    }
                    .tippyPrimaryButton()
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, TippySpacing.xl)
        .padding(.top, TippySpacing.base)
        .padding(.bottom, TippySpacing.xl)
    }

    private func selectAmount(_ amount: Double, from scanResult: ReceiptScanner.ScanResult) {
        let formatted = amount.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", amount)
            : String(format: "%.2f", amount)
        state.amount = formatted

        if state.serviceType == nil {
            state.serviceType = scanResult.detectedServiceType ?? .restaurant
        }

        if let guests = scanResult.numberOfGuests, guests >= 6 {
            state.contextTags.insert(.largeGroup)
        }

        state.pendingScanResult = nil
        withAnimation(.easeInOut(duration: 0.25)) {
            state.currentScreen = .entry
        }
    }
}
