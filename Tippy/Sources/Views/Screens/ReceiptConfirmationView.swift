import SwiftUI

struct ReceiptConfirmationView: View {
    @Bindable var state: TipState

    var body: some View {
        VStack(spacing: 24) {
            // Back button
            HStack {
                Button {
                    withAnimation {
                        state.pendingScanResult = nil
                        state.currentScreen = .entry
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.subheadline.weight(.semibold))
                        Text("Back")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.tippyTextSecondary)
                }
                Spacer()
            }

            VStack(spacing: 8) {
                Text("Confirm the amount")
                    .font(.custom("Georgia", size: 28, relativeTo: .title))
                    .foregroundStyle(.tippyText)

                Text("We found a few numbers on your receipt. Which one is the total?")
                    .font(.subheadline)
                    .foregroundStyle(.tippyTextSecondary)
                    .multilineTextAlignment(.center)
            }

            if let scanResult = state.pendingScanResult {
                // Primary detected amount
                VStack(spacing: 6) {
                    Text("Best match")
                        .font(.caption2.bold())
                        .foregroundStyle(.tippyPrimaryDark)
                        .textCase(.uppercase)
                        .tracking(0.6)

                    Text("$\(scanResult.amount, specifier: "%.2f")")
                        .font(.custom("Georgia", size: 42, relativeTo: .largeTitle))
                        .foregroundStyle(.tippyText)
                }
                .padding(.vertical, 8)

                // Alternative amounts
                if scanResult.allAmounts.count > 1 {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("OTHER AMOUNTS FOUND")
                            .font(.tippyLabel)
                            .foregroundStyle(.tippyTextSecondary)
                            .tracking(0.8)

                        FlowLayout(spacing: 8) {
                            ForEach(scanResult.allAmounts.dropFirst(), id: \.self) { amount in
                                Button {
                                    selectAmount(amount, from: scanResult)
                                } label: {
                                    Text("$\(amount, specifier: "%.2f")")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.tippyText)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(Color.tippySurface)
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule().stroke(Color.tippyBorder, lineWidth: 1.5)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                Spacer()

                // Use this amount
                Button {
                    selectAmount(scanResult.amount, from: scanResult)
                } label: {
                    Text("Use this amount")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.tippyPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 20)
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
        withAnimation {
            state.currentScreen = .entry
        }
    }
}
