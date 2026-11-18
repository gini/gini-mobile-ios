//
//  GiniBankNetworkingScreenApiCoordinator+FraudWarning.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK
import GiniUtilites

/**
 Fraud warning presentation seam. Each of the four terminal delivery paths
 (`deliver(result:)`, `deliverWithReturnAssistant`, `deliverWithSkonto`,
 `deliverWeroResult`) wraps its terminal section in
 `presentFraudWarningIfEnabled(result:completion:)`.

 Toggle off (default) → `completion` fires synchronously with the input
 result; delivery is unchanged. Toggle on → the warning presents as a
 large-detent bottom sheet; Cancel calls `giniCaptureDidCancelAnalysis` +
 resets `documentService`, Proceed invokes `completion` with the ORIGINAL
 result unchanged.

 IBANs shown are scaffold stubs; real extraction from
 `AnalysisResult.candidates` + chosen-IBAN propagation is deferred.
 */
extension GiniBankNetworkingScreenApiCoordinator: FraudWarningCoordinatorDelegate {

    private enum FraudWarningStubs {
        static let qrIBAN = "PL12 1000 0111 0100 1000"
        static let printedIBAN = "DE89 3704 0044 0532 0130 00"
    }

    func presentFraudWarningIfEnabled(result: AnalysisResult,
                                      completion: @escaping (AnalysisResult) -> Void) {
        guard giniBankConfiguration.fraudWarningEnabled else {
            completion(result)
            return
        }
        let coordinator = FraudWarningCoordinator(qrIBAN: FraudWarningStubs.qrIBAN,
                                                  printedIBAN: FraudWarningStubs.printedIBAN,
                                                  delegate: self)
        fraudWarningPresentation = (coordinator: coordinator,
                                    result: result,
                                    completion: completion)
        let hosting = coordinator.start()
        /// Large detent + manual `.present` — `presentAsBottomSheet(from:)` hardcodes medium.
        hosting.configureBottomSheet(shouldIncludeLargeDetent: true)
        screenAPINavigationController.present(hosting, animated: true) { [weak self] in
            self?.screenAPINavigationController.view.accessibilityElementsHidden = true
            hosting.view.accessibilityViewIsModal = true
            UIAccessibility.post(notification: .screenChanged, argument: hosting.view)
        }
    }

    // MARK: - FraudWarningCoordinatorDelegate

    func fraudWarningCoordinatorDidCancel(_ coordinator: FraudWarningCoordinator) {
        guard takeFraudWarningPresentation() != nil else { return }
        screenAPINavigationController.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.resultsDelegate?.giniCaptureDidCancelAnalysis()
            self.documentService.resetToInitialState()
        }
    }

    func fraudWarningCoordinatorDidProceed(_ coordinator: FraudWarningCoordinator) {
        guard let pending = takeFraudWarningPresentation() else { return }
        screenAPINavigationController.dismiss(animated: true) {
            pending.completion(pending.result)
        }
    }

    private func takeFraudWarningPresentation() -> (coordinator: FraudWarningCoordinator,
                                                    result: AnalysisResult,
                                                    completion: (AnalysisResult) -> Void)? {
        let presentation = fraudWarningPresentation
        fraudWarningPresentation = nil
        return presentation
    }
}
