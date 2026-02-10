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
    //TODO

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

    @available(*, deprecated, message: "This property will be removed in a next release. Use items instead")
    public var unauthorizedItems: [String]? {
        switch self {
        case .decorator(let giniError):
            return giniError.unauthorizedItems
        }
    }

    @available(*, deprecated, message: "This property will be removed in a next release. Use items instead")
    public var notFoundItems: [String]? {
        switch self {
        case .decorator(let giniError):
            return giniError.notFoundItems
        }
    }

    @available(*, deprecated, message: "This property will be removed in a next release. Use items instead")
    public var missingCompositeItems: [String]? {
        switch self {
        case .decorator(let giniError):
            return giniError.missingCompositeItems
        }
    }
    
    @available(*, deprecated, message: "This property will be removed in a future release", renamed: "unauthorizedItems")
    public var unauthorizedDocuments: [String]? {
        switch self {
        case .decorator(let giniError):
            return giniError.unauthorizedItems
        }
    }
    
    @available(*, deprecated, message: "This property will be removed in a future release", renamed: "notFoundItems")
    public var notFoundDocuments: [String]? {
        switch self {
        case .decorator(let giniError):
            return giniError.notFoundItems
        }
    }
    
    @available(*, deprecated, message: "This property will be removed in a future release", renamed: "missingCompositeItems")
    public var missingCompositeDocuments: [String]? {
        switch self {
        case .decorator(let giniError):
            return giniError.missingCompositeItems
        }
    }
}
