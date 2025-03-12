//
//  GiniError.swift
//  GiniHealthAPI
//
//  Created by Enrique del Pozo Gómez on 1/24/18.
//

import Foundation

/**
 A protocol representing errors that may occur when interacting with the Gini API.

 This protocol defines three properties:
 - `message`: A descriptive message explaining the error.
 - `response`: The associated `HTTPURLResponse`, if available.
 - `data`: The response data received, if any.
 */

public protocol GiniErrorProtocol {
    var message: String { get }
    var response: HTTPURLResponse? { get }
    var data: Data? { get }
}

/**
 A protocol representing custom errors that may occur when interacting with the Gini API.

 This protocol defines three properties:
 - `unauthorizedDocuments`: An array of documents that could not be deleted due to insufficient permissions.  
 - `notFoundDocuments`: An array of documents that were not found during a bulk deletion attempt.
 - `missingCompositeDocuments`: An array of composite documents that are missing when attempting to perform a bulk deletion.
 */

public protocol GiniCustomErrorProtocol {
    var unauthorizedDocuments: [String]? { get }
    var notFoundDocuments: [String]? { get }
    var missingCompositeDocuments: [String]? { get }
}

struct GiniCustomError: GiniCustomErrorProtocol, Codable {
    var message: String?
    var unauthorizedDocuments: [String]?
    var notFoundDocuments: [String]?
    var missingCompositeDocuments: [String]?
}

public enum GiniError: Error, GiniErrorProtocol, GiniCustomErrorProtocol, Equatable {
    case badRequest(response: HTTPURLResponse? = nil, data: Data? = nil)
    case notAcceptable(response: HTTPURLResponse? = nil, data: Data? = nil)
    case notFound(response: HTTPURLResponse? = nil, data: Data? = nil)
    case noResponse
    case parseError(message: String, response: HTTPURLResponse? = nil, data: Data? = nil)
    case requestCancelled
    case tooManyRequests(response: HTTPURLResponse? = nil, data: Data? = nil)
    case unauthorized(response: HTTPURLResponse? = nil, data: Data? = nil)
    case customError(response: HTTPURLResponse? = nil, data: Data? = nil)
    case unknown(response: HTTPURLResponse? = nil, data: Data? = nil)

    public var message: String {
        switch self {
        case .badRequest:
            return "Bad request"
        case .notAcceptable:
            return "Not acceptable"
        case .notFound:
            return "Not found"
        case .noResponse:
            return "No response"
        case .parseError(let message, _, _):
            return message
        case .requestCancelled:
            return "Request cancelled"
        case .tooManyRequests:
            return "Too many requests"
        case .unauthorized:
            return "Unauthorized"
        case .unknown:
            return "Unknown"
        case .customError(_, _):
            if let message = customError?.message {
                return message
            }
            return getCustomErrorMessage() ?? localizedDescription
        }
    }

    public var response: HTTPURLResponse? {
        switch self {
        case .badRequest(let response, _),
             .notAcceptable(let response, _),
             .notFound(let response, _),
             .parseError(_, let response, _),
             .tooManyRequests(let response, _),
             .unauthorized(let response, _),
             .unknown(let response, _),
             .customError(let response, _):
            return response
        default:
            return nil
        }
    }

    public var data: Data? {
        switch self {
        case .badRequest(_, let data),
             .notAcceptable(_, let data),
             .notFound(_, let data),
             .parseError(_, _, let data),
             .tooManyRequests(_, let data),
             .unauthorized(_, let data),
             .unknown(_, let data),
             .customError(_, let data):
            return data
        default:
            return nil
        }
    }

    var customError: GiniCustomError? {
        guard let data, let customErrorDecoded = try? JSONDecoder().decode(GiniCustomError.self, from: data) else {
            return nil
        }
        return customErrorDecoded
    }

    public var unauthorizedDocuments: [String]? {
        return customError?.unauthorizedDocuments
    }

    public var notFoundDocuments: [String]? {
        return customError?.notFoundDocuments
    }

    public var missingCompositeDocuments: [String]? {
        return customError?.missingCompositeDocuments
    }

    /// Helper Function to Get Custom Document Errors Message
    private func getCustomErrorMessage() -> String? {
        if let unauthorizedDocuments = customError?.unauthorizedDocuments {
            return "Unauthorized documents: \(unauthorizedDocuments.joined(separator: ", "))"
        } else if let notFoundDocuments = customError?.notFoundDocuments {
            return "Not found documents: \(notFoundDocuments.joined(separator: ", "))"
        } else if let missingCompositeDocuments = customError?.missingCompositeDocuments {
            return "Missing composite documents: \(missingCompositeDocuments.joined(separator: ", "))"
        }
        return nil
    }
}
