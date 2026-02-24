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

/// An enumeration representing errors that can occur when interacting with the Gini API.
public enum GiniError: Error, GiniErrorProtocol, Equatable {

    case decorator(GiniHealthAPILibrary.GiniError)

    public var message: String? {
        switch self {
        case .decorator(let giniError):
            return giniError.message
        }
    }

    public var response: HTTPURLResponse? {
        switch self {
        case .decorator(let giniError):
            return giniError.response
        }
    }

    public var data: Data? {
        switch self {
        case .decorator(let giniError):
            return giniError.data
        }
    }

    public var statusCode: Int? {
        switch self {
        case .decorator(let giniError):
            return giniError.statusCode
        }
    }

    public var items: [ErrorItem]? {
        switch self {
        case .decorator(let giniError):
            return giniError.items
        }
    }

    public var requestId: String {
        switch self {
            case .decorator(let giniError):
                return giniError.requestId
        }
    }
}

