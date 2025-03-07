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
 - serverError: Error returned by the server.
 - authentication: Error related to authentication.
 - unexpected: Unexpected error that is not covered by the other cases.
 - maintenance: Error returned when the system is under maintenance.
 - outage: Error indicating that the service is unavailable due to outage.
 */

@objc public enum ErrorType: Int {
    case connection
    case request
    case serverError
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
        case .noResponse, .notFound:
            self = .unexpected
        case .notAcceptable, .tooManyRequests,
             .parseError, .badRequest:
            self = .request
        case .server:
            self = .serverError
        case .maintenance:
            self = .maintenance
        case .outage:
            self = .outage
        default:
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
        case .serverError, .outage:
            return "errorCloud"
        case .unexpected:
            return "alertTriangle"
        case .maintenance:
            return "errorMaintenance"
        }
    }

    public func content() -> String {
        switch self {
        case .connection:
            return NSLocalizedStringPreferredFormat(
                "ginicapture.error.connection.content",
                comment: "Connection error")
        case .request:
            return NSLocalizedStringPreferredFormat(
                "ginicapture.error.request.content",
                comment: "Request error")
        case .authentication:
            return NSLocalizedStringPreferredFormat(
                "ginicapture.error.authentication.content",
                comment: "Authentication error")
        case .serverError:
            return NSLocalizedStringPreferredFormat(
                "ginicapture.error.serverError.content",
                comment: "Server error")
        case .unexpected:
            return NSLocalizedStringPreferredFormat(
                "ginicapture.error.unexpected.content",
                comment: "Unexpected error")
        case .maintenance:
            return NSLocalizedStringPreferredFormat(
                "ginicapture.error.maintenance.content",
                comment: "Maintenance error")
        case .outage:
            return NSLocalizedStringPreferredFormat(
                "ginicapture.error.outage.content",
                comment: "Outage error")
        }
    }

    public func title() -> String {
        switch self {
        case .connection:
            return NSLocalizedStringPreferredFormat(
                "ginicapture.error.connection.title",
                comment: "Connection error")
        case .authentication:
            return NSLocalizedStringPreferredFormat(
                "ginicapture.error.authentication.title",
                comment: "Authentication error")
        case .serverError:
            return NSLocalizedStringPreferredFormat(
                "ginicapture.error.serverError.title",
                comment: "Server error")
        case .unexpected:
            return NSLocalizedStringPreferredFormat(
                "ginicapture.error.unexpected.title",
                comment: "Unexpected error")
        case .request:
            return NSLocalizedStringPreferredFormat(
                "ginicapture.error.request.title",
                comment: "Upload error")
        case .maintenance:
            return NSLocalizedStringPreferredFormat(
                "ginicapture.error.maintenance.title",
                comment: "Maintenance error")
        case .outage:
            return NSLocalizedStringPreferredFormat(
                "ginicapture.error.outage.title",
                comment: "Outage error")
        }
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
