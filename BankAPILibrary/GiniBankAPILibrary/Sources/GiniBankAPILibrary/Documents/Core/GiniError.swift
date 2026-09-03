//
//  GiniError.swift
//  GiniBankAPI
//
//  Created by Enrique del Pozo Gómez on 1/24/18.
//

import Foundation

/**
 Protocol representing errors that can occur while interacting with the Gini API.

 The protocol defines three properties:
 - message: A message describing the error.
 - response: The HTTPURLResponse received in the error, if any.
 - data: The data received in the error, if any.
 */

public protocol GiniErrorProtocol {
    var message: String { get }
    var response: HTTPURLResponse? { get }
    var data: Data? { get }
}

/**
 Enum representing different types of errors that can occur while interacting with the Gini API.

 - badRequest: Error indicating that the request was invalid.
 - notAcceptable: Error indicating that the request was not acceptable.
 - notFound: Error indicating that the requested resource was not found.
 - noResponse: Error indicating that no response was received.
 - parseError: Error indicating that there was an error parsing the response.
 - requestCancelled: Error indicating that the request was cancelled.
 - tooManyRequests: Error indicating that too many requests have been made.
 - unauthorized: Error indicating that the request was unauthorized.
 - maintenance: Error indicating that the system is under maintenance.
 - outage: Error indicating that the service is unavailable due to outage.
 - server: Error indicating that the server is unavailable.
 - noInternetConnection: Error indicating that there is no internet connection.
 - clientSide: Error indicating a client-side error in the 4xx range (excluding specific cases like 404).
 - unknown: An unknown error occurred.
 */

public enum GiniError: Error, GiniErrorProtocol, Equatable {
    case badRequest(response: HTTPURLResponse? = nil, data: Data? = nil)
    case notAcceptable(response: HTTPURLResponse? = nil, data: Data? = nil)
    case notFound(response: HTTPURLResponse? = nil, data: Data? = nil)
    case noResponse
    case parseError(message: String, response: HTTPURLResponse? = nil, data: Data? = nil)
    case requestCancelled
    case tooManyRequests(response: HTTPURLResponse? = nil, data: Data? = nil)
    case unauthorized(response: HTTPURLResponse? = nil, data: Data? = nil)
    case maintenance(errorCode: Int)
    case outage(errorCode: Int)
    case server(errorCode: Int)
    case noInternetConnection
    case clientSide(response: HTTPURLResponse? = nil, data: Data? = nil)
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
        case .maintenance:
            return "Maintenance is in progress"
        case .outage:
            return "Service is unavailable"
        case .server:
            return "An unexpected server error occurred"
        case .noInternetConnection:
            return "No internet connection"
        case .clientSide:
            return "Client side errors between 402 and 498 except 404"
        case .unknown:
            return "Unknown"
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
             .unknown(_, let data):
            return data
        default:
            return nil
        }
    }
}

public extension GiniError {
    static func from(statusCode: Int,
                     response: HTTPURLResponse?,
                     data: Data?) -> GiniError {
        switch statusCode {
            case 401:
                return .unauthorized(response: response, data: data)
            case 500...599:
                return handleServerError(statusCode: statusCode)
            case 400...499:
                return handleClientError(statusCode: statusCode, response: response, data: data)
            default:
                return .unknown(response: response, data: data)
        }
    }

    private static func handleServerError(statusCode: Int) -> GiniError {
        switch statusCode {
            case 500:
                return .outage(errorCode: statusCode)
            case 503:
                return .maintenance(errorCode: statusCode)
            case 501, 502, 504...599:
                return .server(errorCode: statusCode)
            default:
                return .unknown(response: nil, data: nil)
        }
    }

    private static func handleClientError(statusCode: Int,
                                          response: HTTPURLResponse?,
                                          data: Data?) -> GiniError {
        switch statusCode {
            case 400:
                return handleBadRequest(response: response, data: data)
            case 404:
                return .notFound(response: response, data: data)
            case 406:
                return .notAcceptable(response: response, data: data)
            case 429:
                return .tooManyRequests(response: response, data: data)
            case 402...498:
                return .clientSide(response: response, data: data)
            default:
                return .unknown(response: response, data: data)
        }
    }

    private static func handleBadRequest(response: HTTPURLResponse?, data: Data?) -> GiniError {
        guard let data = data else {
            return .badRequest(response: response, data: nil)
        }

        if let errorInfo = try? JSONDecoder().decode([String: String].self, from: data),
           errorInfo["error"] == "invalid_grant" {
            return .unauthorized(response: response, data: data)
        }

        return .badRequest(response: response, data: data)
    }
}
