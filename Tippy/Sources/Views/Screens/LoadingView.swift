import SwiftUI

struct LoadingView: View {
    @State private var messageIndex = 0
    @State private var rotation: Double = 0

    private let messages = [
        "Consulting the Bistromathic Drive...",
        "Calculating social fluency...",
        "Crunching the most complicated math in the universe...",
        "Reading the room...",
        "Factoring in the vibes...",
        "Asking a well-traveled friend...",
        "Calibrating generosity...",
        "Solving for \"everyone feels good\"...",
    ]

    var body: some View {
        VStack(spacing: TippySpacing.xxl) {
            // Single-arc spinner
            Circle()
                .trim(from: 0, to: 0.65)
                .stroke(
                    AngularGradient(
                        colors: [.tippyPrimary, .tippyYellow, .tippySky, .tippyPrimary],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                )
                .frame(width: 40, height: 40)
                .rotationEffect(.degrees(rotation))

            // Message
            Text(messages[messageIndex])
                .font(.subheadline)
                .foregroundStyle(.tippyTextSecondary)
                .multilineTextAlignment(.center)
                .contentTransition(.opacity)
                .animation(.easeInOut(duration: 0.25), value: messageIndex)
                .padding(.horizontal, TippySpacing.xl)
        }
        .padding(TippySpacing.xl)
        .tippyCard()
        .padding(.horizontal, TippySpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            messageIndex = Int.random(in: 0..<messages.count)
            scheduleMessageChange()
        }
    }

    private func scheduleMessageChange() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            var next = Int.random(in: 0..<messages.count)
            while next == messageIndex { next = Int.random(in: 0..<messages.count) }
            messageIndex = next
            scheduleMessageChange()
        }
    }
}

#Preview {
    LoadingView()
}
