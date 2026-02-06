import SwiftUI

struct ResultView: View {
    @Bindable var state: TipState
    @State private var appeared = false

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
                        .font(.system(size: 15))
                        .foregroundStyle(.tippyTextSecondary)
                        .padding(.vertical, 12)
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
        VStack(spacing: 16) {
            Text("Recommended")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.tippyPrimaryDark)
                .textCase(.uppercase)
                .tracking(0.6)

            Text(result.rangeText ?? "")
                .font(.custom("Georgia", size: 38))
                .foregroundStyle(.tippyText)

            Text(result.explanation)
                .font(.system(size: 16))
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
    private func fullResult(_ result: TipResult) -> some View {
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
            .font(.system(size: 16))
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
                .font(.system(size: 15))
                .foregroundStyle(.tippyTextSecondary)
            Spacer()
            Text("$\(state.currentTotal, specifier: "%.2f")")
                .font(.custom("Georgia", size: 22))
                .foregroundStyle(.tippyText)
                .blur(radius: state.isDiscreet ? 12 : 0)
        }
        .padding(16)
        .tippyCard()

        // Split
        VStack(spacing: 0) {
            HStack {
                Text("Split the bill")
                    .font(.system(size: 15))
                    .foregroundStyle(.tippyTextSecondary)
                Spacer()
                HStack(spacing: 4) {
                    stepperButton("minus") {
                        if state.splitCount > 1 { state.splitCount -= 1 }
                    }
                    Text("\(state.splitCount)")
                        .font(.system(size: 18, weight: .semibold))
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
                        .font(.custom("Georgia", size: 24))
                        .foregroundStyle(.tippyText)
                        .blur(radius: state.isDiscreet ? 12 : 0)
                    Text("per person")
                        .font(.system(size: 14))
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
            actionButton(icon: "doc.on.doc", label: "Copy amount") {
                UIPasteboard.general.string = "\(state.currentTipDollars)"
            }
            actionButton(
                icon: state.isDiscreet ? "eye.slash" : "eye",
                label: "Discreet mode"
            ) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    state.isDiscreet.toggle()
                }
            }
        }

        // Feedback
        VStack(spacing: 12) {
            Text("How'd we do?")
                .font(.system(size: 13))
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
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.5)
                    .foregroundStyle(isSelected && isPrimary ? .tippyPrimaryDark : .tippyTextTertiary)
                    .padding(.top, 4)

                Text("$\(dollars)")
                    .font(.custom("Georgia", size: isPrimary ? 36 : 24))
                    .foregroundStyle(.tippyText)
                    .blur(radius: state.isDiscreet ? 12 : 0)

                Text("\(percent)%")
                    .font(.system(size: isPrimary ? 16 : 14, weight: isPrimary ? .medium : .regular))
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
                .font(.system(size: 14, weight: .medium))
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
                    .font(.system(size: 15))
                Text(label)
                    .font(.system(size: 14))
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
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
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
