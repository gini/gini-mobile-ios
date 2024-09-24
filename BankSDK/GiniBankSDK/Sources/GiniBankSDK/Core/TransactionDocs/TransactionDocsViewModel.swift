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
        return transactionDocsDataProtocol.presentingViewController
    }

    private var documentPagesViewController: DocumentPagesViewController?
    private let transactionDocsDataProtocol: TransactionDocsDataProtocol
    public var onUpdate: (() -> Void)?

    public init(transactionDocsDataProtocol: TransactionDocsDataProtocol) {
        self.transactionDocsDataProtocol = transactionDocsDataProtocol
        self.transactionDocs = transactionDocsDataProtocol.transactionDocs
    }
    public func deleteTransactionDoc(with documentId: String) {
        transactionDocs.removeAll { $0.documentId == documentId }
        transactionDocsDataProtocol.deleteAttachedDoc(named: documentId)
        onUpdate?()
    }

    public func handleDocumentOpen() {
        let transactionDoc = self.transactionDocs.first
        let viewController = DocumentPagesViewController(screenTitle: transactionDoc?.fileName ?? "")
        viewController.modalPresentationStyle = .overCurrentContext
        documentPagesViewController = viewController
        presentingViewController?.present(viewController, animated: true)
        transactionDocsDataProtocol.loadDocumentData?()
    }

    public func presentDocumentActionSheet(for document: TransactionDoc) {
        guard let presentingViewController = transactionDocsDataProtocol.presentingViewController else {
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
