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
        let dummy = FraudWarningCoordinator(qrIBAN: "", printedIBAN: "")

        coordinator.fraudWarningCoordinatorDidProceed(dummy)

        #expect(coordinator.fraudWarningPresentation == nil)
    }

    @Test("toggle on: parks the delivery tuple and keeps the completion unfired")
    func toggleOnParksTupleAndDefersCompletion() async {
        _GINIBANKAPILIBRARY_DISABLE_KEYCHAIN_PRECONDITION_FAILURE = true

        let configuration = GiniBankConfiguration()
        configuration.fraudWarningEnabled = true

        let coordinator = GiniBankNetworkingScreenApiCoordinator(alternativeTokenSource: StubTokenSource(),
                                                                 resultsDelegate: StubResultsDelegate(),
                                                                 configuration: configuration,
                                                                 documentMetadata: nil,
                                                                 trackingDelegate: nil)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = coordinator.screenAPINavigationController
        window.makeKeyAndVisible()

        let input = AnalysisResult(extractions: [:], images: [], candidates: [:])
        var completionFired = false
        coordinator.presentFraudWarningIfEnabled(result: input) { _ in
            completionFired = true
        }

        #expect(coordinator.fraudWarningPresentation != nil)
        #expect(coordinator.fraudWarningPresentation?.coordinator is FraudWarningCoordinator)
        #expect(completionFired == false)

        try? await Task.sleep(nanoseconds: 100_000_000)
        window.isHidden = true
    }

    @Test("proceed with parked presentation delivers the parked result and clears the tuple")
    func proceedWithParkedPresentationDeliversOriginalResult() async {
        _GINIBANKAPILIBRARY_DISABLE_KEYCHAIN_PRECONDITION_FAILURE = true

        let coordinator = GiniBankNetworkingScreenApiCoordinator(alternativeTokenSource: StubTokenSource(),
                                                                 resultsDelegate: StubResultsDelegate(),
                                                                 configuration: GiniBankConfiguration(),
                                                                 documentMetadata: nil,
                                                                 trackingDelegate: nil)
        let parkedCoordinator = FraudWarningCoordinator(qrIBAN: "qr", printedIBAN: "pr")
        let parkedResult = AnalysisResult(extractions: ["iban": Extraction(box: nil,
                                                                           candidates: "ibans",
                                                                           entity: "iban",
                                                                           value: "parked-iban",
                                                                           name: "iban")],
                                          images: [],
                                          candidates: [:])

        var deliveredValue: String?
        coordinator.fraudWarningPresentation = (coordinator: parkedCoordinator,
                                                result: parkedResult,
                                                completion: { delivered in
            deliveredValue = delivered.extractions["iban"]?.value
        })

        coordinator.fraudWarningCoordinatorDidProceed(parkedCoordinator)
        try? await Task.sleep(nanoseconds: 300_000_000)

        #expect(coordinator.fraudWarningPresentation == nil)
        #expect(deliveredValue == "parked-iban")
    }

    @Test("cancel with parked presentation clears the tuple and fires giniCaptureDidCancelAnalysis")
    func cancelWithParkedPresentationFiresCancellation() async {
        _GINIBANKAPILIBRARY_DISABLE_KEYCHAIN_PRECONDITION_FAILURE = true

        let spy = CountingResultsDelegate()
        let coordinator = GiniBankNetworkingScreenApiCoordinator(alternativeTokenSource: StubTokenSource(),
                                                                 resultsDelegate: spy,
                                                                 configuration: GiniBankConfiguration(),
                                                                 documentMetadata: nil,
                                                                 trackingDelegate: nil)
        let parkedCoordinator = FraudWarningCoordinator(qrIBAN: "qr", printedIBAN: "pr")
        let parkedResult = AnalysisResult(extractions: [:], images: [], candidates: [:])
        coordinator.fraudWarningPresentation = (coordinator: parkedCoordinator,
                                                result: parkedResult,
                                                completion: { _ in })

        coordinator.fraudWarningCoordinatorDidCancel(parkedCoordinator)
        try? await Task.sleep(nanoseconds: 300_000_000)

        #expect(coordinator.fraudWarningPresentation == nil)
        #expect(spy.cancelCount >= 1)
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

private final class CountingResultsDelegate: GiniCaptureResultsDelegate {
    var cancelCount = 0
    func giniCaptureAnalysisDidFinishWith(result: AnalysisResult) {}
    func giniCaptureDidCancelAnalysis() { cancelCount += 1 }
    func giniCaptureDidEnterManually() {}
}
