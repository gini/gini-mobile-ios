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
 - importError: Error related to importing documents.
 */

@objc public enum ErrorType: Int {
    case connection
    case request
    case serverError
    case authentication
    case unexpected
    case importError

    /**
     Initializes a new instance of the `ErrorType` enum based on the given `GiniError`.

     - Parameters:
        - error: The `GiniError` to base the `ErrorType` on.
     */
    public init(error: GiniError) {
        switch error {
        case .unauthorized(_, _):
            self = .authentication
        case .noResponse:
            self = .connection
        case .notAcceptable(let response, _), .tooManyRequests(let response, _),
                .parseError(_, let response, _), .badRequest(let response, _), .notFound(let response, _):
            if let status = response?.statusCode {
                switch status {
                case 400, 402 ... 499:
                    self = .request
                case 401:
                    self = .authentication
                case let code where code >= 500:
                    self = .serverError
                default:
                    self = .unexpected
                }
            } else {
                self = .serverError
            }
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
        case .serverError:
            return "errorCloud"
        case .unexpected:
            return "alertTriangle"
        case .importError:
            return "alertTriangle"
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
        case .importError:
            return NSLocalizedStringPreferredFormat(
                "ginicapture.error.importError.content",
                comment: "Import error")
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
        case .importError:
            return NSLocalizedStringPreferredFormat(
                "ginicapture.error.importError.title",
                comment: "Upload error")
        }
    }
}
