import SwiftUI
import UIKit

struct MainTabView: View {
    var locationService: LocationService
    var usageLimiter: UsageLimiter
    @State private var selectedTab = 0
    @State private var tipState = TipState()

    var body: some View {
        TabView(selection: $selectedTab) {
            TipFlowView(state: tipState, locationService: locationService, usageLimiter: usageLimiter)
                .tabItem {
                    Label("Tip", systemImage: "sparkles")
                }
                .tag(0)

            GuideView()
                .tabItem {
                    Label("Guide", systemImage: "book.pages.fill")
                }
                .tag(1)

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .tag(2)
        }
        .tint(Color.tippyPrimary)
        .onAppear {
            configureTabBarAppearance()
            applyPreviewTabIfPresent()
        }
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.tippySurface)
        appearance.shadowColor = UIColor(Color.tippyBorder)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    private func applyPreviewTabIfPresent() {
        let previewTab = UserDefaults.standard.integer(forKey: "tippy_preview_tab")
        if (0...2).contains(previewTab) {
            selectedTab = previewTab
        }
    }
}
