//
//  AnalyticsMapper.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import GiniBankAPILibrary

class AnalyticsMapper {

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

    static func errorAnalytics(from error: GiniError) -> ErrorAnalytics {
        switch error {
        case .badRequest(let response, _):
            return ErrorAnalytics(type: "bad_request", code: response?.statusCode, reason: error.message)
        case .notAcceptable(let response, _):
            return ErrorAnalytics(type: "not_acceptable", code: response?.statusCode, reason: error.message)
        case .notFound(let response, _):
            return ErrorAnalytics(type: "not_found", code: response?.statusCode, reason: error.message)
        case .noResponse:
            return ErrorAnalytics(type: "no_reponse", reason: error.message)
        case .parseError(_, let response, _):
            return ErrorAnalytics(type: "bad_request", code: response?.statusCode, reason: error.message)
        case .requestCancelled:
            return ErrorAnalytics(type: "request_cancelled", reason: error.message)
        case .tooManyRequests(let response, _):
            return ErrorAnalytics(type: "too_many_requests", code: response?.statusCode, reason: error.message)
        case .unauthorized(let response, _):
            return ErrorAnalytics(type: "unauthorized", code: response?.statusCode, reason: error.message)
        case .maintenance(let errorCode):
            return ErrorAnalytics(type: "maintenance", code: errorCode, reason: error.message)
        case .outage(let errorCode):
            return ErrorAnalytics(type: "outage", code: errorCode, reason: error.message)
        case .server(let errorCode):
            return ErrorAnalytics(type: "server", code: errorCode, reason: error.message)
        case .unknown(let response, _):
            return ErrorAnalytics(type: "unknown", code: response?.statusCode, reason: error.message)
        case .noInternetConnection:
            return ErrorAnalytics(type: "no_internet")
        }
    }
}
