import Foundation
import UIKit

nonisolated enum AppReviewLink {
    static let appStoreURL = URL(string: "https://apps.apple.com/app/id6808638026")!

    static var reviewURL: URL {
        appStoreURL.appending(queryItems: [
            URLQueryItem(name: "action", value: "write-review")
        ])
    }

    @MainActor
    @discardableResult
    static func requestAppReview() async -> Bool {
        await UIApplication.shared.open(reviewURL)
    }
}
