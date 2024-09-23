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

    private lazy var documentPagesViewController: DocumentPagesViewController = {
        let transactionDoc = self.transactionDocs.first
        let viewController = DocumentPagesViewController(screenTitle: transactionDoc?.fileName ?? "")
        viewController.modalPresentationStyle = .overCurrentContext
        return viewController
    }()

    public var onUpdate: (() -> Void)?

    public init(transactionDocs: [TransactionDoc] = TransactionDocsDataCoordinator.shared.transactionDocs) {
        self.transactionDocs = transactionDocs
    }

    public func deleteTransactionDoc(with fileName: String) {
        transactionDocs.removeAll { $0.fileName == fileName }
        onUpdate?()
    }

    public func handleDocumentOpen() {
        presentingViewController?.present(documentPagesViewController, animated: true)
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
            self?.deleteTransactionDoc(with: document.fileName)
        })
    }

    func setTransactionDocsDocumentPagesViewModel(_ transactionDocsDocumentPagesViewModel: TransactionDocsDocumentPagesViewModel) {
        let transactionDoc = self.transactionDocs.first
        transactionDocsDocumentPagesViewModel.rightBarButtonAction = { [weak self] in
            guard let self else { return }
            let deleteAction = {
                self.deleteTransactionDoc(with: transactionDoc?.fileName ?? "")
                self.documentPagesViewController.dismiss(animated: true)
            }
            TransactionDocsActionsBottomSheet.showDeleteAlert(on: self.documentPagesViewController,
                                                              deleteHandler: deleteAction)
        }
        documentPagesViewController.stopLoadingIndicatorAnimation()
        documentPagesViewController.setData(viewModel: transactionDocsDocumentPagesViewModel)
    }
}
