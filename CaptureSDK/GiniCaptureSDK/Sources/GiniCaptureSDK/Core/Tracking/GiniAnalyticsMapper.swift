//
//  GiniAnalyticsMapper.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import GiniBankAPILibrary

/**
 A utility class for mapping different types to their respective analytics representations.
 */
class GiniAnalyticsMapper {

    /**
     Converts a `NoResultScreenViewController.NoResultType` to its analytics string representation.

     - Parameter noResultType: The type of no result screen.
     - Returns: A string representing the document type for analytics purposes.
     */
    static func documentTypeAnalytics(from noResultType: NoResultScreenViewController.NoResultType) -> String {
        switch noResultType {
        case .pdf:
            return "pdf"
        case .image:
            return "image"
        case .qrCode:
            return "qrCode"
        default:
            return "unknown"
        }
    }

    /**
     Converts a `GiniCaptureDocumentType` to its analytics string representation.

     - Parameter documentType: The type of document captured.
     - Returns: A string representing the document type for analytics purposes.
     */
    static func documentTypeAnalytics(from documentType: GiniCaptureDocumentType) -> String {
        switch documentType {
        case .pdf:
            return "pdf"
        case .image:
            return "image"
        case .qrcode:
            return "qrCode"
        }
    }

    /**
     Converts a `GiniError` to an `GiniErrorAnalytics` object for analytics purposes.

     - Parameter error: The `GiniError` encountered.
     - Returns: An `GiniErrorAnalytics` object containing details about the error that will be logged in analytics.
     */
    static func errorAnalytics(from error: GiniError) -> GiniErrorAnalytics {
        switch error {
        case .badRequest(let response, _):
            return GiniErrorAnalytics(type: "bad_request", code: response?.statusCode, reason: error.message)
        case .notAcceptable(let response, _):
            return GiniErrorAnalytics(type: "not_acceptable", code: response?.statusCode, reason: error.message)
        case .notFound(let response, _):
            return GiniErrorAnalytics(type: "not_found", code: response?.statusCode, reason: error.message)
        case .noResponse:
            return GiniErrorAnalytics(type: "no_response", reason: error.message)
        case .parseError(_, let response, _):
            return GiniErrorAnalytics(type: "bad_request", code: response?.statusCode, reason: error.message)
        case .requestCancelled:
            return GiniErrorAnalytics(type: "request_cancelled", reason: error.message)
        case .tooManyRequests(let response, _):
            return GiniErrorAnalytics(type: "too_many_requests", code: response?.statusCode, reason: error.message)
        case .unauthorized(let response, _):
            return GiniErrorAnalytics(type: "unauthorized", code: response?.statusCode, reason: error.message)
        case .maintenance(let errorCode):
            return GiniErrorAnalytics(type: "maintenance", code: errorCode, reason: error.message)
        case .outage(let errorCode):
            return GiniErrorAnalytics(type: "outage", code: errorCode, reason: error.message)
        case .server(let errorCode):
            return GiniErrorAnalytics(type: "server", code: errorCode, reason: error.message)
        case .unknown(let response, _):
            return GiniErrorAnalytics(type: "unknown", code: response?.statusCode, reason: error.message)
        case .clientSide(let response, _):
            return GiniErrorAnalytics(type: "client side error", code: response?.statusCode, reason: error.message)
        case .noInternetConnection:
            return GiniErrorAnalytics(type: "no_internet")
        }
    }
}
