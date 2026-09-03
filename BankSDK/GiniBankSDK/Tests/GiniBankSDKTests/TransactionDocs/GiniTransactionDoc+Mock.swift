//
//  GiniTransactionDoc+Mock.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

@testable import GiniBankSDK

extension GiniTransaction {
    /// Creates a mock list of transaction documents.
    static func createMockDocuments(count: Int = 2) -> [GiniTransactionDoc] {
        return (1...count).map { index in
            GiniTransactionDoc(documentId: "doc\(index)", originalFileName: "filename\(index)")
        }
    }

    /// Creates a mock list of `GiniTransaction` objects, where each transaction contains a list of documents.
    static func createMockTransactions(transactionCount: Int = 2, documentsPerTransaction: Int = 2) -> [GiniTransaction] {
        return (1...transactionCount).map { index in
            GiniTransaction(
                identifier: "indentifier\(index)",
                transactionDocs: createMockDocuments(count: documentsPerTransaction)
            )
        }
    }
}
