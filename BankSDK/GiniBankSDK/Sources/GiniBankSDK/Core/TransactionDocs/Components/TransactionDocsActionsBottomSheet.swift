//
//  TransactionDocActionsBottomSheet.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

class TransactionDocsActionsBottomSheet {
    static func showDeleteAlert(on viewController: UIViewController,
                                deleteHandler: @escaping () -> Void,
                                cancelHandler: (() -> Void)? = nil) {
        let actionSheet = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)
        actionSheet.view.tintColor = .GiniBank.accent1

        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = viewController.view
            popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                                  y: viewController.view.bounds.maxY,
                                                  width: 0,
                                                  height: 0)
            popoverController.permittedArrowDirections = []
        }

        let deleteAction = UIAlertAction(title: Constants.deleteTitle,
                                         style: .destructive) { _ in
            deleteHandler()
        }

        let cancelAction = UIAlertAction(title: Constants.cancelTitle,
                                         style: .cancel) { _ in
            cancelHandler?()
        }
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        actionSheet.preferredAction = deleteAction

        viewController.present(actionSheet, animated: true, completion: nil)
    }
}

private extension TransactionDocsActionsBottomSheet {
    enum Constants {
        static let deleteTitle = NSLocalizedStringPreferredGiniBankFormat("ginibank.transactionDocs.bottomSheet.action.delete",
                                                                          comment: "Delete")
        static let cancelTitle = NSLocalizedStringPreferredGiniBankFormat("ginibank.transactionDocs.bottomSheet.action.cancel",
                                                                          comment: "Cancel")
    }
}
