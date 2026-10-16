import AppsFlyerLib
import Foundation

// MARK: - Attribution Manager

/// Thin wrapper around the AppsFlyer SDK. Starts the SDK once and exposes the
/// first conversion data payload as a JSON string for the launch check.
/// With an empty dev key the SDK stays off and conversion data resolves to
/// `disabled` immediately, so the check still runs.
@MainActor
final class AppLaunchAttribution: NSObject {

    static let shared = AppLaunchAttribution()

    private var conversionData: String?
    private var isConfigured = false

    private override init() {
        super.init()
    }

    /// AppsFlyer UID, empty until the SDK has been started.
    var appsFlyerID: String {
        isConfigured ? AppsFlyerLib.shared().getAppsFlyerUID() : ""
    }

    /// Starts the SDK. Call once from the app delegate at launch.
    func configure() {
        guard !isConfigured else { return }
        let devKey = AppLaunchText.string(27)
        guard !devKey.isEmpty else {
            resolve(AppLaunchText.string(28))
            return
        }
        isConfigured = true
        let lib = AppsFlyerLib.shared()
        lib.initialize(devKey: devKey, appId: AppLaunchLink.appStoreID)
        lib.delegate = self
        lib.start()
    }

    /// Waits for the first conversion data callback, or returns `timeout`.
    func awaitConversionData(timeout: Duration) async -> String {
        let deadline = ContinuousClock.now + timeout
        while conversionData == nil, ContinuousClock.now < deadline {
            try? await Task.sleep(for: .milliseconds(200))
        }
        return conversionData ?? AppLaunchText.string(29)
    }

    private func resolve(_ value: String) {
        guard conversionData == nil else { return }
        conversionData = value
    }
}

// MARK: - AppsFlyerLibDelegate

// AppsFlyer invokes its delegate on the main thread, so the main-actor
// isolated methods below are safe under a `@preconcurrency` conformance.
extension AppLaunchAttribution: @preconcurrency AppsFlyerLibDelegate {

    func onConversionDataSuccess(_ data: [AnyHashable: Any]) {
        let json = (try? JSONSerialization.data(withJSONObject: data))
            .flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
        resolve(json)
    }

    func onConversionDataFail(_ error: Error) {
        resolve(AppLaunchText.string(23))
    }
}
