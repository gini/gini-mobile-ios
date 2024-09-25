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

public enum GiniError: Error, GiniErrorProtocol, Equatable {
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
}
