//
//  TransactionDocsDataCoordinator.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniBankAPILibrary

/// An internal protocol that defines methods and properties for managing the state
/// of transaction documents used within the GiniBankSDK.
internal protocol TransactionDocsDataInternalProtocol: AnyObject {

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

    /// Retrieves the current view model for transaction documents.
    /// - Returns: An optional `TransactionDocsViewModel` instance if available.
    func getTransactionDocsViewModel() -> TransactionDocsViewModel? {
        if transactionViewModels.isEmpty {
            return transactionDocsViewModel
        }
        return getSelectedTransactionDocsViewModel()
    }

    /// Lazily initialized view model for transaction documents.
    private lazy var transactionDocsViewModel: TransactionDocsViewModel? = {
        return TransactionDocsViewModel(transactionDocsDataProtocol: self)
    }()

    /// A closure that handles loading document data.
    var loadDocumentData: (() -> Void)?

    // MARK: - Initializer
    /// Initializes a new instance of the class.
    public init() {
        // This initializer is intentionally left empty because no custom setup is required at initialization.
    }

    // MARK: - TransactionDocsDataProtocol - Public protocol methods and properties

    /// The view controller responsible for presenting document-related views.
    public weak var presentingViewController: UIViewController?

    /// Retrieves the current value of the "Always Attach Documents" setting.
    /// - Returns: A `Bool` representing whether documents should always be attached to the transaction.
    public func getAlwaysAttachDocsValue() -> Bool {
        return GiniBankUserDefaultsStorage.alwaysAttachDocs ?? false
    }

    /// Retrieves or updates the list of transaction documents for the selected transaction.
    /// Supports both single-instance and multi-transaction cases.
    public var transactionDocs: [TransactionDoc] = [] {
        didSet {
            // If no multi-transaction logic is used, update the single-instance model
            if transactionViewModels.isEmpty {
                transactionDocsViewModel?.transactionDocs = transactionDocs
            } else if transactions.indices.contains(selectedTransactionIndex) {
                // Multiple transactions case: Ensure the selected transaction updates correctly
                transactions[selectedTransactionIndex] = transactionDocs
                transactionViewModels[selectedTransactionIndex].transactionDocs = transactionDocs
            }
        }
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

    /// Deletes an attached document from the selected transaction.
    /// If only a single transaction exists, it uses the previous implementation.
    /// - Parameter documentId: The ID of the document to delete.
    public func deleteTransactionDoc(with documentId: String) {
        if transactionViewModels.isEmpty {
            // single transaction support
            transactionDocs.removeAll { $0.documentId == documentId }
            return
        }

        // multiple transactions support
        guard transactions.indices.contains(selectedTransactionIndex) else { return }

        transactions[selectedTransactionIndex].removeAll { $0.documentId == documentId }
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

    private func updateTransactionDocsViewModel(with images: [UIImage],
                                                extractions: [Extraction],
                                                for documentId: String) {
        let extractionInfo = TransactionDocsExtractions(extractions: extractions)
        let viewModel = TransactionDocsDocumentPagesViewModel(originalImages: images,
                                                              extractions: extractionInfo)
        getTransactionDocsViewModel()?
            .setTransactionDocsDocumentPagesViewModel(viewModel, for: documentId)
    }

    // MARK: - Multiple transactions handling internal methods and properties

    /// Stores multiple sets of transaction documents, where each index represents a transaction.
    private var transactions: [[TransactionDoc]] = []

    /// Stores view models for each transaction.
    private var transactionViewModels: [TransactionDocsViewModel] = []

    /// Stores the currently selected transaction index.
    private var selectedTransactionIndex: Int = 0

    /// Retrieves the `TransactionDocsViewModel` for the selected transaction.
    private func getSelectedTransactionDocsViewModel() -> TransactionDocsViewModel? {
        guard transactionViewModels.indices.contains(selectedTransactionIndex) else { return nil }
        return transactionViewModels[selectedTransactionIndex]
    }

    // MARK: - Multiple transactions handling public methods
    /// Sets the transactions and creates a view model for each.
    /// If a single transaction is provided, it updates the old `transactionDocsViewModel` for backward compatibility.
    public func setTransactions(_ transactions: [[TransactionDoc]]) {
        self.transactions = transactions
        transactionViewModels = transactions.map { docs in
            let viewModel = TransactionDocsViewModel(transactionDocsDataProtocol: self)
            viewModel.transactionDocs = docs
            return viewModel
        }

        // Support old single-instance view model if only one transaction exists
        if transactions.count == 1 {
            transactionDocsViewModel = transactionViewModels.first
        }
    }

    /// Sets the selected transaction index.
    public func setSelectedTransactionIndex(_ index: Int) {
        guard transactions.indices.contains(index) else { return }
        self.selectedTransactionIndex = index
    }

}
