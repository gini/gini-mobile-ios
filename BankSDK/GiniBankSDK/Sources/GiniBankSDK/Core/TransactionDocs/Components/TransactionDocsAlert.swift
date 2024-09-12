//
//  TransactionDocsAlert.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

class TransactionDocsAlert {
    static func show(on viewController: UIViewController,
                     alwaysAttachHandler: @escaping () -> Void,
                     attachOnceHandler: @escaping () -> Void,
                     doNotAttachHandler: @escaping () -> Void) {
        let actionSheet = UIAlertController(title: Constants.title,
                                            message: Constants.message,
                                            preferredStyle: .alert)
        actionSheet.view.tintColor = .GiniBank.accent1

        let alwaysAttachAction = UIAlertAction(title: AttachmentOption.alwaysAttach.title, style: .default) { _ in
            alwaysAttachHandler()
        }
        let attachOnce = UIAlertAction(title: AttachmentOption.attachOnce.title, style: .default) { _ in
            attachOnceHandler()
        }
        let doNotAttachAction = UIAlertAction(title: AttachmentOption.doNotAttach.title, style: .cancel) { _ in
            doNotAttachHandler()
        }
        actionSheet.addAction(alwaysAttachAction)
        actionSheet.addAction(attachOnce)
        actionSheet.addAction(doNotAttachAction)
        actionSheet.preferredAction = alwaysAttachAction

        viewController.present(actionSheet, animated: true, completion: nil)
    }
}

private extension TransactionDocsAlert {
    enum Constants {
        static let title = NSLocalizedStringPreferredGiniBankFormat("ginibank.transactionDocs.alert.title",
                                                                    comment: "Add an attachment to this transaction")
        static let message = NSLocalizedStringPreferredGiniBankFormat("ginibank.transactionDocs.alert.message",
                                                                      comment: "We recommend adding attachments...")
    }
}
