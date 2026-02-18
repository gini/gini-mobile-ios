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
    var statusCode: Int? { get }
    var items: [ErrorItem]? { get }
    var requestId: String { get }
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

    @available(*, deprecated, message: "This property will not return values and will be removed in a next release. Use `items` for the specific errors instead")
    public var unauthorizedItems: [String]? {
        switch self {
        case .decorator(let giniError):
            return giniError.unauthorizedItems
        }
    }

    @available(*, deprecated, message: "This property will not return values and will be removed in a next release. Use `items` for the specific errors instead")
    public var notFoundItems: [String]? {
        switch self {
        case .decorator(let giniError):
            return giniError.notFoundItems
        }
    }

    @available(*, deprecated, message: "This property will not return values and will be removed in a next release. Use `items` for the specific errors instead")
    public var missingCompositeItems: [String]? {
        switch self {
        case .decorator(let giniError):
            return giniError.missingCompositeItems
        }
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

