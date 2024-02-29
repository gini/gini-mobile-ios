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
 */

@objc public enum ErrorType: Int {
    case connection
    case request
    case serverError
    case authentication
    case unexpected
    case maintenance
    case outage

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
        case .noResponse:
            self = .unexpected
        case .notAcceptable, .tooManyRequests,
             .parseError, .badRequest,
             .notFound:
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
    }

    func iconName() -> String {
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

    func content() -> String {
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

    func title() -> String {
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
}
