//
//  GiniBankNetworkingScreenApiCoordinator+FraudMismatch.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//
//  Spike PP-3938 — intercepts analysis results before they are delivered
//  to the host app and, if an IBAN mismatch is detected, presents the
//  mismatch screen with the IBAN picker bottom sheet on top. Hands off
//  the result to the delegate once the user chose (or cancelled).
//
//  Spike constraints:
//    - Hardcoded detection (always "mismatch") so the screen is always shown.
//    - Hardcoded placeholder QR / printed IBAN strings.
//    - Cancel/Continue both deliver the original (unmodified) result.
//

import Foundation
import UIKit
import GiniCaptureSDK

extension GiniBankNetworkingScreenApiCoordinator {

    func deliverAnalysisResult(_ result: AnalysisResult) {
        presentMismatchIfNeeded(for: result) { [weak self] finalResult in
            self?.resultsDelegate?.giniCaptureAnalysisDidFinishWith(result: finalResult)
        }
    }

    private func presentMismatchIfNeeded(for result: AnalysisResult,
                                        completion: @escaping (AnalysisResult) -> Void) {
        guard shouldShowMismatch(for: result) else {
            completion(result)
            return
        }

        let hostingVC = MismatchHostingController(
            qrIBAN: "PL12 1000 0111 0100 1000",
            printedIBAN: "DE89 3704 0044 0532 0130 00",
            onCancel: { [weak self] in
                self?.screenAPINavigationController.dismiss(animated: true) {
                    completion(result)
                }
            },
            onContinue: { [weak self] _ in
                self?.screenAPINavigationController.dismiss(animated: true) {
                    completion(result)
                }
            }
        )
        screenAPINavigationController.present(hostingVC, animated: true)
    }

    private func shouldShowMismatch(for result: AnalysisResult) -> Bool {
        // Spike PP-3938: hardcoded true so the mismatch screen is always shown.
        // Replace with real QR-vs-printed IBAN comparison when productionizing.
        return true
    }
}
