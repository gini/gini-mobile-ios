//
//  GiniError.swift
//  GiniHealthSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import GiniHealthAPILibrary

public protocol GiniErrorProtocol {
    var message: String? { get }
    var response: HTTPURLResponse? { get }
    var data: Data? { get }
    var statusCode: Int? { get }
    var items: [ErrorItem]? { get }
    var requestId: String { get }
}

/**
 An enumeration representing errors that can occur when interacting with the Gini API.
 */
public struct GiniError: Error, GiniErrorProtocol, Equatable {
    public var message: String?
    public var response: HTTPURLResponse?
    public var data: Data?
    public var statusCode: Int?
    public var items: [ErrorItem]?
    public var requestId: String
    
    /// Converts a GiniHealthAPILibrary.GiniError to GiniHealthSDK.GiniError
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

