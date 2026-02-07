import SwiftUI

struct LoadingView: View {
    @State private var messageIndex = 0
    @State private var dotScale: [CGFloat] = [0.4, 0.4, 0.4]
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
        VStack(spacing: 28) {
            // Animated loading indicator
            ZStack {
                Circle()
                    .stroke(Color.tippyBorder, lineWidth: 3)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        Color.tippyPrimary,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(rotation))
                
                Image(systemName: "sparkles")
                    .font(.title3)
                    .foregroundStyle(.tippyPrimary)
            }
            .onAppear {
                withAnimation(
                    .linear(duration: 1.2)
                    .repeatForever(autoreverses: false)
                ) {
                    rotation = 360
                }
            }

            Text(messages[messageIndex])
                .font(.subheadline)
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
