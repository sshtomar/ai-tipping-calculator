import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var tipState = TipState()

    var body: some View {
        TabView(selection: $selectedTab) {
            TipFlowView(state: tipState)
                .tabItem {
                    Label("Tip", systemImage: "dollarsign")
                }
                .tag(0)

            GuideView()
                .tabItem {
                    Label("Guide", systemImage: "book")
                }
                .tag(1)
        }
        .tint(Color.tippyPrimaryDark)
    }
}

#Preview {
    MainTabView()
}
