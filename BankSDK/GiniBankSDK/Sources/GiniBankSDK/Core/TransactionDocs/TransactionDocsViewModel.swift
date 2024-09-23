//
//  TransactionDocsViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

public class TransactionDocsViewModel {

    public var transactionDocs: [TransactionDoc] {
        didSet {
            onUpdate?()
        }
    }

    private var presentingViewController: UIViewController? {
        return TransactionDocsDataCoordinator.shared.presentingViewController
    }

    private var documentPagesViewController: DocumentPagesViewController?

    public var onUpdate: (() -> Void)?

    public init(transactionDocs: [TransactionDoc] = TransactionDocsDataCoordinator.shared.transactionDocs) {
        self.transactionDocs = transactionDocs
    }

    public func deleteTransactionDoc(with documentId: String) {
        transactionDocs.removeAll { $0.documentId == documentId }
        onUpdate?()
    }

    public func handleDocumentOpen() {
        let transactionDoc = self.transactionDocs.first
        let viewController = DocumentPagesViewController(screenTitle: transactionDoc?.fileName ?? "")
        viewController.modalPresentationStyle = .overCurrentContext
        documentPagesViewController = viewController
        presentingViewController?.present(viewController, animated: true)
        TransactionDocsDataCoordinator.shared.loadDocumentData?()
    }

    public func presentDocumentActionSheet(for document: TransactionDoc) {
        guard let presentingViewController = TransactionDocsDataCoordinator.shared.presentingViewController else {
            print("No presenting view controller available.")
            return
        }

        TransactionDocsActionsBottomSheet.showDeleteAlert(on: presentingViewController,
                                                          openHandler: { [weak self] in
            self?.handleDocumentOpen()
        },
                                                          deleteHandler: { [weak self] in
            self?.deleteTransactionDoc(with: document.documentId)
        })
    }

    func setTransactionDocsDocumentPagesViewModel(_ viewModel: TransactionDocsDocumentPagesViewModel) {
        guard let documentPagesViewController else { return }
        let transactionDoc = self.transactionDocs.first
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
}
