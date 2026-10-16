import SwiftUI
import UIKit

@main
struct PrimeMoveApp: App {
    @UIApplicationDelegateAdaptor(AppReviewAppDelegate.self) private var reviewAppDelegate

    /// First run shows the tour; after that it never appears again.
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {
            AppLaunchContainer {
                AppReviewContainer {
                    Group {
                        if UIDevice.current.userInterfaceIdiom == .pad {
                            PadRootView()      // iPad: sidebar-driven layout, see `iPad/`
                        } else {
                            RootView()         // iPhone: tab-bar experience
                        }
                    }
                    .preferredColorScheme(.dark)
                    .tint(Theme.volt)
                    .fullScreenCover(isPresented: Binding(
                        get: { !hasSeenOnboarding },
                        set: { showing in if !showing { hasSeenOnboarding = true } })) {
                        OnboardingView { hasSeenOnboarding = true }
                    }
                }
            }
        }
    }
}
