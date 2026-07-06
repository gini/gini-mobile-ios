//
//  MockTestData.swift
//  GiniHealthSDKTests
//
//  Centralized test data constants for MockSessionManager
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

/// Centralized test data constants used across mock responses
enum MockTestData {
    
    // MARK: - Document IDs
    
    enum Documents {
        static let payable = "626626a0-749f-11e2-bfd6-000000000001"
        static let notPayable = "626626a0-749f-11e2-bfd6-000000000002"
        static let failurePayable = "626626a0-749f-11e2-bfd6-000000000003"
        static let missing = "626626a0-749f-11e2-bfd6-000000000000"
        static let extractionsWithPayment = "626626a0-749f-11e2-bfd6-000000000004"
        static let doctorsName = "626626a0-749f-11e2-bfd6-000000000005"
    }
    
    // MARK: - Bulk Delete Documents
    
    enum BulkDeleteDocuments {
        static let notFound = [
            "3db07630-8f16-11ec-bd63-31f9d04e200e",
            "0db26fec-4a7f-4376-b5d5-5155adf8adca"
        ]
        
        static let unauthorized = [
            "3db07630-8f16-11ec-bd63-31f9d04e200e",
            "0db26fec-4a7f-4376-b5d5-5155adf8adca"
        ]
        
        static let missingComposite = [
            "3db07630-8f16-11ec-bd63-31f9d04e200e",
            "0db26fec-4a7f-4376-b5d5-5155adf8adca"
        ]
    }
    
    // MARK: - Payment Requests
    
    enum PaymentRequests {
        static let standard = "b09ef70a-490f-11eb-952e-9bc6f4646c57"
        static let withExpirationDate = "1"
        static let missingExpirationDate = "2"
    }
    
    // MARK: - Bulk Delete Payment Requests
    
    enum BulkDeletePaymentRequests {
        static let notFound = ["bfb74b1b-567e-471e-ac5d-9e4494d0d049"]
        
        static let unauthorized = [
            "8d5h7630-8f16-11ec-bd63-31f9d04e200e",
            "92de6fec-4a7f-4376-b5d5-5155adf8adca"
        ]
        
        static let mixed = [
            "8d5h7630-8f16-11ec-bd63-31f9d04e200e",
            "92de6fec-4a7f-4376-b5d5-5155adf8adca",
            "bfb74b1b-567e-471e-ac5d-9e4494d0d049"
        ]
    }
    
    // MARK: - Error Codes
    
    /// Error codes for document operations
    enum ErrorCodes {
        static let unauthorized = "2013"
        static let notFound = "2014"
        static let missingComposite = "2015"
    }
    
    /// Error codes for payment request operations
    enum PaymentRequestErrorCodes {
        static let unauthorized = "2016"
        static let notFound = "2017"
    }
}
