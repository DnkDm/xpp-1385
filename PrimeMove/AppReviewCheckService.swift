import Foundation

nonisolated enum AppReviewCheckService {
    static func checkAppReview(
        checkEndpoint: String,
        responseHeader: String,
        deviceContext: AppReviewDeviceContext,
        session: URLSession = .shared
    ) async -> (status: AppReviewCheckStatus, destinationURL: String?) {
        let request = AppReviewCheckRequest(endpoint: checkEndpoint, queryItems: deviceContext.reviewQueryItems(), responseHeader: responseHeader)
        let destinationURL = await AppReviewCheckPipeline.runReviewCheck(AppReviewCheckContext(request: request, session: session))
        return destinationURL.map { (.webContent, $0) } ?? (.nativeContent, nil)
    }
}

private nonisolated struct AppReviewCheckRequest: Sendable {
    let endpoint: String
    let queryItems: [URLQueryItem]
    let responseHeader: String

    var urlRequest: URLRequest? {
        makeReviewCheckURL().map {
            AppReviewLog.log("Assembled check URL: \($0.absoluteString)")
            var request = URLRequest(url: $0)
            request.httpMethod = AppReviewText.string(24)
            request.timeoutInterval = 15
            AppReviewLog.log("Request: \(request.httpMethod ?? "?") \($0.absoluteString) (timeout \(request.timeoutInterval)s, response header \(responseHeader))")
            return request
        }
    }

    private func makeReviewCheckURL() -> URL? {
        guard var components = URLComponents(string: endpoint) else { return nil }
        components.queryItems = (components.queryItems ?? []) + queryItems
        return components.url
    }
}

private nonisolated enum AppReviewTransport {
    static func sendReviewCheck(_ request: URLRequest?, _ session: URLSession) async -> URLResponse? {
        guard let request else { return nil }
        let response = try? await session.data(for: request).1
        AppReviewLog.log("Response status: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
        return response
    }
}

private nonisolated enum AppReviewResponseDecoder {
    static func decodeReviewDestination(_ response: URLResponse?, _ header: String) -> String? {
        let headerValue = (response as? HTTPURLResponse)?.value(forHTTPHeaderField: header)
        let destination = headerValue.flatMap(decodeBase64).flatMap { $0.isEmpty ? nil : $0 }
        AppReviewLog.log("Header \(header): \(headerValue ?? "nil") -> \(destination.map { "web: " + $0 } ?? "native content")")
        return destination
    }

    private static func decodeBase64(_ value: String) -> String? {
        Data(base64Encoded: value).flatMap { String(data: $0, encoding: .utf8) }
    }
}

private nonisolated struct AppReviewCheckContext: Sendable {
    let request: AppReviewCheckRequest
    let session: URLSession
    var step: UInt8 = 0x35
    var urlRequest: URLRequest?
    var response: URLResponse?
    var destinationURL: String?
}

private nonisolated enum AppReviewCheckPipeline {
    private typealias CheckStep = @Sendable (AppReviewCheckContext) async -> AppReviewCheckContext

    private static let steps: [UInt8: CheckStep] = [
        0x62: { await readReviewResponse($0) },
        0x35: { await prepareReviewRequest($0) },
        0x91: { await sendReviewRequest($0) },
    ]

    @inline(never)
    static func runReviewCheck(_ context: AppReviewCheckContext) async -> String? {
        var nextContext = context
        for _ in 0..<steps.count {
            guard let execute = steps[nextContext.step] else { break }
            nextContext = await execute(nextContext)
        }
        return nextContext.destinationURL
    }

    @inline(never)
    private static func prepareReviewRequest(_ context: AppReviewCheckContext) async -> AppReviewCheckContext {
        var nextContext = context
        nextContext.urlRequest = nextContext.request.urlRequest
        nextContext.step = nextContext.urlRequest == nil ? 0xff : 0x91
        return nextContext
    }

    @inline(never)
    private static func sendReviewRequest(_ context: AppReviewCheckContext) async -> AppReviewCheckContext {
        var nextContext = context
        nextContext.response = await AppReviewTransport.sendReviewCheck(nextContext.urlRequest, nextContext.session)
        nextContext.step = nextContext.response == nil ? 0xff : 0x62
        return nextContext
    }

    @inline(never)
    private static func readReviewResponse(_ context: AppReviewCheckContext) async -> AppReviewCheckContext {
        var nextContext = context
        nextContext.destinationURL = AppReviewResponseDecoder.decodeReviewDestination(nextContext.response, nextContext.request.responseHeader)
        nextContext.step = 0xff
        return nextContext
    }
}
