//
//  GiniError.swift
//  GiniHealthSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import GiniHealthAPILibrary

/**
 A protocol representing errors that may occur when interacting with the Gini Health SDK.
 */
public protocol GiniErrorProtocol {
    /** A descriptive message explaining the error. */
    var message: String? { get }
    /** The HTTP response associated with the error, if available. */
    var response: HTTPURLResponse? { get }
    /** The raw response data received from the server, if any. */
    var data: Data? { get }
    /** The HTTP status code from the error response, if available. */
    var statusCode: Int? { get }
    /** Array of structured error items from the API response, if any. */
    var items: [ErrorItem]? { get }
    /** The request ID from the API response, useful for debugging and support. */
    var requestId: String { get }
}

/**
 A concrete error type representing errors that can occur when interacting with the Gini Health SDK.
 */
public struct GiniError: Error, GiniErrorProtocol, Equatable {
    /** A descriptive message explaining the error. */
    public var message: String?
    /** The HTTP response associated with the error, if available. */
    public var response: HTTPURLResponse?
    /** The raw response data received from the server, if any. */
    public var data: Data?
    /** The HTTP status code from the error response, if available. */
    public var statusCode: Int?
    /** Array of structured error items from the API response, if any. */
    public var items: [ErrorItem]?
    /** The request ID from the API response, useful for debugging and support. */
    public var requestId: String
    
    /**
     Converts a `GiniHealthAPILibrary.GiniError` to a `GiniHealthSDK.GiniError`.

     - Parameter error: The `GiniHealthAPILibrary.GiniError` to convert.
     - Returns: A `GiniHealthSDK.GiniError` with equivalent error information.
     */
    static func toGiniHealthSDKError(error: GiniHealthAPILibrary.GiniError) -> GiniError {
        let healthSDKError = GiniError(message: error.message,
                                       response: error.response,
                                       data: error.data,
                                       statusCode: error.statusCode,
                                       items: error.items,
                                       requestId: error.requestId)
        return healthSDKError
    }
}

