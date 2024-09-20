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

    public var presentingViewController: UIViewController?

    public var onUpdate: (() -> Void)?

    public init(transactionDocs: [TransactionDoc] = TransactionDocsDataCoordinator.shared.transactionDocs) {
        self.transactionDocs = transactionDocs
        self.presentingViewController = TransactionDocsDataCoordinator.shared.presentingViewController
    }

    public func deleteTransactionDoc(with fileName: String) {
        transactionDocs.removeAll { $0.fileName == fileName }
        onUpdate?()
    }

    public func handleDocumentOpen(for documentId: String) {
        guard let presentingViewController = TransactionDocsDataCoordinator.shared.presentingViewController else {
            print("No presenting view controller available.")
            return
        }

        guard let transactionDoc = transactionDocs.first(where: { $0.documentId == documentId }) else {
            print("Document not found.")
            return
        }

        let viewModel = TransactionDocsDocumentPagesViewModel(
            originalImages: [GiniImages.transactionDocsFileIcon.image!],
            amountToPay: .init(value: 100, currencyCode: "EUR"),
            iban: "IBAN",
            expiryDate: Date(),
            rightBarButtonAction: { [weak self] in
                self?.deleteTransactionDoc(with: transactionDoc.fileName)
                presentingViewController.dismiss(animated: true)
            }
        )

        let viewController = DocumentPagesViewController(screenTitle: transactionDoc.fileName)
        viewController.modalPresentationStyle = .fullScreen

        presentingViewController.present(viewController, animated: true)

        // Simulate data loading delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            viewController.stopLoadingIndicatorAnimation()
            viewController.setData(viewModel: viewModel)
        }
    }

    public func presentDocumentActionSheet(for document: TransactionDoc) {
        guard let presentingViewController = TransactionDocsDataCoordinator.shared.presentingViewController else {
            print("No presenting view controller available.")
            return
        }

        TransactionDocsActionsBottomSheet.showDeleteAlert(on: presentingViewController,
                                                          openHandler: { [weak self] in
            self?.handleDocumentOpen(for: document.documentId)
        },
                                                          deleteHandler: { [weak self] in
            self?.deleteTransactionDoc(with: document.fileName)
        })
    }
}
