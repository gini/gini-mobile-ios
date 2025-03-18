//
//  TransactionDocsDataCoordinator.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniBankAPILibrary

/**
 An internal protocol that defines methods and properties for managing the state
 of transaction documents within the GiniBankSDK.
 */
internal protocol TransactionDocsDataInternalProtocol: AnyObject {

    /**
     Retrieves the current view model for transaction documents.

     - Returns: An optional `TransactionDocsViewModel` instance if available.
     */
    func getTransactionDocsViewModel() -> TransactionDocsViewModel?

    /**
     Updates the `TransactionDocsViewModel` with new images and extracted data for a specific document.

     - Parameters:
     - images: An array of `UIImage` objects representing the updated transaction document images.
     - extractions: An array of `Extraction` objects containing extracted data related to the transaction.
     - documentId: A `String` representing the unique identifier of the document being updated.

     This method ensures that the `TransactionDocsViewModel` is synchronized with the latest document images and extracted data.
     */
    func updateTransactionDocsViewModel(with images: [UIImage],
                                        extractions: [Extraction],
                                        for documentId: String)

    /**
     A closure that handles the loading of document data.
     */
    var loadDocumentData: (() -> Void)? { get set }

    /**
     Informs that an error occurred while trying to preview a document.
     The method allows passing an error along with a retry action to handle the error scenario.

     - Parameters:
     - error: The `GiniError` that occurred while previewing the document.
     - tryAgainAction: A closure that is called when the user attempts to retry the document preview action.
     */
    func setPreviewDocumentError(error: GiniError, tryAgainAction: @escaping () -> Void)

    /**
     Deletes an attached document from a transaction.

     - Parameter documentId: The ID of the document to delete.
     */
    func deleteTransactionDoc(with documentId: String)
}

/**
 A class that implements the `TransactionDocsDataProtocol` to manage transaction document data.
 Responsible for handling the state of attaching, managing, and presenting documents attached to a transaction.
 */
public final class TransactionDocsDataCoordinator: TransactionDocsDataProtocol, TransactionDocsDataInternalProtocol {

    // MARK: - Internal properties and methods

    /**
     Retrieves the current view model for transaction documents.

     - Returns: An optional `TransactionDocsViewModel` instance if available.
     */
    func getTransactionDocsViewModel() -> TransactionDocsViewModel? {
        if transactionViewModels.isEmpty {
            return transactionDocsViewModel
        }
        return getSelectedTransactionDocsViewModel()
    }

    /**
     Lazily initialized view model for transaction documents.
     */
    private lazy var transactionDocsViewModel: TransactionDocsViewModel? = {
        return TransactionDocsViewModel(transactionDocsDataProtocol: self)
    }()

    /**
     A closure that handles loading document data.
     */
    var loadDocumentData: (() -> Void)?

    // MARK: - Initializer

    /**
     Initializes a new instance of the class.
     */
    public init() {
        // This initializer is intentionally left empty because no custom setup is required at initialization.
    }

    // MARK: - TransactionDocsDataProtocol - Public protocol methods and properties

    /**
     The view controller responsible for presenting document-related views.
     */
    public weak var presentingViewController: UIViewController?

    /**
     Retrieves the current value of the "Always Attach Documents" setting.

     - Returns: A `Bool` representing whether documents should always be attached to the transaction.
     */
    public func getAlwaysAttachDocsValue() -> Bool {
        return GiniBankUserDefaultsStorage.alwaysAttachDocs ?? false
    }

    /**
     Retrieves or updates the list of transaction documents for the selected transaction.
     Supports both single-instance and multi-transaction cases.
     */
    public var transactionDocs: [GiniTransactionDoc] = [] {
        didSet {
            if transactionViewModels.isEmpty {
                transactionDocsViewModel?.transactionDocs = transactionDocs
            } else if transactions.indices.contains(selectedTransactionIndex) {
                transactions[selectedTransactionIndex].transactionDocs = transactionDocs
                transactionViewModels[selectedTransactionIndex].transactionDocs = transactionDocs
            }
        }
    }

    /**
     Sets the "Always Attach Documents" setting to the given value.

     - Parameter value: A `Bool` indicating whether documents should always be attached to the transaction.
     */
    public func setAlwaysAttachDocs(_ value: Bool) {
        GiniBankUserDefaultsStorage.alwaysAttachDocs = value
    }

    /**
     Resets the "Always Attach Documents" setting.
     */
    public func resetAlwaysAttachDocs() {
        GiniBankUserDefaultsStorage.removeAlwaysAttachDocs()
    }

    /**
     Deletes an attached document from the selected transaction.

     - Parameter documentId: The ID of the document to delete.
     */
    public func deleteTransactionDoc(with documentId: String) {
        if transactionViewModels.isEmpty {
            transactionDocs.removeAll { $0.documentId == documentId }
        } else if transactions.indices.contains(selectedTransactionIndex) {
            transactions[selectedTransactionIndex].transactionDocs.removeAll { $0.documentId == documentId }
            transactionDocs = transactions[selectedTransactionIndex].transactionDocs
        }
    }

    /**
     Informs that an error occurred while trying to preview a document.
     The method allows passing an error along with a retry action to handle the error scenario.

     - Parameters:
     - error: The `GiniError` that occurred while previewing the document.
     - tryAgainAction: A closure that is called when the user attempts to retry the document preview action.
     */
    func setPreviewDocumentError(error: GiniBankAPILibrary.GiniError, tryAgainAction: @escaping () -> Void) {
        transactionDocsViewModel?.setPreviewDocumentError(error: error, tryAgainAction: tryAgainAction)
    }

    /**
     Updates the `TransactionDocsViewModel` with new images and extracted data for a specific document.

     - Parameters:
     - images: An array of `UIImage` objects representing the updated transaction document images.
     - extractions: An array of `Extraction` objects containing extracted data related to the transaction.
     - documentId: A `String` representing the unique identifier of the document being updated.
     */
    func updateTransactionDocsViewModel(with images: [UIImage],
                                        extractions: [Extraction],
                                        for documentId: String) {
        let extractionInfo = TransactionDocsExtractions(extractions: extractions)
        let viewModel = TransactionDocsDocumentPagesViewModel(originalImages: images,
                                                              extractions: extractionInfo)
        getTransactionDocsViewModel()?
            .setTransactionDocsDocumentPagesViewModel(viewModel, for: documentId)
    }

    // MARK: - Multiple transactions handling internal methods and properties

    /**
     Stores multiple sets of transactions.
     */
    private var transactions: [GiniTransaction] = []

    /**
     Stores view models for each transaction.
     */
    private var transactionViewModels: [TransactionDocsViewModel] = []

    /**
     Stores the currently selected transaction index.
     */
    private var selectedTransactionIndex: Int = 0

    /**
     Retrieves the `TransactionDocsViewModel` for the selected transaction.

     - Returns: The `TransactionDocsViewModel` instance for the selected transaction, or `nil` if unavailable.
     */
    private func getSelectedTransactionDocsViewModel() -> TransactionDocsViewModel? {
        guard transactionViewModels.indices.contains(selectedTransactionIndex) else { return nil }
        return transactionViewModels[selectedTransactionIndex]
    }

    // MARK: - Multiple transactions handling public methods

    /**
     Sets the transactions and creates a view model for each.

     - Parameter transactions: A nested array of `GiniTransaction` objects, where each inner array represents
     the documents attached to a specific transaction.
     */
    public func setTransactions(_ transactions: [GiniTransaction]) {
        self.transactions = transactions
        transactionViewModels = transactions.map { transaction in
            let viewModel = TransactionDocsViewModel(transactionDocsDataProtocol: self)
            viewModel.transactionDocs = transaction.transactionDocs
            return viewModel
        }

        if transactions.count == 1 {
            transactionDocsViewModel = transactionViewModels.first
        }
    }

    /**
     Sets the selected transaction.

     - Parameter identifier: The unique identifier of the transaction to select.
     */
    public func setSelectedTransaction(_ identifier: String) {
        guard let index = transactions.firstIndex(where: { $0.identifier == identifier }) else { return }
        self.selectedTransactionIndex = index
        transactionDocs = transactions[index].transactionDocs
    }
}
