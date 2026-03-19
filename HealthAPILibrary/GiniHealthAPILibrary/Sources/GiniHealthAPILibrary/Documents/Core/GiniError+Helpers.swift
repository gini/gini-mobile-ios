//
//  GiniError+Helpers.swift
//  GiniHealthAPILibrary
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

// MARK: - Convenience Helpers for API v5 Error Handling

public extension GiniError {
    /**
     Formatted description of all error items for logging or display.

     Returns a human-readable string with all error codes and their associated objects.
     This property formats all error items into a concise, readable string suitable for display
     in UI alerts or logging. Each error code is shown with its associated object IDs.

     Example output: `"2013: [doc-id-1, doc-id-2]; 2014: [doc-id-3]"`

     - Returns: A formatted string describing all error items, or "No specific error details" if none exist
     */
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
    
    /**
     Returns all object IDs (e.g., document IDs) that failed with the specified error code.

     Use this method to extract document IDs or other object identifiers for a specific error code.
     If multiple error items share the same code, all their objects are merged into a single array.

     - parameter code: The error code to filter by (e.g., "2013" for unauthorized, "2014" for not found)
     - Returns: Array of object IDs associated with that error code, or empty array if none found

     Example:
     ```swift
     let unauthorizedDocs = error.objectsWithCode("2013")
     if !unauthorizedDocs.isEmpty {
         print("Unauthorized documents: \(unauthorizedDocs.joined(separator: ", "))")
     }
     ```
     */
    func objectsWithCode(_ code: String) -> [String] {
        guard let items = items else { return [] }
        return items
            .filter { $0.code == code }
            .compactMap { $0.object }
            .flatMap { $0 }
    }
    
    /**
     Comprehensive error summary including status code, request ID, message, and all error items.

     This property provides a complete error description ideal for detailed logging and debugging.
     It combines all error information into a multi-line formatted string.

     Example output:
     ```
     Status: 400 | Request ID: a497-01aa-b6f0-cc17-43d3-76a8
     Message: Bad request
     Items: 2013: [doc-id-1, doc-id-2]
     ```

     - Returns: A multi-line string with complete error details
     */
    var detailedDescription: String {
        """
        Status: \(statusCode ?? 0) | Request ID: \(requestId)
        Message: \(String(describing: message))
        Items: \(itemsDescription)
        """
    }
}
