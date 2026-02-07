import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.tippyBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 20) {
                    // Lightbulb icon
                    Image(systemName: "lightbulb.max")
                        .font(.system(.largeTitle).weight(.light))
                        .foregroundStyle(.tippyPrimary)
                        .symbolEffect(.pulse, options: .repeating, isActive: appeared)

                    Text("Tippy")
                        .font(.custom("Georgia", size: 52, relativeTo: .largeTitle))
                        .foregroundStyle(.tippyText)

                    VStack(spacing: 6) {
                        Text("Nobody knows how to tip anymore.")
                            .font(.title3.weight(.medium))
                        Text("Now you do.")
                            .font(.title3.weight(.medium))
                    }
                    .foregroundStyle(.tippyText)
                    .multilineTextAlignment(.center)

                    Text("Enter your bill, tell us the situation, and get a single confident answer — not a percentage slider.")
                        .font(.subheadline)
                        .foregroundStyle(.tippyTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    HStack(spacing: 8) {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                        Text("Your tips and data never leave this device.")
                            .font(.footnote)
                    }
                    .foregroundStyle(.tippyTextTertiary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.tippySurfaceSecondary)
                    .clipShape(Capsule())
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

                Spacer()

                Button(action: onComplete) {
                    Text("Get Started")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.tippyText)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
                .opacity(appeared ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }
}

#Preview {
    OnboardingView { }
}
