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

    /// Sets the "Always Attach Documents" setting to `true`.
    func setAlwaysAttachDocs(_ value: Bool)

    /// Resets the "Always Attach Documents" setting entirely.
    /// This may be used when the setting needs to be cleared or invalidated.
    func resetAlwaysAttachDocs()
}

/// A class that implements the TransactionDocsDataProtocol and manages transaction document data.
/// Responsible for handling the state of attaching documents to a transaction.
public class TransactionDocsDataCoordinator: TransactionDocsDataProtocol {

    // Mock data for transaction documents
   private var transactionDocs: [TransactionDoc] = [
        TransactionDoc(fileName: "image.png", type: .image),
        TransactionDoc(fileName: "document.pdf", type: .document)
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
}
