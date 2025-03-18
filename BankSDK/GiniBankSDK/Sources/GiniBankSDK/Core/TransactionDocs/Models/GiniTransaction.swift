//
//  GiniTransaction.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

/**
 A model representing a transaction processed through PhotoPayment.
 This transaction may contain attached documents, if available.
 */
public struct GiniTransaction {

    /**
     The unique identifier for the transaction.
     */
    public let identifier: String

    /**
     A collection of documents attached to the transaction.
     */
    public var transactionDocs: [GiniTransactionDoc]

    /**
     Initializes a new transaction instance with an identifier and associated attached documents.

     - Parameters:
     - identifier: A unique identifier for the transaction.
     - transactionDocs: An array of `GiniTransactionDoc` objects associated with transaction.
     */
    public init(identifier: String, transactionDocs: [GiniTransactionDoc]) {
        self.identifier = identifier
        self.transactionDocs = transactionDocs
    }
}
