//
//  TransactionDocsDataCoordinator.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

/// A protocol that defines methods for managing the state of transaction documents in a photo payment flow.
/// Conforming types will be responsible for tracking and modifying the state related to attaching documents to a transaction.
public protocol TransactionDocsDataProtocol: AnyObject {

    /// Retrieves the current value of the "Always Attach Documents" setting.
    /// - Returns: A `Bool` representing whether documents should always be attached to the transaction
    func getAlwaysAttachDocsValue() -> Bool

    /// Sets the "Always Attach Documents" setting to a given value.
    /// - Parameter value: A `Bool` to set whether documents should always be attached to the transaction.
    func setAlwaysAttachDocs(_ value: Bool)

    /// Resets the "Always Attach Documents" setting entirely.
    /// This may be used when the setting needs to be cleared or invalidated.
    func resetAlwaysAttachDocs()

    /// Retrieves the current list of attached documents.
    /// - Returns: An array of `TransactionDoc` representing the attached documents.
    func getAttachedDocs() -> [TransactionDoc]

    /// Deletes a document from the attached documents list.
    /// - Parameter fileName: The name of the document to be deleted.
    func deleteAttachedDoc(named fileName: String)
}

/// A class that implements the TransactionDocsDataProtocol and manages transaction document data.
/// Responsible for handling the state of attaching documents to a transaction.
public class TransactionDocsDataCoordinator: TransactionDocsDataProtocol {
    
    // Singleton instance
    public static let shared = TransactionDocsDataCoordinator()

    private init() {}

    // Mock data for transaction documents
    public var transactionDocs: [TransactionDoc] = [
        TransactionDoc(documentId: "12121dssa", 
                       fileName: "imagess.png",
                       type: .image),
        TransactionDoc(documentId: "232asasas",
                       fileName: "documentwww.pdf",
                       type: .document)
    ]

    // MARK: - TransactionDocsDataProtocol Methods

    /// Retrieves the current value of the "Always Attach Documents" setting.
    public func getAlwaysAttachDocsValue() -> Bool {
        return GiniBankUserDefaultsStorage.alwaysAttachDocs ?? false
    }

    /// Sets the "Always Attach Documents" setting to `true`.
    public func setAlwaysAttachDocs(_ value: Bool) {
        GiniBankUserDefaultsStorage.alwaysAttachDocs = value
    }

    /// Resets the "Always Attach Documents" setting entirely.
    public func resetAlwaysAttachDocs() {
        GiniBankUserDefaultsStorage.removeAlwaysAttachDocs()
    }

    /// Retrieves the current list of attached documents.
    public func getAttachedDocs() -> [TransactionDoc] {
        return transactionDocs
    }

    /// Deletes a document from the attached documents list.
    public func deleteAttachedDoc(named fileName: String) {
        transactionDocs.removeAll { $0.fileName == fileName }
    }
}
