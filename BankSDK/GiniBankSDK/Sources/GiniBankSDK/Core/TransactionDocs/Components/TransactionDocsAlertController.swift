//
//  TransactionDocsAlertController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

/// A utility class responsible for presenting an alert to the user with options for handling transaction document attachments.
/// The alert allows the user to choose between always attaching documents, attaching once, or not attaching documents at all.
class TransactionDocsAlertController {

    /// Presents an alert on the specified view controller, offering the user three options related to attaching transaction documents.
    ///
    /// - Parameters:
    ///   - viewController: The view controller on which to present the alert.
    ///   - alwaysAttachHandler: A closure that is called when the user selects the "Always Attach" option.
    ///   - attachOnceHandler: A closure that is called when the user selects the "Attach Once" option.
    ///   - doNotAttachHandler: A closure that is called when the user selects the "Do Not Attach" option.
    ///
    /// This alert is used to prompt the user to decide how they want to handle the attachment of transaction documents in PP flow.
    static func show(on viewController: UIViewController,
                     alwaysAttachHandler: @escaping () -> Void,
                     attachOnceHandler: @escaping () -> Void,
                     doNotAttachHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: Constants.title,
                                                message: Constants.message,
                                                preferredStyle: .alert)
        alertController.view.tintColor = .GiniBank.accent1

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
        alertController.addAction(alwaysAttachAction)
        alertController.addAction(attachOnce)
        alertController.addAction(doNotAttachAction)
        alertController.preferredAction = alwaysAttachAction

        viewController.present(alertController, animated: true, completion: nil)
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
