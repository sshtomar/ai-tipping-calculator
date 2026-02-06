import SwiftUI

@main
struct TippyApp: App {
    @AppStorage("hasOnboarded") private var hasOnboarded = false

    var body: some Scene {
        WindowGroup {
            if hasOnboarded {
                MainTabView()
            } else {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        hasOnboarded = true
                    }
                }
            }
        }
    }
}
