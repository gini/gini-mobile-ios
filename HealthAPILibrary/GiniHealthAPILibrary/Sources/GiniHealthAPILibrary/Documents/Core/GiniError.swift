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
    var statusCode: Int? { get }
    var items: [ErrorItem]? { get }
    var requestId: String { get }
}

/**
 A protocol representing custom errors that may occur when interacting with the Gini Health API.

 This protocol defines three properties:
 - `unauthorizedItems`: An array of items that could not be deleted due to insufficient permissions.
 - `notFoundItems`: An array of items that were not found during a bulk deletion attempt.
 - `missingCompositeDocuments`: An array of composite documents that are missing when attempting to perform a bulk deletion.
 */
@available(*, deprecated, message: "Conforming to this protocol will not have any effect and will be removed in a next release. Use `items` for the specific errors instead")
public protocol GiniCustomErrorProtocol {
    var unauthorizedItems: [String]? { get }
    var notFoundItems: [String]? { get }
    var missingCompositeItems: [String]? { get }
}

public struct ErrorItem: Codable, Equatable {
    public var code: String
    public var message: String?
    public var object: [String]?

    enum CodingKeys: String, CodingKey {
        case code
        case message
        case object
    }

    public init(code: String = "", message: String = "", object: [String]? = nil) {
        self.code = code
        self.message = message
        self.object = object
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try container.decodeIfPresent(String.self, forKey: .code) ?? ""
        self.message = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
        self.object = try container.decodeIfPresent([String].self, forKey: .object)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(code, forKey: .code)
        try container.encode(message, forKey: .message)
        try container.encode(object, forKey: .object)
    }
}

struct GiniCustomError: Codable {
    var message: String
    var items: [ErrorItem]?
    var requestId: String
    @available(*, deprecated, message: "This property will not return values and will be removed in a next release. Use `items` for the specific errors instead")
    var unauthorizedItems: [String]?
    @available(*, deprecated, message: "This property will not return values and will be removed in a next release. Use `items` for the specific errors instead")
    var notFoundItems: [String]?
    @available(*, deprecated, message: "This property will not return values and will be removed in a next release. Use `items` for the specific errors instead")
    var missingCompositeItems: [String]?
    
    enum CodingKeys: CodingKey {
        case message
        case items
        case requestId
        case unauthorizedItems
        case notFoundItems
        case missingCompositeItems
        //backend values
        case unauthorizedPaymentRequests
        case notFoundPaymentRequests
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        message = try container.decodeIfPresent(String.self, forKey: .message) ?? "No message available"

        items = try container.decodeIfPresent([ErrorItem].self, forKey: .items)

        requestId = try container.decodeIfPresent(String.self, forKey: .requestId) ?? "No requestId available"
    }
    
    init(message: String, items: [ErrorItem]? = nil, requestId: String) {
        self.message = message
        self.items = items
        self.requestId = requestId
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(items, forKey: .items)
        try container.encodeIfPresent(requestId, forKey: .requestId)
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
        default:
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
             .customError(let response, _),
             .unknown(let response, _):
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
             .customError(_, let data),
             .unknown(_, let data):
            return data
        default:
            return nil
        }
    }

    public var statusCode: Int? {
        switch self {
            case .badRequest(let response, _),
                    .notAcceptable(let response, _),
                    .notFound(let response, _),
                    .parseError(_, let response, _),
                    .tooManyRequests(let response, _),
                    .unauthorized(let response, _),
                    .customError(let response, _),
                    .unknown(let response, _):
                return response?.statusCode
            default:
                return nil
        }
    }

    public var items: [ErrorItem]? {
        return customError?.items
    }

    public var requestId: String {
        return customError?.requestId ?? "no requestId is available"
    }

    var customError: GiniCustomError? {
        guard let data, let customErrorDecoded = try? JSONDecoder().decode(GiniCustomError.self, from: data) else {
            return nil
        }
        return customErrorDecoded
    }

    @available(*, deprecated, message: "This property will not return values and will be removed in a next release. Use `items` for the specific errors instead")
    public var unauthorizedItems: [String]? {
        // API v5 doesn't return this field - customers must use `items` array
        return nil
    }

    @available(*, deprecated, message: "This property will not return values and will be removed in a next release. Use `items` for the specific errors instead")
    public var notFoundItems: [String]? {
        // API v5 doesn't return this field - customers must use `items` array
        return nil
    }

    @available(*, deprecated, message: "This property will not return values and will be removed in a next release. Use `items` for the specific errors instead")
    public var missingCompositeItems: [String]? {
        // API v5 doesn't return this field - customers must use `items` array
        return nil
    }

    /// Helper Function to Get Custom Document / PaymentRequest Errors Message
    @available(*, deprecated, message: "This method will not return values and will be removed in a next release. Use `items` for the specific errors instead")
    private func getCustomErrorMessage() -> String? {
        // Deprecated - returns nil since API v5 uses items array
        return nil
    }
}

// MARK: - Convenience Helpers for API v5 Error Handling

public extension GiniError {
    /// Formatted description of all error items for logging or display.
    ///
    /// Returns a human-readable string with all error codes and their associated objects.
    ///
    /// Example output: `"2013: [doc-id-1, doc-id-2]; 2014: [doc-id-3]"`
    var itemsDescription: String {
        guard let items = items, !items.isEmpty else {
            return "No specific error details"
        }
        
        return items
            .map { item in
                let objects = item.object?.joined(separator: ", ") ?? "no objects"
                return "\(item.code): [\(objects)]"
            }
            .joined(separator: "; ")
    }
    
    /// Returns all object IDs (e.g., document IDs) that failed with the specified error code.
    ///
    /// - Parameter code: The error code to filter by (e.g., "2013" for unauthorized)
    /// - Returns: Array of object IDs associated with that error code, or empty array if none found
    ///
    /// Example:
    /// ```swift
    /// let unauthorizedDocs = error.objectsWithCode("2013")
    /// print("Unauthorized documents: \(unauthorizedDocs)")
    /// ```
    func objectsWithCode(_ code: String) -> [String] {
        guard let items = items else { return [] }
        return items
            .filter { $0.code == code }
            .compactMap { $0.object }
            .flatMap { $0 }
    }
    
    /// Comprehensive error summary including status code, request ID, message, and all error items.
    ///
    /// This property is ideal for detailed logging and debugging.
    ///
    /// Example output:
    /// ```
    /// Status: 400 | Request ID: a497-01aa-b6f0-cc17-43d3-76a8
    /// Message: Bad request
    /// Items: 2013: [doc-id-1, doc-id-2]
    /// ```
    var detailedDescription: String {
        """
        Status: \(statusCode ?? 0) | Request ID: \(requestId)
        Message: \(message)
        Items: \(itemsDescription)
        """
    }
}


