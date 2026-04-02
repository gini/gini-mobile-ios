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


/**
 Represents a single error item from the API error response.
 Each error item contains an error code, optional message, and optional list of affected objects (e.g., document IDs).
 */
public struct ErrorItem: Codable, Equatable, Sendable {
    /**
     The error code identifying the type of error (e.g., "2013" for unauthorized, "2014" for not found).
     */
    public var code: String

    /**
     Optional human-readable error message describing the error.
     */
    public var message: String?

    /**
     Optional array of object identifiers (e.g., document IDs) that are affected by this error.
     */
    public var object: [String]?

    enum CodingKeys: String, CodingKey {
        case code
        case message
        case object
    }

    /**
     Creates a new error item.

     - Parameters:
       - code: The error code identifying the type of error
       - message: Optional human-readable error message
       - object: Optional array of affected object identifiers
     */
    public init(code: String = "", message: String? = nil, object: [String]? = nil) {
        self.code = code
        self.message = message
        self.object = object
    }

    /**
     Creates an error item by decoding from the given decoder.
     - Parameter decoder: The decoder to read data from.
     */
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try container.decodeIfPresent(String.self, forKey: .code) ?? ""
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        self.object = try container.decodeIfPresent([String].self, forKey: .object)
    }

    /**
     Encodes this error item into the given encoder.
     - Parameter encoder: The encoder to write data to.
     */
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

/**
 Errors returned by the Gini Health API.
 */
public enum GiniError: Error, GiniErrorProtocol, Equatable {
    /** The request was malformed or contained invalid parameters. */
    case badRequest(response: HTTPURLResponse? = nil, data: Data? = nil)
    /** The server cannot produce a response matching the accepted content type. */
    case notAcceptable(response: HTTPURLResponse? = nil, data: Data? = nil)
    /** The requested resource could not be found. */
    case notFound(response: HTTPURLResponse? = nil, data: Data? = nil)
    /** No response was received from the server. */
    case noResponse
    /** The response could not be parsed. Includes a descriptive message. */
    case parseError(message: String, response: HTTPURLResponse? = nil, data: Data? = nil)
    /** The request was cancelled before completion. */
    case requestCancelled
    /** The rate limit was exceeded. */
    case tooManyRequests(response: HTTPURLResponse? = nil, data: Data? = nil)
    /** The request was not authorized. */
    case unauthorized(response: HTTPURLResponse? = nil, data: Data? = nil)
    /** A structured API error was returned with a JSON body. Inspect `items` and `requestId` for details. */
    case customError(response: HTTPURLResponse? = nil, data: Data? = nil)
    /** An unexpected error occurred. */
    case unknown(response: HTTPURLResponse? = nil, data: Data? = nil)

    /**
     A descriptive message explaining the error.
     */
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

    /**
     The HTTP response associated with the error, if available.
     */
    public var response: HTTPURLResponse? {
        switch self {
        case .badRequest(let response, _), .notAcceptable(let response, _),
             .notFound(let response, _), .parseError(_, let response, _):
            return response
        case .tooManyRequests(let response, _), .unauthorized(let response, _),
             .customError(let response, _), .unknown(let response, _):
            return response
        default:
            return nil
        }
    }

    /**
     The raw response data received from the server, if any.
     */
    public var data: Data? {
        switch self {
        case .badRequest(_, let data), .notAcceptable(_, let data),
             .notFound(_, let data), .parseError(_, _, let data):
            return data
        case .tooManyRequests(_, let data), .unauthorized(_, let data),
             .customError(_, let data), .unknown(_, let data):
            return data
        default:
            return nil
        }
    }

    /**
     HTTP status code from the error response, if available.
     Returns `nil` if no response is available.
     */
    public var statusCode: Int? {
        switch self {
        case .badRequest(let response, _), .notAcceptable(let response, _),
             .notFound(let response, _), .parseError(_, let response, _):
            return response?.statusCode
        case .tooManyRequests(let response, _), .unauthorized(let response, _),
             .customError(let response, _), .unknown(let response, _):
            return response?.statusCode
        default:
            return nil
        }
    }

    /**
     Array of error items containing specific error details from the API.
     Each item includes an error code, optional message, and optional list of affected objects.
     */
    public var items: [ErrorItem]? {
        return customError?.items
    }

    /**
     The request ID from the API response, useful for debugging and support.
     This identifier can be used to trace the request in server logs.
     */
    public var requestId: String {
        return customError?.requestId ?? "no requestId is available"
    }

    var customError: GiniCustomError? {
        guard let data else { return nil }
        return try? JSONDecoder().decode(GiniCustomError.self, from: data)
    }
}

