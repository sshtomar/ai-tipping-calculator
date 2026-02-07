import SwiftUI

struct ResultView: View {
    @Bindable var state: TipState
    var usageLimiter: UsageLimiter?
    @State private var appeared = false
    @State private var showUpgrade = false

    var body: some View {
        ScrollView {
            VStack(spacing: TippySpacing.xl) {
                // Back button
                HStack {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
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

                Text("TIP RESULT")
                    .font(.tippyMono)
                    .foregroundStyle(.tippyTextTertiary)
                    .tracking(1.0)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let result = state.result {
                    if result.isRange {
                        rangeResult(result)
                    } else {
                        fullResult(result)
                    }
                }

                // Actions
                VStack(spacing: TippySpacing.base) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            state.reset()
                        }
                    } label: {
                        HStack(spacing: TippySpacing.sm) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.subheadline.weight(.medium))
                            Text("Start over")
                                .font(.subheadline.weight(.medium))
                        }
                        .tippySecondaryButton()
                    }
                    .buttonStyle(.plain)

                    if let result = state.result, !result.isRange {
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                state.currentScreen = .entry
                            }
                        } label: {
                            HStack(spacing: TippySpacing.sm) {
                                Image(systemName: "pencil")
                                    .font(.caption)
                                Text("Edit amount or context")
                            }
                            .font(.subheadline)
                            .foregroundStyle(.tippyTextTertiary)
                        }
                    }
                }
            }
            .padding(.horizontal, TippySpacing.xl)
            .padding(.top, TippySpacing.lg)
            .padding(.bottom, TippySpacing.xxl)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                appeared = true
            }
        }
    }

    // MARK: - Range Result (No-Bill)

    @ViewBuilder
    private func rangeResult(_ result: TipResult) -> some View {
        badges(result)

        VStack(spacing: TippySpacing.xl) {
            VStack(spacing: TippySpacing.sm) {
                Text("RECOMMENDED")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(.tippyPrimary)

                Text(result.rangeText ?? "")
                    .font(.tippyHero)
                    .foregroundStyle(.tippyText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, TippySpacing.lg)
            .background(
                LinearGradient(
                    colors: [.tippyYellow.opacity(0.18), .tippyRose.opacity(0.25)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: TippyRadius.panel, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: TippyRadius.panel, style: .continuous)
                    .stroke(Color.tippyBorder, lineWidth: 1)
            )

            explanationCard(result.explanation)
        }
        .scaleEffect(appeared ? 1 : 0.95)
        .opacity(appeared ? 1 : 0)
    }

    // MARK: - Full Result

    @ViewBuilder
    private func badges(_ result: TipResult) -> some View {
        if result.isOffline {
            HStack(spacing: TippySpacing.sm) {
                Image(systemName: "wifi.slash")
                    .font(.caption2)
                Text("Offline estimate")
                    .font(.caption2.weight(.medium))
            }
            .foregroundStyle(.tippyTextTertiary)
            .padding(.horizontal, TippySpacing.md)
            .padding(.vertical, TippySpacing.sm)
            .background(Color.tippySurfaceSecondary)
            .clipShape(Capsule())
        }

        if let limiter = usageLimiter, limiter.showUpgradePrompt && result.isOffline {
            upgradeBanner()
        }
    }

    @ViewBuilder
    private func upgradeBanner() -> some View {
        VStack(spacing: TippySpacing.md) {
            Text("You've used your 3 free AI tips today")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.tippyText)
            Button {
                showUpgrade = true
            } label: {
                Text("Upgrade to Pro")
                    .tippyPrimaryButton()
            }
        }
        .padding(TippySpacing.lg)
        .frame(maxWidth: .infinity)
        .background(Color.tippyPrimaryLight)
        .clipShape(RoundedRectangle(cornerRadius: TippyRadius.card, style: .continuous))
        .sheet(isPresented: $showUpgrade) {
            UpgradeView()
        }
    }

    @ViewBuilder
    private func autoGratuityBanner() -> some View {
        if let gratuity = state.autoGratuityAmount {
            HStack(spacing: TippySpacing.sm) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.subheadline)
                    .foregroundStyle(.tippyYellow)
                Text("Auto-gratuity of $\(gratuity, specifier: "%.2f") already included")
                    .font(.subheadline)
                    .foregroundStyle(.tippyText)
            }
            .padding(TippySpacing.base)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.tippyYellow.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: TippyRadius.card, style: .continuous))
        }
    }

    @ViewBuilder
    private func fullResult(_ result: TipResult) -> some View {
        badges(result)
        autoGratuityBanner()

        // Hero tip amount
        VStack(spacing: TippySpacing.xs) {
            Text("YOUR TIP")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundStyle(.tippyPrimary)
                .padding(.bottom, TippySpacing.xs)

            Text("$\(state.currentTipDollars)")
                .font(.tippyHero)
                .foregroundStyle(.tippyText)
                .blur(radius: state.isDiscreet ? 16 : 0)

            Text("\(state.currentTipPercent)%")
                .font(.tippyMoney)
                .foregroundStyle(.tippyTextSecondary)
                .blur(radius: state.isDiscreet ? 8 : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, TippySpacing.lg)
        .background(
            LinearGradient(
                colors: [.tippyYellow.opacity(0.18), .tippySky.opacity(0.12)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: TippyRadius.panel, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TippyRadius.panel, style: .continuous)
                .stroke(Color.tippyBorder, lineWidth: 1)
        )
        .scaleEffect(appeared ? 1 : 0.92)
        .opacity(appeared ? 1 : 0)

        // Tip option picker
        HStack(spacing: 0) {
            tipTab("Acceptable", option: .lower, dollars: result.lowerDollars, percent: result.lowerPercent)
            tipTab("Recommended", option: .recommended, dollars: result.recommendedDollars, percent: result.recommendedPercent)
            tipTab("Generous", option: .higher, dollars: result.higherDollars, percent: result.higherPercent)
        }
        .padding(TippySpacing.xs)
        .background(Color.tippySurfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: TippyRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TippyRadius.card, style: .continuous)
                .stroke(Color.tippyBorderLight, lineWidth: 1)
        )

        // Explanation
        explanationCard(result.explanation)

        // Total with tip
        VStack(spacing: TippySpacing.base) {
            HStack {
                Text("Total with tip")
                    .font(.subheadline)
                    .foregroundStyle(.tippyTextSecondary)
                Spacer()
                Text("$\(state.currentTotal, specifier: "%.2f")")
                    .font(.tippyTitle)
                    .monospacedDigit()
                    .foregroundStyle(.tippyText)
                    .blur(radius: state.isDiscreet ? 12 : 0)
            }

            if state.splitCount > 1 {
                Divider()

                HStack(alignment: .firstTextBaseline, spacing: TippySpacing.sm) {
                    Text("$\(state.perPersonAmount, specifier: "%.2f")")
                        .font(.tippyTitle)
                        .monospacedDigit()
                        .foregroundStyle(.tippyText)
                        .blur(radius: state.isDiscreet ? 12 : 0)
                    Text("per person")
                        .font(.subheadline)
                        .foregroundStyle(.tippyTextTertiary)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            Divider()

            // Split stepper — always visible inside the total card
            HStack {
                Text("Split")
                    .font(.subheadline)
                    .foregroundStyle(.tippyTextSecondary)
                Spacer()
                HStack(spacing: TippySpacing.xs) {
                    stepperButton("minus") {
                        if state.splitCount > 1 { state.splitCount -= 1 }
                    }
                    Text("\(state.splitCount)")
                        .font(.body.weight(.semibold).monospacedDigit())
                        .frame(minWidth: TippySpacing.xxl)
                    stepperButton("plus") {
                        if state.splitCount < 20 { state.splitCount += 1 }
                    }
                }
            }
        }
        .padding(TippySpacing.base)
        .tippyCard()
        .animation(.easeInOut(duration: 0.15), value: state.splitCount)

        // Quick actions row
        HStack(spacing: TippySpacing.sm) {
            quickAction(icon: "doc.on.doc", label: "Copy") {
                UIPasteboard.general.string = "$\(state.currentTipDollars)"
            }
            quickAction(
                icon: state.isDiscreet ? "eye.slash" : "eye",
                label: "Discreet"
            ) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    state.isDiscreet.toggle()
                }
            }
            quickAction(icon: "square.and.arrow.up", label: "Share") {
                shareResult()
            }
        }

        // Feedback
        feedbackSection()
    }

    // MARK: - Components

    @ViewBuilder
    private func tipTab(_ label: String, option: TipOption, dollars: Int, percent: Int) -> some View {
        let isSelected = state.selectedOption == option
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                state.selectedOption = option
            }
        } label: {
            VStack(spacing: 2) {
                Text("$\(dollars)")
                    .font(.tippyMoney)
                    .foregroundStyle(isSelected ? .tippyText : .tippyTextSecondary)
                    .blur(radius: state.isDiscreet ? 8 : 0)
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(isSelected ? .tippyPrimary : .tippyTextTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, TippySpacing.md)
            .background(isSelected ? Color.tippySurface : .clear)
            .clipShape(RoundedRectangle(cornerRadius: TippyRadius.chip, style: .continuous))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }

    @ViewBuilder
    private func explanationCard(_ text: String) -> some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: TippyRadius.accent)
                .fill(Color.tippyPrimary)
                .frame(width: 3)
                .padding(.vertical, TippySpacing.xs)

            Text(text)
                .font(.callout)
                .foregroundStyle(.tippyTextSecondary)
                .lineSpacing(5)
                .padding(.leading, TippySpacing.base)
                .padding(.vertical, 2)
        }
        .padding(TippySpacing.base)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.tippySurfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: TippyRadius.card, style: .continuous))
        .blur(radius: state.isDiscreet ? 8 : 0)
    }

    @ViewBuilder
    private func quickAction(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: TippySpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                Text(label)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(.tippyTextSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, TippySpacing.md)
            .tippyCard()
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: state.isDiscreet)
    }

    @ViewBuilder
    private func stepperButton(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.subheadline.weight(.medium))
                .frame(width: 34, height: 34)
                .background(Color.tippySurfaceSecondary)
                .foregroundStyle(.tippyText)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: state.splitCount)
    }

    @ViewBuilder
    private func feedbackSection() -> some View {
        VStack(spacing: TippySpacing.md) {
            Text("How'd we do?")
                .font(.subheadline)
                .foregroundStyle(.tippyTextTertiary)

            HStack(spacing: TippySpacing.sm) {
                feedbackChip(icon: "arrow.down", label: "Too low", value: "too_low")
                feedbackChip(icon: "checkmark", label: "Just right", value: "just_right")
                feedbackChip(icon: "arrow.up", label: "Too high", value: "too_high")
            }
        }
        .padding(.top, TippySpacing.xs)
    }

    @ViewBuilder
    private func feedbackChip(icon: String, label: String, value: String) -> some View {
        let isSelected = state.feedbackGiven == value
        let isJustRight = value == "just_right"
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                state.feedbackGiven = value
            }
            saveFeedback(value)
        } label: {
            HStack(spacing: 5) {
                Image(systemName: isSelected && isJustRight ? "checkmark.circle.fill" : icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(label)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .medium))
            }
            .foregroundStyle(isSelected ? (isJustRight ? .tippyGreen : .tippyPrimary) : .tippyTextSecondary)
            .padding(.horizontal, TippySpacing.md)
            .padding(.vertical, TippySpacing.sm)
            .background(isSelected ? (isJustRight ? Color.tippyGreenLight : Color.tippyPrimaryLight) : Color.tippySurface)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(
                    isSelected ? (isJustRight ? Color.tippyGreen.opacity(0.3) : Color.tippyPrimary.opacity(0.3)) : Color.tippyBorder.opacity(0.5),
                    lineWidth: 1
                )
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
