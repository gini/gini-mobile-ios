//
//  GiniBankNetworkingScreenApiCoordinatorFraudWarningTests.swift
//  GiniBankSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

@testable import GiniBankAPILibrary
@testable import GiniBankSDK
@testable import GiniCaptureSDK
import Foundation
import Testing
import UIKit

/**
 Semantic-equivalence coverage for the fraud warning presentation seam in
 `GiniBankNetworkingScreenApiCoordinator+FraudWarning`. Locks R13's promise
 that `fraudWarningEnabled == false` leaves delivery untouched: completion
 fires synchronously with the identical result and no presentation state is
 parked.

 The toggle-ON path isn't covered here because it requires a running
 `screenAPINavigationController` — that's SDK-boot infrastructure covered
 by the follow-up ticket that replaces the stub IBANs with real extraction
 wiring.
 */
@Suite("GiniBankNetworkingScreenApiCoordinator+FraudWarning")
@MainActor
struct GiniBankNetworkingScreenApiCoordinatorFraudWarningTests {

    @Test("toggle off: completion fires synchronously with the input result and nothing is parked")
    func toggleOffDeliversSynchronouslyWithoutParking() {
        _GINIBANKAPILIBRARY_DISABLE_KEYCHAIN_PRECONDITION_FAILURE = true

        let configuration = GiniBankConfiguration()
        configuration.fraudWarningEnabled = false

        let coordinator = GiniBankNetworkingScreenApiCoordinator(alternativeTokenSource: StubTokenSource(),
                                                                 resultsDelegate: StubResultsDelegate(),
                                                                 configuration: configuration,
                                                                 documentMetadata: nil,
                                                                 trackingDelegate: nil)

        let input = AnalysisResult(extractions: ["iban": Extraction(box: nil,
                                                                    candidates: "ibans",
                                                                    entity: "iban",
                                                                    value: "DE89 3704 0044 0532 0130 00",
                                                                    name: "iban")],
                                   images: [],
                                   candidates: [:])

        var delivered: AnalysisResult?
        var invocationCount = 0
        coordinator.presentFraudWarningIfEnabled(result: input) { result in
            delivered = result
            invocationCount += 1
        }

        #expect(invocationCount == 1, "Completion must fire exactly once when the toggle is off")
        #expect(delivered?.extractions["iban"]?.value == input.extractions["iban"]?.value,
                "Delivered result must carry the original IBAN extraction unchanged")
        #expect(coordinator.fraudWarningPresentation == nil,
                "No presentation state should be parked when the toggle is off")
    }
}

private final class StubTokenSource: AlternativeTokenSource {
    func fetchToken(completion: @escaping (Result<Token, GiniError>) -> Void) {
        completion(.failure(.requestCancelled))
    }
}

private final class StubResultsDelegate: GiniCaptureResultsDelegate {
    func giniCaptureAnalysisDidFinishWith(result: AnalysisResult) {}
    func giniCaptureDidCancelAnalysis() {}
    func giniCaptureDidEnterManually() {}
}
