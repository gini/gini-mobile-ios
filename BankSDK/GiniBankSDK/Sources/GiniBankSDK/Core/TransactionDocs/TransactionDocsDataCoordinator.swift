//
//  TransactionDocsDataCoordinator.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit
/// A protocol that defines methods and properties for managing the state of transaction documents in a photo payment flow.
/// Conforming types are responsible for tracking, modifying, and handling the state related to attaching documents to a transaction.
public protocol TransactionDocsDataProtocol: AnyObject {

    /// The view controller responsible for presenting document-related views.
    var presentingViewController: UIViewController? { get set }

    /// Retrieves the current value of the "Always Attach Documents" setting.
    /// - Returns: A `Bool` representing whether documents should always be attached to the transaction.
    func getAlwaysAttachDocsValue() -> Bool

    /// Sets the "Always Attach Documents" setting to a given value.
    /// - Parameter value: A `Bool` indicating whether documents should always be attached to the transaction.
    func setAlwaysAttachDocs(_ value: Bool)

    /// Retrieves the current view model for transaction documents.
    /// - Returns: An optional `TransactionDocsViewModel` instance if available.
    func getTransactionDocsViewModel() -> TransactionDocsViewModel?

    /// A closure that handles the loading of document data.
    var loadDocumentData: (() -> Void)? { get set }

    /// The list of attached transaction documents.
    var transactionDocs: [TransactionDoc] { get set }

    /// Deletes a document from the attached documents list.
    /// - Parameter fileName: The name of the document to be deleted.
    func deleteAttachedDoc(named fileName: String)
}

/// A class that implements the `TransactionDocsDataProtocol` to manage transaction document data.
/// Responsible for handling the state of attaching, managing, and presenting documents attached to a transaction.
public class TransactionDocsDataCoordinator: TransactionDocsDataProtocol {

    /// The view controller responsible for presenting document-related views.
    public weak var presentingViewController: UIViewController?

    /// A closure that handles loading document data.
    public var loadDocumentData: (() -> Void)?

    /// The list of attached transaction documents.
    public var transactionDocs: [TransactionDoc] = [] {
        didSet {
            transactionDocsViewModel?.transactionDocs = transactionDocs
        }
    }

    /// Lazily initialized view model for transaction documents.
    private lazy var transactionDocsViewModel: TransactionDocsViewModel? = {
        return TransactionDocsViewModel(transactionDocsDataProtocol: self)
    }()

    /// Default initializer.
    public init() {}

    /// Retrieves the current value of the "Always Attach Documents" setting.
    /// - Returns: A `Bool` representing whether documents should always be attached to the transaction.
    public func getAlwaysAttachDocsValue() -> Bool {
        return GiniBankUserDefaultsStorage.alwaysAttachDocs ?? false
    }

    /// Sets the "Always Attach Documents" setting to the given value.
    /// - Parameter value: A `Bool` indicating whether documents should always be attached to the transaction.
    public func setAlwaysAttachDocs(_ value: Bool) {
        GiniBankUserDefaultsStorage.alwaysAttachDocs = value
    }

    /// Resets the "Always Attach Documents" setting.
    public func resetAlwaysAttachDocs() {
        GiniBankUserDefaultsStorage.removeAlwaysAttachDocs()
    }

    /// Retrieves the current view model for transaction documents.
    /// - Returns: An optional `TransactionDocsViewModel` instance if available.
    public func getTransactionDocsViewModel() -> TransactionDocsViewModel? {
        return transactionDocsViewModel
    }

    /// Deletes a document from the attached documents list.
    /// - Parameter fileName: The name of the document to be deleted.
    public func deleteAttachedDoc(named fileName: String) {
        transactionDocs.removeAll { $0.fileName == fileName }
    }
}
