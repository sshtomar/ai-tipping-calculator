import SwiftUI

struct NoBillView: View {
    @Bindable var state: TipState
    @FocusState private var isFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Back button
                Button {
                    withAnimation {
                        state.currentScreen = .entry
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                    }
                    .font(.system(size: 15))
                    .foregroundStyle(.tippyTextSecondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Describe the situation")
                        .font(.custom("Georgia", size: 28))
                        .foregroundStyle(.tippyText)

                    Text("Tell us who you're tipping, how long you've used their service, what they usually charge — whatever feels relevant.")
                        .font(.system(size: 15))
                        .foregroundStyle(.tippyTextSecondary)
                        .lineSpacing(3)
                }

                VStack(alignment: .trailing, spacing: 6) {
                    TextEditor(text: $state.noBillText)
                        .font(.system(size: 16))
                        .frame(minHeight: 140)
                        .padding(12)
                        .scrollContentBackground(.hidden)
                        .background(Color.tippySurface)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.tippyBorder, lineWidth: 2)
                        )
                        .overlay(alignment: .topLeading) {
                            if state.noBillText.isEmpty {
                                Text("e.g., Holiday tip for my barber, I've been going for 2 years, haircut is usually $40")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.tippyTextTertiary)
                                    .padding(.horizontal, 17)
                                    .padding(.top, 20)
                                    .allowsHitTesting(false)
                            }
                        }
                        .focused($isFocused)

                    Text("\(state.noBillText.count)/280")
                        .font(.system(size: 12))
                        .foregroundStyle(.tippyTextTertiary)
                }
                .onChange(of: state.noBillText) { _, newValue in
                    if newValue.count > 280 {
                        state.noBillText = String(newValue.prefix(280))
                    }
                }

                Button {
                    getAdvice()
                } label: {
                    Text("Get Advice")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(canAdvise ? Color.tippyText : Color.tippyText.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .disabled(!canAdvise)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 80)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var canAdvise: Bool {
        state.noBillText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10
    }

    private func getAdvice() {
        isFocused = false
        withAnimation {
            state.currentScreen = .loading
        }

        let delay = Double.random(in: 0.8...1.6)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            state.result = TipEngine.advise(text: state.noBillText)
            state.selectedOption = .recommended
            state.feedbackGiven = nil

            withAnimation(.easeInOut(duration: 0.4)) {
                state.currentScreen = .result
            }
        }
    }
}

#Preview {
    NoBillView(state: TipState())
}
