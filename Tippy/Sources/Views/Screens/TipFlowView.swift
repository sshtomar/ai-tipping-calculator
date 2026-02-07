import SwiftUI

struct TipFlowView: View {
    @Bindable var state: TipState
    var locationService: LocationService
    var usageLimiter: UsageLimiter

    var body: some View {
        NavigationStack {
            ZStack {
                Color.tippyBackground.ignoresSafeArea()

                switch state.currentScreen {
                case .entry:
                    EntryView(state: state)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                case .noBill:
                    NoBillView(state: state, locationService: locationService, usageLimiter: usageLimiter)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                case .context:
                    ContextView(state: state, locationService: locationService, usageLimiter: usageLimiter)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                case .loading:
                    LoadingView()
                        .transition(.opacity)
                case .result:
                    ResultView(state: state, usageLimiter: usageLimiter)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                case .receiptConfirmation:
                    ReceiptConfirmationView(state: state)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: state.currentScreen)
        }
    }
}
