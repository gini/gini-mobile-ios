//
//  MockErrorGenerator.swift
//  GiniHealthSDKTests
//
//  Utility for creating mock error responses
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
@testable import GiniHealthAPILibrary

/// Generates mock error response data for testing
enum MockErrorGenerator {
    
    /**
     Create a custom error response with error items, message, and request ID. This can be used to simulate API error responses in tests.
     - Parameters:
        - items: Array of error items
        - message: Optional error message
        - requestId: Optional request ID
     - Returns: Encoded error data
     */
    static func createErrorData(items: [ErrorItem],
                                message: String = "Bad request",
                                requestId: String = "test-request-id") -> Data {
        let errorResponse: [String: Any] = [
            "message": message,
            "items": items.map { item in
                var dict: [String: Any] = ["code": item.code]
                if let message = item.message {
                    dict["message"] = message
                }
                if let object = item.object {
                    dict["object"] = object
                }
                return dict
            },
            "requestId": requestId
        ]
        
        guard let data = try? JSONSerialization.data(withJSONObject: errorResponse) else {
            return Data() // Return empty data to let tests fail with proper assertions
        }
        return data
    }
}
