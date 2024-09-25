//
//  TransactionDocsAlertController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

class TransactionDocsAlertController {
    static func show(on viewController: UIViewController,
                     alwaysAttachHandler: @escaping () -> Void,
                     attachOnceHandler: @escaping () -> Void,
                     doNotAttachHandler: @escaping () -> Void) {
        let alterController = UIAlertController(title: Constants.title,
                                                message: Constants.message,
                                                preferredStyle: .alert)
        alterController.view.tintColor = .GiniBank.accent1

        let alwaysAttachAction = UIAlertAction(title: GiniUserAttachmentOption.alwaysAttach.title,
                                               style: .default) { _ in
            alwaysAttachHandler()
        }
        let attachOnce = UIAlertAction(title: GiniUserAttachmentOption.attachOnce.title,
                                       style: .default) { _ in
            attachOnceHandler()
        }
        let doNotAttachAction = UIAlertAction(title: GiniUserAttachmentOption.doNotAttach.title,
                                              style: .cancel) { _ in
            doNotAttachHandler()
        }
        alterController.addAction(alwaysAttachAction)
        alterController.addAction(attachOnce)
        alterController.addAction(doNotAttachAction)
        alterController.preferredAction = alwaysAttachAction

        viewController.present(alterController, animated: true, completion: nil)
    }
}

private extension TransactionDocsAlertController {
    enum Constants {
        static let title = NSLocalizedStringPreferredGiniBankFormat("ginibank.transactionDocs.alert.title",
                                                                    comment: "Add an attachment to this transaction")
        static let message = NSLocalizedStringPreferredGiniBankFormat("ginibank.transactionDocs.alert.message",
                                                                      comment: "We recommend adding attachments...")
    }
}
