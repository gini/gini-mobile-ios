//
//  GiniBankNetworkingScreenApiCoordinator+TransactionDocs.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

extension GiniBankNetworkingScreenApiCoordinator {
    func handleTransactionDocsAlertIfNeeded(on controller: UIViewController,
                                            action: @escaping () -> Void) {
        let savedConfiguration = GiniBankUserDefaultsStorage.clientConfiguration
        let clientTransactionDocsEnabled = savedConfiguration?.transactionDocsEnabled ?? false
        let transactionDocsEnabled = clientTransactionDocsEnabled && giniBankConfiguration.transactionDocsEnabled

        guard transactionDocsEnabled else {
            // TransactionDocs feature not enabled, do not show any TransactionDocsAlertController
            // contiunue with the normal flow of PhotoPayment
            action()
            return
        }

        if let alwaysAttachDocs = GiniBankUserDefaultsStorage.alwaysAttachDocs {
            handleExistingAttachmentOption(alwaysAttachDocs,
                                           on: controller,
                                           action: action)
        } else {
            // First time displaying the TransactionDocsAlertController
            showAndSaveTransactionDocsAlert(on: controller, action: action)
        }
    }

    private func handleExistingAttachmentOption(_ alwaysAttachDocs: Bool,
                                                on controller: UIViewController,
                                                action: @escaping () -> Void) {
        if alwaysAttachDocs {
            // Do not show the TransactionDocsAlertController, always attach document
            // TODO: send in the AnalysisResult the TransactionDoc information
            action()
        } else {
            // Show the TransactionDocsAlertController every time
            showAndSaveTransactionDocsAlert(on: controller, action: action)
        }
    }

    private func showAndSaveTransactionDocsAlert(on controller: UIViewController,
                                                 action: @escaping () -> Void) {
        TransactionDocsAlertController.show(on: controller,
                                            alwaysAttachHandler: transactionDocsAction(
                                                selectedAttachmentOption: .alwaysAttach,
                                                action: action),
                                            attachOnceHandler: transactionDocsAction(
                                                selectedAttachmentOption: .attachOnce,
                                                action: action),
                                            doNotAttachHandler: transactionDocsAction(
                                                selectedAttachmentOption: .doNotAttach,
                                                action: action))
    }

    private func transactionDocsAction(selectedAttachmentOption: AttachmentOption,
                                       action: @escaping () -> Void) -> (() -> Void) {
        return {

            GiniBankUserDefaultsStorage.alwaysAttachDocs = selectedAttachmentOption == .alwaysAttach
            action()
        }
    }
}
