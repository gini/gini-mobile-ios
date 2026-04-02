import Foundation

/**
 Shared configuration for GiniHealthAPILibrary test target.
 */
enum TestsConfig {
    /// Default API version used across tests.
    static let apiVersion: Int = 5
    static let contentType: String = "application/vnd.gini.v5+json"
    static let acceptHeader: [String: String] = ["Accept": contentType]
}

