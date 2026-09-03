//
//  GiniErrorAnalytics.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

/// Represents an error event for analytics, capturing its type, optional error code, and reason.
public struct GiniErrorAnalytics {
    public let type: String
    public let code: Int?
    public let reason: String?

    /// Initializes a GiniErrorAnalytics instance with the given error details.
    /// - Parameters:
    ///   - type: The category or identifier of the error.
    ///   - code: An optional numerical code representing the error.
    ///   - reason: An optional descriptive reason for the error.
    init(type: String, code: Int? = nil, reason: String? = nil) {
        self.type = type
        self.code = code
        self.reason = reason
    }
}
