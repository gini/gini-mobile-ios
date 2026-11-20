//
//  GiniBankNetworkingScreenApiCoordinator+FraudWarning.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit
import GiniBankAPILibrary
import GiniCaptureSDK
import GiniUtilites

/**
 Fraud warning presentation seam. Each of the four terminal delivery paths
 (`deliver(result:)`, `deliverWithReturnAssistant`, `deliverWithSkonto`,
 `deliverWeroResult`) wraps its terminal section in
 `presentFraudWarningIfEnabled(result:extractionResult:completion:)`.

 Short-circuits when any of these is true (completion fires synchronously
 with the input result, delivery unchanged):
 - `GiniBankConfiguration.fraudWarningEnabled == false` (integrator gate)
 - backend's `ClientConfiguration.fraudSignalsEnabled` is `false` / `nil`
 - `FraudWarningIBANResolver` returns `nil` (no `.qrPrintedIbanMismatch`
   signal, or no printed-IBAN candidate to contrast against)

 Otherwise the warning presents as a large-detent bottom sheet with the
 resolved QR + printed IBANs; Cancel calls `giniCaptureDidCancelAnalysis` +
 resets `documentService`, Proceed applies the user's IBAN choice to the
 parked result via `ChosenIBANExtractions` (rewriting `iban`, dropping
 `bic` when the pick differs from the backend's) and invokes `completion`.
 */
extension GiniBankNetworkingScreenApiCoordinator: FraudWarningCoordinatorDelegate {

    func presentFraudWarningIfEnabled(result: AnalysisResult,
                                      extractionResult: ExtractionResult,
                                      completion: @escaping (AnalysisResult) -> Void) {
        guard giniBankConfiguration.fraudWarningEnabled else {
            completion(result)
            return
        }
        let fraudSignalsEnabled = GiniBankUserDefaultsStorage.clientConfiguration?.fraudSignalsEnabled ?? false
        guard let ibans = FraudWarningIBANResolver.resolve(result: result,
                                                            extractionResult: extractionResult,
                                                            fraudSignalsEnabled: fraudSignalsEnabled) else {
            completion(result)
            return
        }
        /// Drop a second delivery that arrives while the first warning is still on screen; replacing the parked tuple would null the first coordinator's weak delegate and leave its buttons inert.
        guard fraudWarningPresentation == nil else { return }
        let coordinator = FraudWarningCoordinator(qrIBAN: ibans.qrIBAN,
                                                  printedIBAN: ibans.printedIBAN,
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

    func fraudWarningCoordinatorDidCancel(_: FraudWarningCoordinator) {
        guard takeFraudWarningPresentation() != nil else { return }
        screenAPINavigationController.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.restorePresenterAccessibility()
            self.resultsDelegate?.giniCaptureDidCancelAnalysis()
            self.documentService.resetToInitialState()
        }
    }

    func fraudWarningCoordinatorDidProceed(_ coordinator: FraudWarningCoordinator) {
        guard let pending = takeFraudWarningPresentation() else { return }
        pending.result.extractions = ChosenIBANExtractions.apply(pending.result.extractions,
                                                                 chosenIBAN: coordinator.viewModel.selectedIBAN?.iban)
        screenAPINavigationController.dismiss(animated: true) { [weak self] in
            self?.restorePresenterAccessibility()
            pending.completion(pending.result)
        }
    }

    private func restorePresenterAccessibility() {
        screenAPINavigationController.view.accessibilityElementsHidden = false
        UIAccessibility.post(notification: .screenChanged,
                             argument: screenAPINavigationController.view)
    }

    private func takeFraudWarningPresentation() -> (coordinator: FraudWarningCoordinator,
                                                    result: AnalysisResult,
                                                    completion: (AnalysisResult) -> Void)? {
        let presentation = fraudWarningPresentation
        fraudWarningPresentation = nil
        return presentation
    }
}
