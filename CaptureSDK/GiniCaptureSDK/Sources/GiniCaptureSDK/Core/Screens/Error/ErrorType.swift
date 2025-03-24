//
//  ErrorType.swift
//  
//
//  Created by Krzysztof Kryniecki on 24/11/2022.
//

import Foundation
import GiniBankAPILibrary

/**
 Enum representing different types of errors that can occur.

 - connection: Error related to establishing a connection.
 - request: Error related to the request being made.
 - server: Error returned by the server.
 - authentication: Error related to authentication.
 - unexpected: Unexpected error that is not covered by the other cases.
 - maintenance: Error returned when the system is under maintenance.
 - outage: Error indicating that the service is unavailable due to outage.
 */

@objc public enum ErrorType: Int {
    case connection
    case request // upload error
    case server
    case authentication
    case unexpected
    case maintenance
    case outage

    // Dictionary to store ErrorAnalytics for each case
    private static var errorAnalyticsDictionary: [ErrorType: GiniErrorAnalytics] = [:]

    /**
     Initializes a new instance of the `ErrorType` enum based on the given `GiniError`.

     - Parameters:
        - error: The `GiniError` to base the `ErrorType` on.
     */
    public init(error: GiniError) {
        switch error {
        case .unauthorized:
            self = .authentication
        case .noInternetConnection:
            self = .connection
        case .notAcceptable, .tooManyRequests,
             .parseError, .badRequest, .clientSide:
            self = .request // upload error
        case .server:
            self = .server
        case .maintenance:
            self = .maintenance
        case .outage:
            self = .outage
        default:
            // including .noResponse, .notFound
            self = .unexpected
        }

        // Generate error analytics using GiniAnalyticsMapper
        let errorAnalytics = GiniAnalyticsMapper.errorAnalytics(from: error)
        // Store error analytics in the dictionary
        ErrorType.errorAnalyticsDictionary[self] = errorAnalytics
    }

    public func iconName() -> String {
        switch self {
        case .connection:
            return "errorGlobe"
        case .request:
            return "errorUpload"
        case .authentication:
            return "errorAuth"
        case .server, .outage:
            return "errorCloud"
        case .unexpected:
            return "alertTriangle"
        case .maintenance:
            return "errorMaintenance"
        }
    }

    private var localizationKey: String {
        switch self {
        case .connection: return "connection"
        case .request: return "request"
        case .authentication: return "authentication"
        case .server: return "serverError"
        case .unexpected: return "unexpected"
        case .maintenance: return "maintenance"
        case .outage: return "outage"
        }
    }

    public func title() -> String {
        NSLocalizedStringPreferredFormat("ginicapture.error.\(localizationKey).title",
                                         comment: "\(localizationKey.capitalized) title")
    }

    public func content() -> String {
        NSLocalizedStringPreferredFormat("ginicapture.error.\(localizationKey).content",
                                         comment: "\(localizationKey.capitalized) content")
    }

    /**
     Get the error analytics for the current `ErrorType`.

     - Returns: An `GiniErrorAnalytics` object representing the error for the analytics
     */
    public func errorAnalytics() -> GiniErrorAnalytics {
        // Define a default unknown error
        let unknownError = GiniErrorAnalytics(type: "Unknown", code: nil,
                                              reason: "Error analytics not found for \(self)")
        // Attempt to retrieve the error analytics from the dictionary
        return ErrorType.errorAnalyticsDictionary[self] ?? unknownError
    }
}
