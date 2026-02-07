import SwiftUI

struct ResultView: View {
    @Bindable var state: TipState
    var usageLimiter: UsageLimiter?
    @State private var appeared = false
    @State private var showUpgrade = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let result = state.result {
                    if result.isRange {
                        rangeResult(result)
                    } else {
                        fullResult(result)
                    }
                }

                // Start over
                Button {
                    withAnimation {
                        state.reset()
                    }
                } label: {
                    Text("← Start over")
                        .font(.subheadline)
                        .foregroundStyle(.tippyTextSecondary)
                        .padding(.vertical, 12)
                }
                
                // Edit amount button
                if let result = state.result, !result.isRange {
                    Button {
                        withAnimation {
                            state.currentScreen = .entry
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "pencil")
                                .font(.caption)
                            Text("Edit amount or context")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.tippyTextTertiary)
                        .padding(.vertical, 8)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 80)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }

    // MARK: - Range Result (No-Bill)

    @ViewBuilder
    private func rangeResult(_ result: TipResult) -> some View {
        if result.isOffline {
            offlineBadge()
        }

        if let limiter = usageLimiter, limiter.showUpgradePrompt && result.isOffline {
            upgradeBanner()
        }

        VStack(spacing: 16) {
            Text("Recommended")
                .font(.caption2.bold())
                .foregroundStyle(.tippyPrimaryDark)
                .textCase(.uppercase)
                .tracking(0.6)

            Text(result.rangeText ?? "")
                .font(.custom("Georgia", size: 38, relativeTo: .largeTitle))
                .foregroundStyle(.tippyText)

            Text(result.explanation)
                .font(.callout)
                .foregroundStyle(.tippyTextSecondary)
                .lineSpacing(4)
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.tippySurfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .scaleEffect(appeared ? 1 : 0.9)
        .opacity(appeared ? 1 : 0)
    }

    // MARK: - Full Result

    @ViewBuilder
    private func offlineBadge() -> some View {
        HStack(spacing: 6) {
            Image(systemName: "wifi.slash")
                .font(.caption2)
            Text("Offline estimate")
                .font(.caption2.weight(.medium))
        }
        .foregroundStyle(.tippyTextTertiary)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.tippySurfaceSecondary)
        .clipShape(Capsule())
    }

    @ViewBuilder
    private func upgradeBanner() -> some View {
        VStack(spacing: 10) {
            Text("You've used your 3 free AI tips today")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.tippyText)
            Button {
                showUpgrade = true
            } label: {
                Text("Upgrade to Tippy Pro")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.tippyYellow)
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.tippyYellow.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.tippyYellow.opacity(0.3), lineWidth: 1.5)
        )
        .sheet(isPresented: $showUpgrade) {
            UpgradeView()
        }
    }

    @ViewBuilder
    private func autoGratuityBanner() -> some View {
        if let gratuity = state.autoGratuityAmount {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.subheadline)
                    .foregroundStyle(.tippyYellow)
                Text("Auto-gratuity of $\(gratuity, specifier: "%.2f") already included")
                    .font(.subheadline)
                    .foregroundStyle(.tippyText)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.tippyYellow.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.tippyYellow.opacity(0.3), lineWidth: 1.5)
            )
        }
    }

    @ViewBuilder
    private func fullResult(_ result: TipResult) -> some View {
        if result.isOffline {
            offlineBadge()
        }

        if let limiter = usageLimiter, limiter.showUpgradePrompt && result.isOffline {
            upgradeBanner()
        }

        autoGratuityBanner()

        // Three options
        HStack(spacing: 10) {
            tipOption(
                label: "Acceptable",
                dollars: result.lowerDollars,
                percent: result.lowerPercent,
                isSelected: state.selectedOption == .lower,
                isPrimary: false
            ) {
                state.selectedOption = .lower
            }

            tipOption(
                label: "Recommended",
                dollars: result.recommendedDollars,
                percent: result.recommendedPercent,
                isSelected: state.selectedOption == .recommended,
                isPrimary: true
            ) {
                state.selectedOption = .recommended
            }

            tipOption(
                label: "Generous",
                dollars: result.higherDollars,
                percent: result.higherPercent,
                isSelected: state.selectedOption == .higher,
                isPrimary: false
            ) {
                state.selectedOption = .higher
            }
        }
        .scaleEffect(appeared ? 1 : 0.9)
        .opacity(appeared ? 1 : 0)

        // Explanation
        Text(result.explanation)
            .font(.callout)
            .foregroundStyle(.tippyTextSecondary)
            .lineSpacing(4)
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.tippySurfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .blur(radius: state.isDiscreet ? 8 : 0)

        // Total with tip
        HStack {
            Text("Total with tip")
                .font(.subheadline)
                .foregroundStyle(.tippyTextSecondary)
            Spacer()
            Text("$\(state.currentTotal, specifier: "%.2f")")
                .font(.custom("Georgia", size: 22, relativeTo: .title2))
                .foregroundStyle(.tippyText)
                .blur(radius: state.isDiscreet ? 12 : 0)
        }
        .padding(16)
        .tippyCard()

        // Split
        VStack(spacing: 0) {
            HStack {
                Text("Split the bill")
                    .font(.subheadline)
                    .foregroundStyle(.tippyTextSecondary)
                Spacer()
                HStack(spacing: 4) {
                    stepperButton("minus") {
                        if state.splitCount > 1 { state.splitCount -= 1 }
                    }
                    Text("\(state.splitCount)")
                        .font(.body.weight(.semibold))
                        .frame(minWidth: 32)
                    stepperButton("plus") {
                        if state.splitCount < 20 { state.splitCount += 1 }
                    }
                }
            }

            if state.splitCount > 1 {
                Divider()
                    .padding(.vertical, 12)

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("$\(state.perPersonAmount, specifier: "%.2f")")
                        .font(.custom("Georgia", size: 24, relativeTo: .title2))
                        .foregroundStyle(.tippyText)
                        .blur(radius: state.isDiscreet ? 12 : 0)
                    Text("per person")
                        .font(.subheadline)
                        .foregroundStyle(.tippyTextTertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(16)
        .tippyCard()
        .animation(.easeInOut(duration: 0.2), value: state.splitCount)

        // Actions
        HStack(spacing: 10) {
            actionButton(icon: "doc.on.doc", label: "Copy") {
                UIPasteboard.general.string = "$\(state.currentTipDollars)"
            }
            actionButton(
                icon: state.isDiscreet ? "eye.slash" : "eye",
                label: "Discreet"
            ) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    state.isDiscreet.toggle()
                }
            }
            actionButton(icon: "square.and.arrow.up", label: "Share") {
                shareResult()
            }
        }

        // Feedback
        VStack(spacing: 12) {
            Text("How'd we do?")
                .font(.footnote)
                .foregroundStyle(.tippyTextTertiary)

            HStack(spacing: 10) {
                feedbackButton("Too low", value: "too_low")
                feedbackButton("Just right", value: "just_right")
                feedbackButton("Too high", value: "too_high")
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func tipOption(
        label: String,
        dollars: Int,
        percent: Int,
        isSelected: Bool,
        isPrimary: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.15)) { action() }
        }) {
            VStack(spacing: 6) {
                Text(label.uppercased())
                    .font(.caption2.bold())
                    .tracking(0.5)
                    .foregroundStyle(isSelected && isPrimary ? .tippyPrimaryDark : .tippyTextTertiary)
                    .padding(.top, 4)

                Text("$\(dollars)")
                    .font(isPrimary
                        ? .custom("Georgia", size: 36, relativeTo: .largeTitle)
                        : .custom("Georgia", size: 24, relativeTo: .title2)
                    )
                    .foregroundStyle(.tippyText)
                    .blur(radius: state.isDiscreet ? 12 : 0)

                Text("\(percent)%")
                    .font(isPrimary ? .callout.weight(.medium) : .subheadline)
                    .foregroundStyle(.tippyTextSecondary)
                    .blur(radius: state.isDiscreet ? 8 : 0)
                    .padding(.bottom, 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, isPrimary ? 16 : 12)
            .background(isSelected ? Color.tippyPrimaryLight : Color.tippySurface)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? Color.tippyPrimary : Color.tippyBorder, lineWidth: isSelected ? 2 : 1.5)
            )
            .shadow(color: isSelected ? .tippyPrimary.opacity(0.15) : .clear, radius: 8, y: 2)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }

    @ViewBuilder
    private func stepperButton(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.subheadline.weight(.medium))
                .frame(width: 36, height: 36)
                .background(Color.tippyBackground)
                .foregroundStyle(.tippyText)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.tippyBorder, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: state.splitCount)
    }

    @ViewBuilder
    private func actionButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.subheadline)
                Text(label)
                    .font(.subheadline)
            }
            .foregroundStyle(.tippyTextSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .tippyCard()
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: state.isDiscreet)
    }

    @ViewBuilder
    private func feedbackButton(_ label: String, value: String) -> some View {
        let isSelected = state.feedbackGiven == value
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                state.feedbackGiven = value
            }
            // Store locally
            saveFeedback(value)
        } label: {
            Text(label)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .tippyGreen : .tippyTextSecondary)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(isSelected ? Color.tippyGreenLight : Color.tippySurface)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(isSelected ? Color.tippyGreen : Color.tippyBorder, lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.success, trigger: isSelected)
    }

    private func saveFeedback(_ value: String) {
        let key = "tippy_feedback"
        var history = UserDefaults.standard.array(forKey: key) as? [[String: String]] ?? []
        history.append([
            "type": value,
            "service": state.serviceType?.rawValue ?? "advice",
            "date": ISO8601DateFormatter().string(from: Date()),
        ])
        UserDefaults.standard.set(history, forKey: key)
    }
    
    private func shareResult() {
        guard let result = state.result else { return }
        let text = """
        Tip: $\(state.currentTipDollars) (\(result.recommendedPercent)%)
        Total: $\(String(format: "%.2f", state.currentTotal))
        
        Calculated with Tippy
        """
        
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            activityVC.popoverPresentationController?.sourceView = rootVC.view
            rootVC.present(activityVC, animated: true)
        }
    }
}

#Preview {
    let state = TipState()
    state.result = TipResult(
        recommendedDollars: 28,
        recommendedPercent: 20,
        lowerDollars: 23,
        lowerPercent: 16,
        higherDollars: 34,
        higherPercent: 24,
        explanation: "Date night — you want the tip to be invisible. $28 on a $142 bill is generous without making a thing of it.",
        totalWithTip: 170,
        billAmount: 142
    )
    return ResultView(state: state)
}
