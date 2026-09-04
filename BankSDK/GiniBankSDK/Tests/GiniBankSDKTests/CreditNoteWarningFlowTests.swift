//
//  CreditNoteWarningFlowTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import Testing
import UIKit
@testable import GiniBankAPILibrary
@testable import GiniBankSDK
@testable import GiniCaptureSDK

extension GiniConfigurationSharedStateSuite {

    /**
     Covers the credit-note gating paths of `GiniBankNetworkingScreenApiCoordinator`:
     `shouldProceedWithCreditNote`, `presentDocumentMarkedAsCreditNoteBottomSheet`
     and its proceed/cancel handlers. The full analysis flow is driven through the
     public `didReview` entry point using a synchronous stubbed network service,
     and presentations are observed through a spy navigation controller — no
     network and no window are involved.
     */
    @Suite("Credit-note warning flow in GiniBankNetworkingScreenApiCoordinator")
    @MainActor
    final class CreditNoteWarningFlowTests {

        private let savedSharedConfiguration: GiniBankConfiguration
        private let savedClientConfiguration: ClientConfiguration?

        private let configuration = GiniBankConfiguration()
        private let resultsDelegate = RecordingCaptureResultsDelegate()
        private let networkDelegate = MockCaptureNetworkDelegate()
        private let spyNavigationController = SpyNavigationController()

        init() {
            _GINIBANKAPILIBRARY_DISABLE_KEYCHAIN_PRECONDITION_FAILURE = true
            savedSharedConfiguration = GiniBankConfiguration.shared
            savedClientConfiguration = GiniBankUserDefaultsStorage.clientConfiguration
        }

        deinit {
            GiniBankConfiguration.shared = savedSharedConfiguration
            GiniBankUserDefaultsStorage.clientConfiguration = savedClientConfiguration
        }

        // MARK: - Sheet presentation (gating enabled)

        @Test("Credit-note document with both hint flags enabled presents the warning sheet")
        func presentsWarningSheetWhenHintsEnabled() async throws {
            let coordinator = try makeCoordinator(fixtureName: "extractionsContainerCreditNote",
                                                  globalHintEnabled: true,
                                                  clientHintEnabled: true)

            await analyzeDocumentAwaitingPresentation(with: coordinator)

            let sheet = try #require(spyNavigationController.presentedControllers.last
                                        as? CreditNoteWarningViewController,
                                     "The credit-note warning sheet should be presented")
            #expect(sheet.isModalInPresentation,
                    "The warning sheet should not be dismissible by swipe")
            #expect(spyNavigationController.pushedControllers.isEmpty,
                    "No feature screen should be pushed while the warning sheet is up")
            #expect(resultsDelegate.deliveredResults.isEmpty,
                    "Nothing should be delivered before the user decides")
            #expect(resultsDelegate.cancelCallCount == 0)
        }

        // MARK: - Proceed handler

        @Test("Proceeding from the warning sheet delivers a stripped credit-note result")
        func proceedDeliversStrippedResult() async throws {
            let coordinator = try makeCoordinator(fixtureName: "extractionsContainerCreditNote",
                                                  globalHintEnabled: true,
                                                  clientHintEnabled: true)

            await analyzeDocumentAwaitingPresentation(with: coordinator)

            let sheet = try #require(spyNavigationController.presentedControllers.last
                                        as? CreditNoteWarningViewController)

            /// Primary button is Cancel, secondary is Proceed (see `CreditNoteWarningViewController`).
            let delivered: AnalysisResult = await withCheckedContinuation { continuation in
                resultsDelegate.onResult = { continuation.resume(returning: $0) }
                sheet.didPressSecondary()
            }

            #expect(spyNavigationController.dismissCallCount == 1,
                    "The warning sheet should be dismissed on proceed")
            #expect(delivered.extractions["amountToPay"] == nil,
                    "amountToPay must not be delivered for a confirmed credit note")
            #expect(delivered.extractions["businessDocType"]?.value == "CreditNote",
                    "The remaining flat extractions should still be delivered")
            #expect(delivered.extractions["iban"] != nil,
                    "The remaining flat extractions should still be delivered")
            #expect(delivered.lineItems == nil,
                    "Compound line items must be stripped so Return Assistant never triggers")
            #expect(delivered.skontoDiscounts == nil,
                    "Skonto discounts must be stripped for a credit note")
            #expect(spyNavigationController.pushedControllers.isEmpty,
                    "The Return Assistant screen must not be shown for a confirmed credit note")
        }

        // MARK: - Cancel handler

        @Test("Cancelling the warning sheet cancels the capture flow without delivering")
        func cancelDismissesAndCancelsCapture() async throws {
            let coordinator = try makeCoordinator(fixtureName: "extractionsContainerCreditNote",
                                                  globalHintEnabled: true,
                                                  clientHintEnabled: true)

            await analyzeDocumentAwaitingPresentation(with: coordinator)

            let sheet = try #require(spyNavigationController.presentedControllers.last
                                        as? CreditNoteWarningViewController)

            sheet.didPressPrimary()

            #expect(spyNavigationController.dismissCallCount == 1,
                    "The warning sheet should be dismissed on cancel")
            #expect(resultsDelegate.cancelCallCount == 1,
                    "Cancelling the sheet should cancel the whole capture flow")
            #expect(resultsDelegate.deliveredResults.isEmpty,
                    "No result should be delivered after cancelling")
        }

        // MARK: - Gating disabled

        @Test("Credit-note document skips the sheet when a hint flag is disabled",
              arguments: [(global: true, client: false),
                          (global: false, client: true),
                          (global: false, client: false)])
        func skipsSheetWhenHintDisabled(flags: (global: Bool, client: Bool)) async throws {
            let coordinator = try makeCoordinator(fixtureName: "extractionsContainerCreditNote",
                                                  globalHintEnabled: flags.global,
                                                  clientHintEnabled: flags.client)

            await analyzeDocumentAwaitingPush(with: coordinator)

            #expect(spyNavigationController.presentedControllers.isEmpty,
                    "No credit-note warning sheet should appear when hints are disabled")
            #expect(spyNavigationController.pushedControllers.last is DigitalInvoiceViewController,
                    "The normal Return Assistant flow should continue unaffected")
        }

        @Test("Non-credit-note document never shows the warning sheet even with hints enabled")
        func skipsSheetForRegularInvoice() async throws {
            let coordinator = try makeCoordinator(fixtureName: "extractionsContainerInvoiceLineItems",
                                                  globalHintEnabled: true,
                                                  clientHintEnabled: true)

            await analyzeDocumentAwaitingPush(with: coordinator)

            #expect(spyNavigationController.presentedControllers.isEmpty,
                    "An invoice must not trigger the credit-note warning sheet")
            #expect(spyNavigationController.pushedControllers.last is DigitalInvoiceViewController,
                    "The Return Assistant screen should be shown for an invoice with line items")
        }

        // MARK: - Helpers

        private func makeCoordinator(fixtureName: String,
                                     globalHintEnabled: Bool,
                                     clientHintEnabled: Bool) throws -> GiniBankNetworkingScreenApiCoordinator {
            configuration.creditNoteHintEnabled = globalHintEnabled
            GiniBankUserDefaultsStorage.clientConfiguration =
                ClientConfiguration(creditNoteHintEnabled: clientHintEnabled)

            let extractionResult = try ExtractionResultFixture.load(named: fixtureName)
            let networkService = StubAnalysisCaptureNetworkService(extractionResult: extractionResult)
            let coordinator = GiniBankNetworkingScreenApiCoordinator(resultsDelegate: resultsDelegate,
                                                                     configuration: configuration,
                                                                     documentMetadata: nil,
                                                                     trackingDelegate: nil,
                                                                     captureNetworkService: networkService,
                                                                     configurationService: nil)
            coordinator.screenAPINavigationController = spyNavigationController
            return coordinator
        }

        /// Drives upload + analysis via `didReview` and suspends until something is presented.
        private func analyzeDocumentAwaitingPresentation(with coordinator: GiniBankNetworkingScreenApiCoordinator) async {
            let document = TestDocumentFactory.makeImageDocument()
            await withCheckedContinuation { continuation in
                spyNavigationController.onPresent = { [weak spyNavigationController] _ in
                    spyNavigationController?.onPresent = nil
                    continuation.resume()
                }
                coordinator.didReview(documents: [document], networkDelegate: networkDelegate)
            }
        }

        /// Drives upload + analysis via `didReview` and suspends until something is pushed.
        private func analyzeDocumentAwaitingPush(with coordinator: GiniBankNetworkingScreenApiCoordinator) async {
            let document = TestDocumentFactory.makeImageDocument()
            await withCheckedContinuation { continuation in
                spyNavigationController.onPush = { [weak spyNavigationController] _ in
                    spyNavigationController?.onPush = nil
                    continuation.resume()
                }
                coordinator.didReview(documents: [document], networkDelegate: networkDelegate)
            }
        }
    }
}
