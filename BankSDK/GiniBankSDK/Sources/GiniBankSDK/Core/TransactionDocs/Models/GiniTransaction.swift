//
//  GiniTransaction.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

/// A representation of a transaction done via PhotoPayment containing attached documents if exists.
public struct GiniTransaction {

    /// The unique identifier for the transaction.
    /// This identifier is used to differentiate between transactions.
    public let identifier: String

    /// A collection of documents attached to the transaction.
    public var transactionDocs: [GiniTransactionDoc]

    /// Initializes a new transaction instance with an identifier and associated attached documents.
    ///
    /// - Parameters:
    ///   - identifier: A unique identifier for the transaction.
    ///   - transactionDocs: An array of `GiniTransactionDoc` objects attached to this transaction.
    public init(identifier: String, transactionDocs: [GiniTransactionDoc]) {
        self.identifier = identifier
        self.transactionDocs = transactionDocs
    }
}
