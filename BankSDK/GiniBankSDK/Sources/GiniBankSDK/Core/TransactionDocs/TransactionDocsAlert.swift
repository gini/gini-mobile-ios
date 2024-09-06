//
//  TransactionDocsAlert.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

class TransactionDocsAlert {
    static func show(on viewController: UIViewController,
                     alwaysAttachHandler: @escaping () -> Void,
                     attachHandler: @escaping () -> Void,
                     dontAttachHandler: @escaping () -> Void) {
        let actionSheet = UIAlertController(title: Constants.title,
                                            message: Constants.message,
                                            preferredStyle: .alert)
        actionSheet.view.tintColor = .GiniBank.accent1

        let alwaysAttachAction = UIAlertAction(title: Constants.alwaysAttachButtonTitle, style: .default) { _ in
            alwaysAttachHandler()
        }
        let attachAction = UIAlertAction(title: Constants.attachButtonTitle, style: .default) { _ in
            attachHandler()
        }
        let dontAttachAction = UIAlertAction(title: Constants.dontAttachButtonTitle, style: .cancel) { _ in
            dontAttachHandler()
        }
        actionSheet.addAction(alwaysAttachAction)
        actionSheet.addAction(attachAction)
        actionSheet.addAction(dontAttachAction)
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
        static let alwaysAttachButtonTitle = NSLocalizedStringPreferredGiniBankFormat("ginibank.transactionDocs.alert.action.attachAlways",
                                                                                      comment: "Always attach")
        static let attachButtonTitle = NSLocalizedStringPreferredGiniBankFormat("ginibank.transactionDocs.alert.action.attach",
                                                                                comment: "Attach")
        static let dontAttachButtonTitle = NSLocalizedStringPreferredGiniBankFormat("ginibank.transactionDocs.alert.action.dontAttach",
                                                                                    comment: "Don't attach")
    }
}
