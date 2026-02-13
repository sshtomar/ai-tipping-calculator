import SwiftUI

struct ResultView: View {
    @Bindable var state: TipState
    var usageLimiter: UsageLimiter?
    @State private var stage = 0
    @State private var showUpgrade = false
    @State private var showCopied = false
    @State private var shakeTrigger = 0
    @State private var displayedDollars = 0
    @State private var countUpTimer: Timer?
    @State private var hasEngaged = false
    @State private var heroPop: CGFloat = 1

    var body: some View {
        ScrollView {
            VStack(spacing: TippySpacing.xl) {
                // Back button
                HStack {
                    Button {
                        withAnimation(TippySpring.gentle) {
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
                        withAnimation(TippySpring.gentle) {
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
                    .buttonStyle(TippyPressableStyle())

                    if let result = state.result, !result.isRange {
                        Button {
                            withAnimation(TippySpring.gentle) {
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
                .opacity(stage >= 4 ? 1 : 0)
                .offset(y: stage >= 4 ? 0 : 10)
                .animation(.easeOut(duration: TippyTiming.navigate), value: stage)
            }
            .padding(.horizontal, TippySpacing.xl)
            .padding(.top, TippySpacing.lg)
            .padding(.bottom, 100)
        }
        .onAppear {
            advanceStages()
        }
        .onDisappear {
            countUpTimer?.invalidate()
            countUpTimer = nil
        }
        .onChange(of: state.selectedOption) { _, _ in
            withAnimation(TippySpring.snappy) {
                displayedDollars = state.currentTipDollars
            }
            // Hero card pop
            withAnimation(TippySpring.pop) {
                heroPop = 1.04
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(TippySpring.settle) {
                    heroPop = 1
                }
            }
        }
    }

    private var heroGradientColors: [Color] {
        switch state.selectedOption {
        case .lower:
            return [.tippyYellow.opacity(0.18), .tippyRose.opacity(0.14)]
        case .recommended:
            return [.tippyYellow.opacity(0.18), .tippySky.opacity(0.12)]
        case .higher:
            return [.tippyGreen.opacity(0.14), .tippySky.opacity(0.16)]
        }
    }

    // MARK: - Staged Entrance

    private func advanceStages() {
        // Stage 1: hero card (immediate)
        withAnimation(TippySpring.pop) {
            stage = 1
        }
        startCountUp(to: state.currentTipDollars)
        // Stage 2: tip tabs (150ms)
        DispatchQueue.main.asyncAfter(deadline: .now() + TippyTiming.instant) {
            withAnimation(TippySpring.snappy) { stage = 2 }
        }
        // Stage 3: explanation (300ms)
        DispatchQueue.main.asyncAfter(deadline: .now() + TippyTiming.entrance) {
            withAnimation(TippySpring.settle) { stage = 3 }
        }
        // Stage 4: total + actions (400ms)
        DispatchQueue.main.asyncAfter(deadline: .now() + TippyTiming.entrance + 0.1) {
            withAnimation(.easeOut(duration: TippyTiming.navigate)) { stage = 4 }
        }
        // Deferred feedback: auto-show after 5s
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            if !hasEngaged {
                withAnimation(TippySpring.gentle) {
                    hasEngaged = true
                }
            }
        }
    }

    private func startCountUp(to target: Int) {
        countUpTimer?.invalidate()
        guard target > 0 else {
            displayedDollars = 0
            return
        }
        displayedDollars = 0
        let steps = min(target, 20)
        let interval = 0.4 / Double(steps)
        var current = 0
        countUpTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            current += 1
            let progress = Double(current) / Double(steps)
            withAnimation(.easeOut(duration: interval)) {
                displayedDollars = Int(Double(target) * progress)
            }
            if current >= steps {
                timer.invalidate()
                countUpTimer = nil
                withAnimation(.easeOut(duration: interval)) {
                    displayedDollars = target
                }
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
        .scaleEffect(stage >= 1 ? 1 : TippyScale.cardEntrance)
        .opacity(stage >= 1 ? 1 : 0)
    }

    // MARK: - Full Result

    @ViewBuilder
    private func badges(_ result: TipResult) -> some View {
        if let limiter = usageLimiter, limiter.showUpgradePrompt && result.isOffline {
            upgradeBanner()
        }
    }

    @ViewBuilder
    private func upgradeBanner() -> some View {
        VStack(spacing: TippySpacing.md) {
            Text("You've used your free AI tip for today")
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

            Text("$\(displayedDollars)")
                .font(.tippyHero)
                .foregroundStyle(.tippyText)
                .contentTransition(.numericText())
                .blur(radius: state.isDiscreet ? 16 : 0)
                .animation(.easeInOut(duration: TippyTiming.navigate), value: state.isDiscreet)

            Text("\(state.currentTipPercent)%")
                .font(.tippyMoney)
                .foregroundStyle(.tippyTextSecondary)
                .blur(radius: state.isDiscreet ? 8 : 0)
                .animation(.easeInOut(duration: TippyTiming.navigate), value: state.isDiscreet)

            Text("on $\(Int(result.billAmount))")
                .font(.system(size: 15, weight: .regular, design: .serif))
                .foregroundStyle(.tippyTextTertiary)
                .blur(radius: state.isDiscreet ? 8 : 0)
                .animation(.easeInOut(duration: TippyTiming.navigate), value: state.isDiscreet)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, TippySpacing.lg)
        .background(
            LinearGradient(
                colors: heroGradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: TippyRadius.panel, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TippyRadius.panel, style: .continuous)
                .stroke(Color.tippyBorder, lineWidth: 1)
        )
        .animation(TippySpring.gentle, value: state.selectedOption)
        .scaleEffect(stage >= 1 ? heroPop : TippyScale.popIn)
        .opacity(stage >= 1 ? 1 : 0)

        // Tip option picker
        HStack(spacing: 0) {
            let labels = (state.serviceType ?? .other).tipLabels
            tipTab(labels.lower, option: .lower, dollars: result.lowerDollars, percent: result.lowerPercent)
            tipTab(labels.recommended, option: .recommended, dollars: result.recommendedDollars, percent: result.recommendedPercent)
            tipTab(labels.higher, option: .higher, dollars: result.higherDollars, percent: result.higherPercent)
        }
        .padding(TippySpacing.xs)
        .background(Color.tippySurfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: TippyRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TippyRadius.card, style: .continuous)
                .stroke(Color.tippyBorderLight, lineWidth: 1)
        )
        .opacity(stage >= 2 ? 1 : 0)
        .offset(y: stage >= 2 ? 0 : 8)

        // Explanation
        explanationCard(result.explanation)
            .opacity(stage >= 3 ? 1 : 0)
            .offset(y: stage >= 3 ? 0 : 10)

        // Total with tip
        VStack(spacing: TippySpacing.base) {
            if state.splitCount > 1 {
                // Per-person primary
                VStack(spacing: TippySpacing.xs) {
                    moneyText(state.perPersonAmount)
                        .blur(radius: state.isDiscreet ? 12 : 0)
                        .animation(.easeInOut(duration: TippyTiming.navigate), value: state.isDiscreet)
                    Text("per person")
                        .font(.subheadline)
                        .foregroundStyle(.tippyTextTertiary)
                }
                .frame(maxWidth: .infinity)
                .transition(.move(edge: .top).combined(with: .opacity))

                Divider()

                // Total secondary
                HStack(alignment: .firstTextBaseline) {
                    Text("Total with tip")
                        .font(.caption)
                        .foregroundStyle(.tippyTextTertiary)
                    Spacer()
                    Text("$\(String(format: "%.2f", state.currentTotal))")
                        .font(.system(size: 16, weight: .semibold, design: .serif))
                        .foregroundStyle(.tippyTextSecondary)
                        .blur(radius: state.isDiscreet ? 12 : 0)
                        .animation(.easeInOut(duration: TippyTiming.navigate), value: state.isDiscreet)
                }
            } else {
                HStack(alignment: .firstTextBaseline) {
                    Text("Total with tip")
                        .font(.subheadline)
                        .foregroundStyle(.tippyTextSecondary)
                    Spacer()
                    moneyText(state.currentTotal)
                        .blur(radius: state.isDiscreet ? 12 : 0)
                        .animation(.easeInOut(duration: TippyTiming.navigate), value: state.isDiscreet)
                }
            }

            Divider()

            // Split stepper
            HStack {
                Text("Split")
                    .font(.subheadline)
                    .foregroundStyle(.tippyTextSecondary)
                Spacer()
                HStack(spacing: TippySpacing.xs) {
                    stepperButton("minus") {
                        if state.splitCount > 1 {
                            state.splitCount -= 1
                        } else {
                            withAnimation(TippySpring.snappy) { shakeTrigger += 1 }
                        }
                    }
                    Text("\(state.splitCount)")
                        .font(.body.weight(.semibold).monospacedDigit())
                        .frame(minWidth: TippySpacing.xxl)
                        .shake(trigger: shakeTrigger)
                    stepperButton("plus") {
                        if state.splitCount < 20 {
                            state.splitCount += 1
                        } else {
                            withAnimation(TippySpring.snappy) { shakeTrigger += 1 }
                        }
                    }
                }
            }
        }
        .padding(TippySpacing.base)
        .tippyCard()
        .animation(TippySpring.snappy, value: state.splitCount)
        .opacity(stage >= 4 ? 1 : 0)
        .offset(y: stage >= 4 ? 0 : 10)

        // Quick actions row
        HStack(spacing: TippySpacing.sm) {
            quickAction(
                icon: showCopied ? "checkmark.circle.fill" : "doc.on.doc",
                label: showCopied ? "Copied!" : "Copy"
            ) {
                UIPasteboard.general.string = "$\(state.currentTipDollars)"
                withAnimation(TippySpring.snappy) {
                    showCopied = true
                    hasEngaged = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(TippySpring.snappy) {
                        showCopied = false
                    }
                }
            }
            quickAction(
                icon: state.isDiscreet ? "eye.slash" : "eye",
                label: "Discreet"
            ) {
                withAnimation(TippySpring.snappy) {
                    state.isDiscreet.toggle()
                }
            }
            quickAction(icon: "square.and.arrow.up", label: "Share") {
                withAnimation(TippySpring.snappy) {
                    hasEngaged = true
                }
                shareResult()
            }
        }
        .opacity(stage >= 4 ? 1 : 0)

        // Feedback (deferred until user engages or 5s timeout)
        if hasEngaged {
            feedbackSection()
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: - Components

    @ViewBuilder
    private func tipTab(_ label: String, option: TipOption, dollars: Int, percent: Int) -> some View {
        let isSelected = state.selectedOption == option
        Button {
            withAnimation(TippySpring.snappy) {
                state.selectedOption = option
            }
        } label: {
            VStack(spacing: 2) {
                Text("$\(dollars)")
                    .font(.tippyMoney)
                    .foregroundStyle(isSelected ? .tippyText : .tippyTextSecondary)
                    .blur(radius: state.isDiscreet ? 8 : 0)
                    .animation(.easeInOut(duration: TippyTiming.navigate), value: state.isDiscreet)
                Text(label)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(isSelected ? .tippyPrimary : .tippyTextTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, TippySpacing.md)
            .background(isSelected ? Color.tippySurface : .clear)
            .clipShape(RoundedRectangle(cornerRadius: TippyRadius.chip, style: .continuous))
            .overlay(alignment: .bottom) {
                if isSelected {
                    Capsule()
                        .fill(Color.tippyPrimary)
                        .frame(width: 24, height: 3)
                        .offset(y: -4)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .buttonStyle(TippyPressableStyle())
        .sensoryFeedback(.selection, trigger: isSelected)
    }

    @ViewBuilder
    private func explanationCard(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 0) {
            RoundedRectangle(cornerRadius: TippyRadius.accent)
                .fill(Color.tippyPrimary)
                .frame(width: 3)
                .padding(.vertical, TippySpacing.xs)

            VStack(alignment: .leading, spacing: TippySpacing.xs) {
                Text("\u{201C}")
                    .font(.system(size: 28, design: .serif))
                    .foregroundStyle(.tippyPrimary.opacity(0.4))

                Text(text)
                    .font(.body)
                    .foregroundStyle(.tippyTextSecondary)
                    .lineSpacing(5)
            }
            .padding(.leading, TippySpacing.base)
            .padding(.vertical, 2)
        }
        .padding(TippySpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.tippySurfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: TippyRadius.card, style: .continuous))
        .blur(radius: state.isDiscreet ? 8 : 0)
        .animation(.easeInOut(duration: TippyTiming.navigate), value: state.isDiscreet)
    }

    @ViewBuilder
    private func quickAction(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: TippySpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .contentTransition(.symbolEffect(.replace))
                Text(label)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(label == "Copied!" ? .tippyGreen : .tippyTextSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, TippySpacing.md)
            .tippyCard()
        }
        .buttonStyle(TippyPressableStyle())
        .sensoryFeedback(.impact(flexibility: .soft), trigger: state.isDiscreet)
    }

    @ViewBuilder
    private func moneyText(_ amount: Double) -> some View {
        let formatted = String(format: "%.2f", amount)
        let parts = formatted.split(separator: ".")
        let dollars = String(parts[0])
        let cents = parts.count > 1 ? ".\(parts[1])" : ""
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text("$\(dollars)")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .monospacedDigit()
                .foregroundStyle(.tippyText)
            Text(cents)
                .font(.system(size: 20, weight: .regular, design: .serif))
                .monospacedDigit()
                .foregroundStyle(.tippyTextTertiary)
        }
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
        .buttonStyle(TippyPressableStyle())
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
            withAnimation(TippySpring.snappy) {
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
        .buttonStyle(TippyPressableStyle())
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
        explanation: "Date night \u{2014} you want the tip to be invisible. $28 on a $142 bill is generous without making a thing of it.",
        totalWithTip: 170,
        billAmount: 142
    )
    return ResultView(state: state)
}
