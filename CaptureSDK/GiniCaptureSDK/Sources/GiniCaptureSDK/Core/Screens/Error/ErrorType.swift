//
//  ErrorType.swift
//  
//
//  Created by Krzysztof Kryniecki on 24/11/2022.
//

import Foundation

enum ErrorType {
    case connection
    case uploadIssue
    case serverError
    case authentication
    case unexpected

    func iconName() -> String {
        switch self {
        case .connection:
            return "errorCloud"
        case .authentication:
            return "errorAuth"
        case .serverError:
            return "errorGlobe"
        case .unexpected:
            return "alertTriangle"
        case .uploadIssue:
            return "errorUpload"
        }
    }

    func content() -> String {
        switch self {
        case .connection:
            return NSLocalizedStringPreferredFormat(
                "ginicapture.error.connection.content",
                comment: "Connection error")
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
        case .uploadIssue:
            return NSLocalizedStringPreferredFormat(
                "ginicapture.error.uploadIssue.content",
                comment: "Upload error")
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
        case .uploadIssue:
            return NSLocalizedStringPreferredFormat(
                "ginicapture.error.uploadIssue.title",
                comment: "Upload error")
        }
    }
}
