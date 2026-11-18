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

    @Test("delegate cancel is a no-op when no presentation is parked")
    func cancelWithoutParkedPresentationIsNoOp() {
        _GINIBANKAPILIBRARY_DISABLE_KEYCHAIN_PRECONDITION_FAILURE = true

        let coordinator = GiniBankNetworkingScreenApiCoordinator(alternativeTokenSource: StubTokenSource(),
                                                                 resultsDelegate: StubResultsDelegate(),
                                                                 configuration: GiniBankConfiguration(),
                                                                 documentMetadata: nil,
                                                                 trackingDelegate: nil)
        let dummy = FraudWarningCoordinator(qrIBAN: "", printedIBAN: "", delegate: nil)

        coordinator.fraudWarningCoordinatorDidCancel(dummy)

        #expect(coordinator.fraudWarningPresentation == nil)
    }

    @Test("a second delivery while a presentation is parked is dropped (first-wins)")
    func duplicateDeliveryDoesNotReplaceParkedTuple() {
        _GINIBANKAPILIBRARY_DISABLE_KEYCHAIN_PRECONDITION_FAILURE = true

        let configuration = GiniBankConfiguration()
        configuration.fraudWarningEnabled = true

        let coordinator = GiniBankNetworkingScreenApiCoordinator(alternativeTokenSource: StubTokenSource(),
                                                                 resultsDelegate: StubResultsDelegate(),
                                                                 configuration: configuration,
                                                                 documentMetadata: nil,
                                                                 trackingDelegate: nil)

        let parkedCoordinator = FraudWarningCoordinator(qrIBAN: "first-qr",
                                                        printedIBAN: "first-printed",
                                                        delegate: nil)
        let parkedResult = AnalysisResult(extractions: [:], images: [], candidates: [:])
        coordinator.fraudWarningPresentation = (coordinator: parkedCoordinator,
                                                result: parkedResult,
                                                completion: { _ in })

        var secondCompletionFired = false
        coordinator.presentFraudWarningIfEnabled(result: parkedResult) { _ in
            secondCompletionFired = true
        }

        #expect(coordinator.fraudWarningPresentation?.coordinator === parkedCoordinator,
                "First presentation's coordinator must remain parked")
        #expect(secondCompletionFired == false,
                "Second delivery's completion must be dropped, not invoked")
    }

    @Test("delegate proceed is a no-op when no presentation is parked")
    func proceedWithoutParkedPresentationIsNoOp() {
        _GINIBANKAPILIBRARY_DISABLE_KEYCHAIN_PRECONDITION_FAILURE = true

        let coordinator = GiniBankNetworkingScreenApiCoordinator(alternativeTokenSource: StubTokenSource(),
                                                                 resultsDelegate: StubResultsDelegate(),
                                                                 configuration: GiniBankConfiguration(),
                                                                 documentMetadata: nil,
                                                                 trackingDelegate: nil)
        let dummy = FraudWarningCoordinator(qrIBAN: "", printedIBAN: "", delegate: nil)

        coordinator.fraudWarningCoordinatorDidProceed(dummy)

        #expect(coordinator.fraudWarningPresentation == nil)
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
