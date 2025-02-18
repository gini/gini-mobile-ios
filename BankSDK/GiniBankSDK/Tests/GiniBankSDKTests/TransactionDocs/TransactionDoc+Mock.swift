//
//  TransactionDoc+Mock.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

@testable import GiniBankSDK

extension TransactionDoc {
    /// Creates a mock list of transaction documents.
    static func createMockDocuments(count: Int = 2) -> [TransactionDoc] {
        return (1...count).map { index in
            TransactionDoc(documentId: "doc\(index)", fileName: "filename\(index)", type: .document)
        }
    }

    /// Creates a mock list of transactions, where each transaction contains a list of documents.
    static func createMockTransactions(transactionCount: Int = 2, documentsPerTransaction: Int = 2) -> [[TransactionDoc]] {
        return (1...transactionCount).map { _ in
            createMockDocuments(count: documentsPerTransaction)
        }
    }
}
