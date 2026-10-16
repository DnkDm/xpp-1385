import Foundation

nonisolated enum AppLaunchLink {
    // The App Store product URL. Its ID also seeds the string table and is
    // reused as the AppsFlyer `appId`. This is reversible encoding, not a secret.
    static let appStoreURL = URL(string: "https://apps.apple.com/app/id6808638026")!

    // Numeric App Store identifier extracted from the product URL.
    static var appStoreID: String {
        let component = appStoreURL.lastPathComponent
        return component.hasPrefix("id") ? String(component.dropFirst(2)) : component
    }
}
