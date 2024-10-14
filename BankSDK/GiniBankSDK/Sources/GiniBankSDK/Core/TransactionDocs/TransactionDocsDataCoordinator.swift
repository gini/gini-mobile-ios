//
//  TransactionDocsDataCoordinator.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit
import GiniBankAPILibrary
/// A protocol that defines methods and properties for managing the state of transaction documents in a photo payment flow.
/// Conforming types are responsible for tracking, modifying, and handling the state related to attaching documents to a transaction.
public protocol TransactionDocsDataProtocol: AnyObject {

    /// The view controller responsible for presenting document-related views.
    var presentingViewController: UIViewController? { get set }

    /// The list of attached transaction document ids.
    var transactionDocIDs: [String] { get }

    /// Retrieves the current value of the "Always Attach Documents" setting.
    /// - Returns: A `Bool` representing whether documents should always be attached to the transaction.
    func getAlwaysAttachDocsValue() -> Bool

    /// Sets the "Always Attach Documents" setting to a given value.
    /// - Parameter value: A `Bool` indicating whether documents should always be attached to the transaction.
    func setAlwaysAttachDocs(_ value: Bool)
}

/// An internal protocol that defines methods and properties for managing the state
/// of transaction documents used within the GiniBankSDK.
internal protocol TransactionDocsDataInternalProtocol: AnyObject {

    /// The list of attached transaction documents.
    var transactionDocs: [TransactionDoc] { get set }

    /// Retrieves the current view model for transaction documents.
    /// - Returns: An optional `TransactionDocsViewModel` instance if available.
    func getTransactionDocsViewModel() -> TransactionDocsViewModel?

    /// A closure that handles the loading of document data.
    var loadDocumentData: (() -> Void)? { get set }

    /// Informs that an error occurred while trying to preview a document.
    /// The method allows passing an error along with a retry action to handle the error scenario.
    ///
    /// - Parameters:
    ///   - error: The `GiniError` that occurred while previewing the document.
    ///   - tryAgainAction: A closure that is called when the user attempts to retry the document preview action.
    func setPreviewDocumentError(error: GiniError, tryAgainAction: @escaping () -> Void)

    /// Deletes a attached document to a transaction from the list.
    /// - Parameter documentId: The ID of the document to delete.
    func deleteTransactionDoc(with documentId: String)
}

/// A class that implements the `TransactionDocsDataProtocol` to manage transaction document data.
/// Responsible for handling the state of attaching, managing, and presenting documents attached to a transaction.
public class TransactionDocsDataCoordinator: TransactionDocsDataProtocol, TransactionDocsDataInternalProtocol {

    // MARK: - Internal properties and methods

    /// The list of attached transaction documents.
    var transactionDocs: [TransactionDoc] = [] {
        didSet {
            transactionDocsViewModel?.transactionDocs = transactionDocs
        }
    }
    /// Retrieves the current view model for transaction documents.
    /// - Returns: An optional `TransactionDocsViewModel` instance if available.
    func getTransactionDocsViewModel() -> TransactionDocsViewModel? {
        return transactionDocsViewModel
    }

    /// Lazily initialized view model for transaction documents.
    private lazy var transactionDocsViewModel: TransactionDocsViewModel? = {
        return TransactionDocsViewModel(transactionDocsDataProtocol: self)
    }()

    // MARK: - Initializer
    /// Initializes a new instance of the class.
    public init() {
        // This initializer is intentionally left empty because no custom setup is required at initialization.
    }

    // MARK: - TransactionDocsDataProtocol - Public protocol methods and properties

    /// The view controller responsible for presenting document-related views.
    public weak var presentingViewController: UIViewController?

    /// A closure that handles loading document data.
    public var loadDocumentData: (() -> Void)?

    /// Retrieves the current value of the "Always Attach Documents" setting.
    /// - Returns: A `Bool` representing whether documents should always be attached to the transaction.
    public func getAlwaysAttachDocsValue() -> Bool {
        return GiniBankUserDefaultsStorage.alwaysAttachDocs ?? false
    }

    public var transactionDocIDs: [String] {
        return transactionDocs.map { $0.documentId }
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

    /// Deletes a attached document to a transaction from the list.
    /// - Parameter documentId: The ID of the document to delete.
    public func deleteTransactionDoc(with documentId: String) {
        transactionDocs.removeAll { $0.documentId == documentId }
    }

    /// Informs that an error occurred while trying to preview a document.
    /// The method allows passing an error along with a retry action to handle the error scenario.
    ///
    /// - Parameters:
    ///   - error: The `GiniError` that occurred while previewing the document.
    ///   - tryAgainAction: A closure that is called when the user attempts to retry the document preview action.
    func setPreviewDocumentError(error: GiniBankAPILibrary.GiniError, tryAgainAction: @escaping () -> Void) {
        transactionDocsViewModel?.setPreviewDocumentError(error: error, tryAgainAction: tryAgainAction)
    }
}
