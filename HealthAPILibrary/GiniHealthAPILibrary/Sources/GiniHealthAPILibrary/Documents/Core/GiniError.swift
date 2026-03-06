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
    var message: String? { get }
    var response: HTTPURLResponse? { get }
    var data: Data? { get }
    var statusCode: Int? { get }
    var items: [ErrorItem]? { get }
    var requestId: String { get }
}


/// Represents a single error item from the API error response.
///
/// Each error item contains an error code, optional message, and optional list of affected objects (e.g., document IDs).
public struct ErrorItem: Codable, Equatable, Sendable {
    /// The error code identifying the type of error (e.g., "2013" for unauthorized, "2014" for not found).
    public var code: String
    
    /// Optional human-readable error message describing the error.
    public var message: String?
    
    /// Optional array of object identifiers (e.g., document IDs) that are affected by this error.
    public var object: [String]?

    enum CodingKeys: String, CodingKey {
        case code
        case message
        case object
    }

    /// Creates a new error item.
    /// - Parameters:
    ///   - code: The error code identifying the type of error
    ///   - message: Optional human-readable error message
    ///   - object: Optional array of affected object identifiers
    public init(code: String = "", message: String? = nil, object: [String]? = nil) {
        self.code = code
        self.message = message
        self.object = object
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try container.decodeIfPresent(String.self, forKey: .code) ?? ""
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
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
    var message: String?
    var items: [ErrorItem]?
    var requestId: String
    
    enum CodingKeys: CodingKey {
        case message
        case items
        case requestId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        message = try container.decodeIfPresent(String.self, forKey: .message)

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

public enum GiniError: Error, GiniErrorProtocol, Equatable {
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

    public var message: String? {
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
        case .customError:
            return customError?.message ?? localizedDescription
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

    /// HTTP status code from the error response, if available.
    ///
    /// Returns the status code from the HTTP response, or `nil` if no response is available.
    /// - Returns: The HTTP status code (e.g., 400, 401, 404) or `nil`
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

    /// Array of error items containing specific error details from the API.
    ///
    /// Each item includes an error code, optional message, and optional list of affected objects.
    /// Use this property to identify which specific documents or objects failed and why.
    ///
    /// Example:
    /// ```swift
    /// if let items = error.items {
    ///     for item in items {
    ///         print("Error \(item.code): \(item.object?.joined(separator: ", ") ?? "no objects")")
    ///     }
    /// }
    /// ```
    /// - Returns: Array of `ErrorItem` objects, or `nil` if no items are available
    public var items: [ErrorItem]? {
        return customError?.items
    }

    /// The request ID from the API response, useful for debugging and support.
    ///
    /// This identifier can be used to trace the request in server logs.
    /// - Returns: The request ID string, or a default message if not available
    public var requestId: String {
        return customError?.requestId ?? "no requestId is available"
    }

    var customError: GiniCustomError? {
        guard let data else { return nil }
        return try? JSONDecoder().decode(GiniCustomError.self, from: data)
    }
}

