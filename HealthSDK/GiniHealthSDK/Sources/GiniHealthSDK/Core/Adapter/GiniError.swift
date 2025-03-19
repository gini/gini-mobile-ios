//
//  GiniError.swift
//  GiniHealthSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import GiniHealthAPILibrary

public protocol GiniErrorProtocol {
    var message: String { get }
    var response: HTTPURLResponse? { get }
    var data: Data? { get }
}

/// An enumeration representing errors that can occur when interacting with the Gini API.
public enum GiniError: Error, GiniErrorProtocol, GiniCustomErrorProtocol, Equatable {
    case decorator(GiniHealthAPILibrary.GiniError)

    public var message: String {
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

    public var unauthorizedItems: [String]? {
        switch self {
        case .decorator(let giniError):
            return giniError.unauthorizedItems
        }
    }

    public var notFoundItems: [String]? {
        switch self {
        case .decorator(let giniError):
            return giniError.notFoundItems
        }
    }

    public var missingCompositeDocuments: [String]? {
        switch self {
        case .decorator(let giniError):
            return giniError.missingCompositeDocuments
        }
    }
}
