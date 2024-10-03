//
//  TransactionDocsViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniBankAPILibrary

/// A view model responsible for managing the state of documents attached to a transaction.
/// The `TransactionDocsViewModel` class handles loading, deleting, and presenting attached documents
/// and communicates updates to the view.
public class TransactionDocsViewModel {

    /// The current list of transaction documents.
    var transactionDocs: [TransactionDoc] {
        didSet {
            onUpdate?()
        }
    }

    private var presentingViewController: UIViewController? {
        return transactionDocsDataProtocol.presentingViewController
    }
    // Cast the transactionDocsDataProtocol to the internal protocol to access internal properties and methods
    private var internalTransactionDocsDataCoordinator: TransactionDocsDataInternalProtocol? {
        return transactionDocsDataProtocol as? TransactionDocsDataInternalProtocol
    }

    private var documentPagesViewController: DocumentPagesViewController?
    private let transactionDocsDataProtocol: TransactionDocsDataProtocol
    public var onUpdate: (() -> Void)?

    /// Initializes a new instance of `TransactionDocsViewModel`.
    /// - Parameter transactionDocsDataProtocol: The protocol responsible for managing attached documents.
    public init(transactionDocsDataProtocol: TransactionDocsDataProtocol) {
        self.transactionDocsDataProtocol = transactionDocsDataProtocol
        // Access transactionDocs from the internal protocol if available
        transactionDocs = (transactionDocsDataProtocol as? TransactionDocsDataInternalProtocol)?.transactionDocs ?? []
    }

    /// Deletes a transaction document from the list.
    /// - Parameter documentId: The ID of the document to delete.
    func deleteTransactionDoc(with documentId: String) {
        transactionDocs.removeAll { $0.documentId == documentId }
        internalTransactionDocsDataCoordinator?.deleteTransactionDoc(with: documentId)
        onUpdate?()
    }
    /// Handles the action to preview an attached document
    /// - Parameter documentId: The ID of the document to preview.
    func handlePreviewDocument(for documentId: String) {
        let transactionDoc = transactionDocs.first(where: { $0.documentId == documentId })
        let screenTitle = transactionDoc?.fileName ?? ""
        let viewController = DocumentPagesViewController(screenTitle: screenTitle)
        viewController.modalPresentationStyle = .overCurrentContext
        documentPagesViewController = viewController
        presentingViewController?.present(viewController, animated: true)
        internalTransactionDocsDataCoordinator?.loadDocumentData?()
    }
    /// Presents an action sheet for the specified attached document, allowing the user to open or delete the document.
    /// - Parameter document: The `TransactionDoc` to present actions for.
    func presentDocumentActionSheet(for document: TransactionDoc) {
        guard let presentingViewController = transactionDocsDataProtocol.presentingViewController else {
            print("No presenting view controller available.")
            return
        }

        TransactionDocsActionsBottomSheet.showDeleteAlert(on: presentingViewController,
                                                          deleteHandler: { [weak self] in
            self?.deleteTransactionDoc(with: document.documentId)
        })
    }

    /// Sets the document pages view model for the `DocumentPagesViewController`.
    /// - Parameter viewModel: The view model representing the document pages.
    func setTransactionDocsDocumentPagesViewModel(_ viewModel: TransactionDocsDocumentPagesViewModel) {
        guard let documentPagesViewController else { return }
        let transactionDoc = transactionDocs.first
        viewModel.rightBarButtonAction = { [weak self] in
            guard let self else { return }
            let deleteAction = {
                self.deleteTransactionDoc(with: transactionDoc?.documentId ?? "")
                documentPagesViewController.dismiss(animated: true)
            }
            TransactionDocsActionsBottomSheet.showDeleteAlert(on: documentPagesViewController,
                                                              deleteHandler: deleteAction)
        }
        documentPagesViewController.stopLoadingIndicatorAnimation()
        documentPagesViewController.setData(viewModel: viewModel)
    }

    /// Informs that an error occurred while trying to preview a document.
    /// The method allows passing an error along with a retry action to handle the error scenario.
    ///
    /// - Parameters:
    ///   - error: The `GiniError` that occurred while previewing the document.
    ///   - tryAgainAction: A closure that is called when the user attempts to retry the document preview action.
    func setPreviewDocumentError(error: GiniError, tryAgainAction: @escaping () -> Void) {
        guard let documentPagesViewController else { return }
        documentPagesViewController.stopLoadingIndicatorAnimation()
        documentPagesViewController.setError(errorType: .init(error: error),
                                             tryAgainAction: tryAgainAction)
    }
}
