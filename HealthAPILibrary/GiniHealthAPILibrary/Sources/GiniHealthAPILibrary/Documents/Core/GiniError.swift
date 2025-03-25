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
 A protocol representing custom errors that may occur when interacting with the Gini Health API.

 This protocol defines three properties:
 - `unauthorizedItems`: An array of items that could not be deleted due to insufficient permissions.
 - `notFoundItems`: An array of items that were not found during a bulk deletion attempt.
 - `missingCompositeDocuments`: An array of composite documents that are missing when attempting to perform a bulk deletion.
 */

public protocol GiniCustomErrorProtocol {
    var unauthorizedItems: [String]? { get }
    var notFoundItems: [String]? { get }
    var missingCompositeItems: [String]? { get }
}

struct GiniCustomError: GiniCustomErrorProtocol, Codable {
    var message: String?
    var unauthorizedItems: [String]?
    var notFoundItems: [String]?
    var missingCompositeItems: [String]?
    
    enum CodingKeys: CodingKey {
        case message
        case unauthorizedItems
        case notFoundItems
        case missingCompositeItems
        
        //backend values
        case unauthorizedPaymentRequests
        case notFoundPaymentRequests
        case unauthorizedDocuments
        case notFoundDocuments
        case missingCompositeDocuments
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        message = try? container.decodeIfPresent(String.self, forKey: .message)
        
        if let items = try? container.decodeIfPresent([String].self, forKey: .missingCompositeDocuments) {
            missingCompositeItems = items
        } else {
            missingCompositeItems = try? container.decodeIfPresent([String].self, forKey: .missingCompositeItems)
        }
        
        if let items = try? container.decodeIfPresent([String].self, forKey: .unauthorizedPaymentRequests) {
            unauthorizedItems = items
        } else if let items = try? container.decodeIfPresent([String].self, forKey: .unauthorizedDocuments) {
            unauthorizedItems = items
        } else {
            unauthorizedItems = try? container.decodeIfPresent([String].self, forKey: .unauthorizedItems)
        }
        
        if let items = try? container.decodeIfPresent([String].self, forKey: .notFoundPaymentRequests) {
            notFoundItems = items
        } else if let items = try? container.decodeIfPresent([String].self, forKey: .notFoundDocuments) {
            notFoundItems = items
        } else {
            notFoundItems = try? container.decodeIfPresent([String].self, forKey: .notFoundItems)
        }
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(missingCompositeItems, forKey: .missingCompositeItems)
        try container.encodeIfPresent(unauthorizedItems, forKey: .unauthorizedItems)
        try container.encodeIfPresent(notFoundItems, forKey: .notFoundItems)
    }
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

    public var unauthorizedItems: [String]? {
        return customError?.unauthorizedItems
    }

    public var notFoundItems: [String]? {
        return customError?.notFoundItems
    }
    
    public var missingCompositeItems: [String]? {
        return customError?.missingCompositeItems
    }
    
    @available(*, deprecated, message: "This property will be removed in a future release", renamed: "unauthorizedItems")
    public var unauthorizedDocuments: [String]? {
        return customError?.unauthorizedItems
    }
    
    @available(*, deprecated, message: "This property will be removed in a future release", renamed: "notFoundItems")
    public var notFoundDocuments: [String]? {
        return customError?.notFoundItems
    }
    
    @available(*, deprecated, message: "This property will be removed in a future release", renamed: "missingCompositeItems")
    public var missingCompositeDocuments: [String]? {
        return customError?.missingCompositeItems
    }

    /// Helper Function to Get Custom Document / PaymentRequest Errors Message
    private func getCustomErrorMessage() -> String? {
        if let unauthorizedItems = customError?.unauthorizedItems {
            return "Unauthorized items: \(unauthorizedItems.joined(separator: ", "))"
        } else if let notFoundItems = customError?.notFoundItems {
            return "Not found items: \(notFoundItems.joined(separator: ", "))"
        } else if let missingCompositeDocuments = customError?.missingCompositeItems {
            return "Missing composite items: \(missingCompositeDocuments.joined(separator: ", "))"
        }
        
        return nil
    }
}
