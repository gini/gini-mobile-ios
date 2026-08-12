//
//  MockBulkDeleteValidator.swift
//  GiniHealthSDKTests
//
//  Validates bulk delete requests and generates appropriate error responses
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
@testable import GiniHealthAPILibrary

/**
 Validates bulk delete operations and generates error items
 */
struct MockBulkDeleteValidator {
    
    enum ValidationResult {
        case success
        case failure([ErrorItem])
    }
    
    // MARK: - Document Validation

    /** Validate document IDs for bulk deletion

    - Parameters:
       - documentIDs: Array of document IDs to validate
    - Returns: Validation result with error items if validation fails
     */
    func validateDocuments(_ documentIDs: [String]) -> ValidationResult {
        var errorItems: [ErrorItem] = []
        
        // Check for unauthorized documents
        let unauthorized = documentIDs.filter {
            MockTestData.BulkDeleteDocuments.unauthorized.contains($0)
        }
        if !unauthorized.isEmpty {
            errorItems.append(ErrorItem(
                code: MockTestData.ErrorCodes.unauthorized,
                object: unauthorized
            ))
        }
        
        // Check for not found documents
        let notFound = documentIDs.filter {
            MockTestData.BulkDeleteDocuments.notFound.contains($0)
        }
        if !notFound.isEmpty {
            errorItems.append(ErrorItem(
                code: MockTestData.ErrorCodes.notFound,
                object: notFound
            ))
        }
        
        // Check for missing composite documents
        let missingComposite = documentIDs.filter {
            MockTestData.BulkDeleteDocuments.missingComposite.contains($0)
        }
        if !missingComposite.isEmpty {
            errorItems.append(ErrorItem(
                code: MockTestData.ErrorCodes.missingComposite,
                object: missingComposite
            ))
        }
        
        return errorItems.isEmpty ? .success : .failure(errorItems)
    }
    
    // MARK: - Payment Request Validation
    
    /**
     Validate payment request IDs for bulk deletion

    - Parameters:
       - paymentRequestIDs: Array of payment request IDs to validate
    - Returns: Validation result with error items if validation fails
     */
    func validatePaymentRequests(_ paymentRequestIDs: [String]) -> ValidationResult {
        var errorItems: [ErrorItem] = []
        
        // Check for unauthorized payment requests
        let unauthorized = paymentRequestIDs.filter {
            MockTestData.BulkDeletePaymentRequests.unauthorized.contains($0)
        }
        if !unauthorized.isEmpty {
            errorItems.append(ErrorItem(
                code: MockTestData.PaymentRequestErrorCodes.unauthorized,
                object: unauthorized
            ))
        }
        
        // Check for not found payment requests
        let notFound = paymentRequestIDs.filter {
            MockTestData.BulkDeletePaymentRequests.notFound.contains($0)
        }
        if !notFound.isEmpty {
            errorItems.append(ErrorItem(
                code: MockTestData.PaymentRequestErrorCodes.notFound,
                object: notFound
            ))
        }
        
        return errorItems.isEmpty ? .success : .failure(errorItems)
    }
}
