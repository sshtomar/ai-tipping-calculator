import SwiftUI

struct MainTabView: View {
    var locationService: LocationService
    var usageLimiter: UsageLimiter
    @State private var selectedTab = 0
    @State private var tipState = TipState()

    var body: some View {
        TabView(selection: $selectedTab) {
            TipFlowView(state: tipState, locationService: locationService, usageLimiter: usageLimiter)
                .tabItem {
                    Label("Tip", systemImage: "dollarsign.circle.fill")
                }
                .tag(0)

            GuideView()
                .tabItem {
                    Label("Guide", systemImage: "book.fill")
                }
                .tag(1)

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(2)
        }
        .tint(Color.tippyPrimaryDark)
    }
}
