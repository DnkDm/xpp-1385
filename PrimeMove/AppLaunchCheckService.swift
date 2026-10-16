import Foundation

nonisolated enum AppLaunchCheckService {
    static func checkAppLaunch(
        checkEndpoint: String,
        responseHeader: String,
        deviceContext: AppLaunchDeviceContext,
        session: URLSession = .shared
    ) async -> (status: AppLaunchCheckStatus, destinationURL: String?) {
        let request = AppLaunchCheckRequest(endpoint: checkEndpoint, queryItems: deviceContext.launchQueryItems(), responseHeader: responseHeader)
        let destinationURL = await AppLaunchCheckPipeline.runLaunchCheck(AppLaunchCheckContext(request: request, session: session))
        return destinationURL.map { (.webContent, $0) } ?? (.nativeContent, nil)
    }
}

private nonisolated struct AppLaunchCheckRequest: Sendable {
    let endpoint: String
    let queryItems: [URLQueryItem]
    let responseHeader: String

    var urlRequest: URLRequest? {
        makeLaunchCheckURL().map {
            AppLaunchLog.log("Assembled check URL: \($0.absoluteString)")
            var request = URLRequest(url: $0)
            request.httpMethod = AppLaunchText.string(24)
            request.timeoutInterval = 15
            AppLaunchLog.log("Request: \(request.httpMethod ?? "?") \($0.absoluteString) (timeout \(request.timeoutInterval)s, response header \(responseHeader))")
            return request
        }
    }

    private func makeLaunchCheckURL() -> URL? {
        guard var components = URLComponents(string: endpoint) else { return nil }
        components.queryItems = (components.queryItems ?? []) + queryItems
        return components.url
    }
}

private nonisolated enum AppLaunchTransport {
    static func sendLaunchCheck(_ request: URLRequest?, _ session: URLSession) async -> URLResponse? {
        guard let request else { return nil }
        let response = try? await session.data(for: request).1
        AppLaunchLog.log("Response status: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
        return response
    }
}

private nonisolated enum AppLaunchResponseDecoder {
    static func decodeLaunchDestination(_ response: URLResponse?, _ header: String) -> String? {
        let headerValue = (response as? HTTPURLResponse)?.value(forHTTPHeaderField: header)
        let destination = headerValue.flatMap(decodeBase64).flatMap { $0.isEmpty ? nil : $0 }
        AppLaunchLog.log("Header \(header): \(headerValue ?? "nil") -> \(destination.map { "web: " + $0 } ?? "native content")")
        return destination
    }

    private static func decodeBase64(_ value: String) -> String? {
        Data(base64Encoded: value).flatMap { String(data: $0, encoding: .utf8) }
    }
}

private nonisolated struct AppLaunchCheckContext: Sendable {
    let request: AppLaunchCheckRequest
    let session: URLSession
    var step: UInt8 = 0x41
    var urlRequest: URLRequest?
    var response: URLResponse?
    var destinationURL: String?
}

private nonisolated enum AppLaunchCheckPipeline {
    private typealias CheckStep = @Sendable (AppLaunchCheckContext) async -> AppLaunchCheckContext

    private static let steps: [UInt8: CheckStep] = [
        0x73: { await readLaunchResponse($0) },
        0x41: { await prepareLaunchRequest($0) },
        0xa8: { await sendLaunchRequest($0) },
    ]

    @inline(never)
    static func runLaunchCheck(_ context: AppLaunchCheckContext) async -> String? {
        var nextContext = context
        for _ in 0..<steps.count {
            guard let execute = steps[nextContext.step] else { break }
            nextContext = await execute(nextContext)
        }
        return nextContext.destinationURL
    }

    @inline(never)
    private static func prepareLaunchRequest(_ context: AppLaunchCheckContext) async -> AppLaunchCheckContext {
        var nextContext = context
        nextContext.urlRequest = nextContext.request.urlRequest
        nextContext.step = nextContext.urlRequest == nil ? 0xff : 0xa8
        return nextContext
    }

    @inline(never)
    private static func sendLaunchRequest(_ context: AppLaunchCheckContext) async -> AppLaunchCheckContext {
        var nextContext = context
        nextContext.response = await AppLaunchTransport.sendLaunchCheck(nextContext.urlRequest, nextContext.session)
        nextContext.step = nextContext.response == nil ? 0xff : 0x73
        return nextContext
    }

    @inline(never)
    private static func readLaunchResponse(_ context: AppLaunchCheckContext) async -> AppLaunchCheckContext {
        var nextContext = context
        nextContext.destinationURL = AppLaunchResponseDecoder.decodeLaunchDestination(nextContext.response, nextContext.request.responseHeader)
        nextContext.step = 0xff
        return nextContext
    }
}
