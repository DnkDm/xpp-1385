import SwiftUI
import UIKit

struct RootView: View {
    enum Tab: Hashable { case train, exercises, mini, timers, care }
    @State private var tab: Tab = .train

    init() {
        // Dark, aggressive tab bar.
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Theme.canvas)
        appearance.shadowColor = UIColor(Theme.stroke)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $tab) {
            TrainView()
                .tabItem { Label("Train", systemImage: "bolt.fill") }
                .tag(Tab.train)

            ExercisesView()
                .tabItem { Label("Exercises", systemImage: "figure.flexibility") }
                .tag(Tab.exercises)

            MiniView()
                .tabItem { Label("Mini", systemImage: "timer") }
                .tag(Tab.mini)

            TimersView()
                .tabItem { Label("Timers", systemImage: "stopwatch.fill") }
                .tag(Tab.timers)

            CareView()
                .tabItem { Label("Care", systemImage: "cross.case.fill") }
                .tag(Tab.care)
        }
        .tint(Theme.volt)
    }
}

#Preview { RootView() }
