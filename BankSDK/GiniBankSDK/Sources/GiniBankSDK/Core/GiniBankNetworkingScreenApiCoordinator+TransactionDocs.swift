//
//  GiniBankNetworkingScreenApiCoordinator+TransactionDocs.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

extension GiniBankNetworkingScreenApiCoordinator {
    func handleTransactionDocsAlertIfNeeded(on controller: UIViewController,
                                            defaultAction: @escaping () -> Void,
                                            attachAction: @escaping () -> Void) {
        let savedConfiguration = GiniBankUserDefaultsStorage.clientConfiguration
        let clientTransactionDocsEnabled = savedConfiguration?.transactionDocsEnabled ?? false
        let transactionDocsEnabled = clientTransactionDocsEnabled && giniBankConfiguration.transactionDocsEnabled

        guard transactionDocsEnabled else {
            // TransactionDocs feature not enabled, do not show any TransactionDocsAlertController
            // contiunue with the normal flow of PhotoPayment
            defaultAction()
            return
        }

        let alwaysAttachDocsValue = giniBankConfiguration.transactionDocsDataCoordinator.getAlwaysAttachDocsValue()
        if alwaysAttachDocsValue {
            handleExistingAttachmentOption(alwaysAttachDocsValue,
                                           on: controller,
                                           defaultAction: defaultAction,
                                           attachAction: attachAction)
        } else {
            // First time displaying the TransactionDocsAlertController
            showAndSaveTransactionDocsAlert(on: controller,
                                            defaultAction: defaultAction,
                                            attachAction: attachAction)
        }
    }

    private func handleExistingAttachmentOption(_ alwaysAttachDocs: Bool,
                                                on controller: UIViewController,
                                                defaultAction: @escaping () -> Void,
                                                attachAction: @escaping () -> Void) {
        if alwaysAttachDocs {
            // Do not show the TransactionDocsAlertController, always attach document
            attachAction()
        } else {
            // Show the TransactionDocsAlertController every time
            showAndSaveTransactionDocsAlert(on: controller,
                                            defaultAction: defaultAction,
                                            attachAction: attachAction)
        }
    }

    private func showAndSaveTransactionDocsAlert(on controller: UIViewController,
                                                 defaultAction: @escaping () -> Void,
                                                 attachAction: @escaping () -> Void) {
        TransactionDocsAlertController.show(on: controller,
                                            alwaysAttachHandler: { [weak self] in
            self?.giniBankConfiguration.transactionDocsDataCoordinator.setAlwaysAttachDocs(true)
            attachAction()
        },
                                            attachOnceHandler: {
                                            attachAction()
                                        },
                                            doNotAttachHandler: { defaultAction() })
    }
}
