import SwiftUI

struct LoadingView: View {
    @State private var messageIndex = 0
    @State private var dotScale: [CGFloat] = [0.4, 0.4, 0.4]

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
        VStack(spacing: 28) {
            HStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color.tippyPrimary)
                        .frame(width: 10, height: 10)
                        .scaleEffect(dotScale[i])
                }
            }
            .onAppear { startAnimation() }

            Text(messages[messageIndex])
                .font(.system(size: 15))
                .foregroundStyle(.tippyTextSecondary)
                .italic()
                .multilineTextAlignment(.center)
                .contentTransition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: messageIndex)
                .onAppear {
                    messageIndex = Int.random(in: 0..<messages.count)
                    scheduleMessageChange()
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.tippyBackground)
    }

    private func startAnimation() {
        for i in 0..<3 {
            withAnimation(
                .easeInOut(duration: 0.5)
                .repeatForever(autoreverses: true)
                .delay(Double(i) * 0.15)
            ) {
                dotScale[i] = 1.0
            }
        }
    }

    private func scheduleMessageChange() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            var next = Int.random(in: 0..<messages.count)
            while next == messageIndex { next = Int.random(in: 0..<messages.count) }
            messageIndex = next
        }
    }
}

#Preview {
    LoadingView()
}
