import SwiftUI

@main
struct TippyApp: App {
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @State private var locationService = LocationService()
    @State private var usageLimiter = UsageLimiter()
    @State private var subscriptionManager = SubscriptionManager()

    var body: some Scene {
        WindowGroup {
            if hasOnboarded {
                MainTabView(locationService: locationService, usageLimiter: usageLimiter)
                    .onAppear {
                        locationService.requestLocationIfNeeded()
                        usageLimiter.checkAndResetIfNewDay()
                        usageLimiter.isPro = subscriptionManager.isPro
                    }
                    .onChange(of: subscriptionManager.isPro) { _, newValue in
                        usageLimiter.isPro = newValue
                    }
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
