import SwiftUI

struct NoBillView: View {
    @Bindable var state: TipState
    var locationService: LocationService
    var usageLimiter: UsageLimiter
    @FocusState private var isFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TippySpacing.xl) {
                // Back button
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

                VStack(alignment: .leading, spacing: TippySpacing.sm) {
                    Text("ADVICE MODE")
                        .font(.tippyMono)
                        .foregroundStyle(.tippyTextTertiary)
                        .tracking(1.0)

                    Text("Describe the situation")
                        .font(.tippyTitle)
                        .foregroundStyle(.tippyText)

                    Text("Tell us who you're tipping, how long you've used their service, what they usually charge — whatever feels relevant.")
                        .font(.subheadline)
                        .foregroundStyle(.tippyTextSecondary)
                        .lineSpacing(4)
                }

                VStack(alignment: .leading, spacing: TippySpacing.sm) {
                    Text("YOUR SITUATION")
                        .font(.tippyLabel)
                        .foregroundStyle(.tippyTextSecondary)
                        .tracking(1.0)

                    VStack(alignment: .trailing, spacing: TippySpacing.sm) {
                        TextEditor(text: $state.noBillText)
                            .font(.callout)
                            .frame(minHeight: 140)
                            .padding(TippySpacing.md)
                            .scrollContentBackground(.hidden)
                            .background(Color.tippySurface)
                            .clipShape(RoundedRectangle(cornerRadius: TippyRadius.card, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: TippyRadius.card, style: .continuous)
                                    .stroke(isFocused ? Color.tippyPrimary : Color.tippyBorder, lineWidth: isFocused ? 1.5 : 1)
                            )
                            .overlay(alignment: .topLeading) {
                                if state.noBillText.isEmpty {
                                    Text("e.g., Holiday tip for my barber, I've been going for 2 years, haircut is usually $40")
                                        .font(.callout)
                                        .foregroundStyle(.tippyTextTertiary)
                                        .padding(.horizontal, TippySpacing.base)
                                        .padding(.top, TippySpacing.lg)
                                        .allowsHitTesting(false)
                                }
                            }
                            .focused($isFocused)

                        Text("\(state.noBillText.count)/280")
                            .font(.caption)
                            .foregroundStyle(state.noBillText.count > 260 ? .tippyPrimary : .tippyTextTertiary)
                    }
                    .onChange(of: state.noBillText) { _, newValue in
                        if newValue.count > 280 {
                            state.noBillText = String(newValue.prefix(280))
                        }
                    }
                }

                Button {
                    getAdvice()
                } label: {
                    HStack {
                        HStack(spacing: TippySpacing.sm) {
                            Image(systemName: "sparkles")
                            Text("Get Advice")
                        }
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.body.weight(.medium))
                    }
                    .tippyPrimaryButton(enabled: canAdvise)
                }
                .disabled(!canAdvise)
            }
            .padding(.horizontal, TippySpacing.xl)
            .padding(.top, TippySpacing.base)
            .padding(.bottom, TippySpacing.xxl)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var canAdvise: Bool {
        state.noBillText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10
    }

    private func getAdvice() {
        isFocused = false
        withAnimation(.easeInOut(duration: 0.25)) {
            state.currentScreen = .loading
        }

        let startTime = Date()

        Task {
            let result = await TipCoordinator.advise(
                text: state.noBillText,
                city: locationService.city,
                state: locationService.state,
                usageLimiter: usageLimiter
            )

            let elapsed = Date().timeIntervalSince(startTime)
            if elapsed < 0.5 {
                try? await Task.sleep(for: .seconds(0.5 - elapsed))
            }

            state.result = result
            state.selectedOption = .recommended
            state.feedbackGiven = nil

            withAnimation(.easeInOut(duration: 0.3)) {
                state.currentScreen = .result
            }
        }
    }
}

#Preview {
    NoBillView(state: TipState(), locationService: LocationService(), usageLimiter: UsageLimiter())
}
