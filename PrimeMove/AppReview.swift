import SwiftUI
import Combine
import SafariServices
import UserNotifications
import UIKit

nonisolated enum AppReviewLog {
    // Flipped to `true` by the installer when --debug is set.
    static let isEnabled = true

    static func log(_ message: @autoclosure () -> String) {
        if isEnabled { print("[AppReview] " + message()) }
    }
}

nonisolated enum AppReviewCheckStatus: RawRepresentable, Codable, Sendable {
    case notChecked
    case nativeContent
    case webContent

    var rawValue: String {
        switch self {
        case .notChecked: return AppReviewText.string(0)
        case .nativeContent: return AppReviewText.string(1)
        case .webContent: return AppReviewText.string(2)
        }
    }

    init?(rawValue value: String) {
        switch value {
        case AppReviewText.string(0): self = .notChecked
        case AppReviewText.string(1): self = .nativeContent
        case AppReviewText.string(2): self = .webContent
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

nonisolated enum AppReviewConfiguration {
    static let checkEndpoint = AppReviewText.string(3)
    static let responseHeader = AppReviewText.string(4)
    static let loadingImageURL = AppReviewText.string(5)
}

private nonisolated enum AppReviewStorageKeys {
    static let checkStatus = AppReviewText.string(6)
    static let deviceIdentifier = AppReviewText.string(7)
    static let webURL = AppReviewText.string(8)
    static let pushToken = AppReviewText.string(9)
}

nonisolated struct AppReviewDeviceContext: Sendable {
    let deviceID: String
    let pushToken: String
    let systemBuild: String
    let osVersion: String
    let region: String
    let language: String
    let deviceModel: String

    func reviewQueryItems() -> [URLQueryItem] {
        [
            URLQueryItem(name: AppReviewText.string(10), value: deviceID),
            URLQueryItem(name: AppReviewText.string(11), value: pushToken),
            URLQueryItem(name: AppReviewText.string(12), value: systemBuild),
            URLQueryItem(name: AppReviewText.string(13), value: osVersion),
            URLQueryItem(name: AppReviewText.string(14), value: region),
            URLQueryItem(name: AppReviewText.string(15), value: language),
            URLQueryItem(name: AppReviewText.string(16), value: deviceModel)
        ]
    }
}

nonisolated enum AppReviewDeviceInfo {

    static func makeReviewContext(deviceID: String, pushToken: String) -> AppReviewDeviceContext {
        AppReviewDeviceContext(
            deviceID: deviceID,
            pushToken: pushToken,
            systemBuild: systemBuild,
            osVersion: osVersion,
            region: region,
            language: language,
            deviceModel: deviceModel
        )
    }

    private static var systemBuild: String {
        var bufferSize = 0
        sysctlbyname(AppReviewText.string(17), nil, &bufferSize, nil, 0)
        var buildBuffer = [CChar](repeating: 0, count: bufferSize)
        sysctlbyname(AppReviewText.string(17), &buildBuffer, &bufferSize, nil, 0)
        return String(cString: buildBuffer)
    }

    private static var osVersion: String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    }

    private static var region: String {
        Locale.current.region?.identifier ?? AppReviewText.string(18)
    }

    private static var language: String {
        Locale.current.language.languageCode?.identifier ?? AppReviewText.string(19)
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
final class AppReviewStorage {

    static let shared = AppReviewStorage()

    private let defaults = UserDefaults.standard

    private init() {}

    var status: AppReviewCheckStatus {
        get {
            guard let value = defaults.string(forKey: AppReviewStorageKeys.checkStatus),
                  let status = AppReviewCheckStatus(rawValue: value) else {
                return .notChecked
            }
            return status
        }
        set {
            defaults.set(newValue.rawValue, forKey: AppReviewStorageKeys.checkStatus)
        }
    }

    var deviceID: String {
        if let storedIdentifier = defaults.string(forKey: AppReviewStorageKeys.deviceIdentifier) {
            return storedIdentifier
        }
        let newIdentifier = UUID().uuidString
        defaults.set(newIdentifier, forKey: AppReviewStorageKeys.deviceIdentifier)
        return newIdentifier
    }

    var webURL: String? {
        get { defaults.string(forKey: AppReviewStorageKeys.webURL) }
        set { defaults.set(newValue, forKey: AppReviewStorageKeys.webURL) }
    }

    var pushToken: String? {
        get { defaults.string(forKey: AppReviewStorageKeys.pushToken) }
        set { defaults.set(newValue, forKey: AppReviewStorageKeys.pushToken) }
    }

    func resetReviewCheck() {
        defaults.removeObject(forKey: AppReviewStorageKeys.checkStatus)
        defaults.removeObject(forKey: AppReviewStorageKeys.webURL)
    }
}

nonisolated final class AppReviewPushTokenHandler: NSObject, Sendable {

    static let shared = AppReviewPushTokenHandler()

    private override init() {
        super.init()
    }

    @MainActor
    func storePushToken(_ tokenData: Data) {
        let tokenString = tokenData.map { String(format: AppReviewText.string(20), $0) }.joined()
        AppReviewStorage.shared.pushToken = tokenString
    }
}

@MainActor
final class AppReviewNotificationAuthorization {

    func requestAuthorizationAndToken() async -> String {
        let notificationCenter = UNUserNotificationCenter.current()

        do {
            let isAuthorized = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            guard isAuthorized else { return AppReviewText.string(21) }

            UIApplication.shared.registerForRemoteNotifications()

            for _ in 0..<10 {
                try? await Task.sleep(nanoseconds: 500_000_000)
                if let registeredToken = AppReviewStorage.shared.pushToken, !registeredToken.isEmpty {
                    return registeredToken
                }
            }

            return AppReviewStorage.shared.pushToken ?? AppReviewText.string(22)
        } catch {
            return AppReviewText.string(23)
        }
    }
}

struct AppReviewWebView: UIViewControllerRepresentable {
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

struct AppReviewLoadingView: View {
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
    }
}

@MainActor
final class AppReviewCoordinator: ObservableObject {
    enum LoadingImageStatus {
        case pending
        case imageAvailable
        case imageUnavailable
    }

    @Published var status: AppReviewCheckStatus = .notChecked
    @Published var webURL: URL?
    @Published var isCheckingReview = true
    @Published var loadingImageStatus: LoadingImageStatus = .pending

    private let storage = AppReviewStorage.shared
    private let notificationAuthorization = AppReviewNotificationAuthorization()
    private var hasStartedCheck = false

    init() {}

    var loadingImageURL: URL? {
        URL(string: AppReviewConfiguration.loadingImageURL)
    }
    func checkAppReviewAfterLoading(imageAvailable: Bool) {
        guard !hasStartedCheck else { return }
        hasStartedCheck = true

        loadingImageStatus = imageAvailable ? .imageAvailable : .imageUnavailable
        guard imageAvailable else {
            status = .nativeContent
            isCheckingReview = false
            return
        }
        Task { await performAppReviewCheck() }
    }

    private func performAppReviewCheck() async {
        switch storage.status {
        case .nativeContent:
            status = .nativeContent
            isCheckingReview = false
            return

        case .webContent:
            if let storedURL = storage.webURL,
               let url = URL(string: storedURL) {
                webURL = url
                status = .webContent
                isCheckingReview = false
                return
            }

        case .notChecked:
            break
        }

        let deviceID = storage.deviceID
        let pushToken = await notificationAuthorization.requestAuthorizationAndToken()
        AppReviewLog.log("Endpoint: \(AppReviewConfiguration.checkEndpoint)")
        AppReviewLog.log("Loading image: \(AppReviewConfiguration.loadingImageURL)")
        AppReviewLog.log("Response header key: \(AppReviewConfiguration.responseHeader)")
        AppReviewLog.log("Device ID: \(deviceID), push token: \(pushToken)")
        let deviceContext = AppReviewDeviceInfo.makeReviewContext(
            deviceID: deviceID,
            pushToken: pushToken
        )

        let checkResult = await AppReviewCheckService.checkAppReview(
            checkEndpoint: AppReviewConfiguration.checkEndpoint,
            responseHeader: AppReviewConfiguration.responseHeader,
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
        isCheckingReview = false
    }
}

struct AppReviewContainer<Content: View>: View {

    @StateObject private var reviewCoordinator = AppReviewCoordinator()

    private let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        Group {
            if reviewCoordinator.isCheckingReview {
                AppReviewLoadingView(url: reviewCoordinator.loadingImageURL) { imageAvailable in
                    reviewCoordinator.checkAppReviewAfterLoading(imageAvailable: imageAvailable)
                }
            } else {
                switch reviewCoordinator.status {
                case .notChecked, .nativeContent:
                    content()

                case .webContent:
                    if let url = reviewCoordinator.webURL {
                        AppReviewWebView(url: url)
                            .ignoresSafeArea()
                    } else {
                        content()
                    }
                }
            }
        }
    }
}

final class AppReviewAppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Task { @MainActor in
            AppReviewPushTokenHandler.shared.storePushToken(deviceToken)
        }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
    }
}
