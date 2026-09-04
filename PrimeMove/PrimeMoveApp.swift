import SwiftUI
import UIKit
import PrimeMoveKit

@main
struct PrimeMoveApp: App {
    @UIApplicationDelegateAdaptor(PrimeMoveKitAppDelegators.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            PrimeMoveKitScreens {
                Group {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        PadRootView()      // iPad: sidebar-driven layout, see `iPad/`
                    } else {
                        RootView()         // iPhone: unchanged tab-bar experience
                    }
                }
                .preferredColorScheme(.dark)
                .tint(Theme.volt)
            }
           
        }
    }
}
