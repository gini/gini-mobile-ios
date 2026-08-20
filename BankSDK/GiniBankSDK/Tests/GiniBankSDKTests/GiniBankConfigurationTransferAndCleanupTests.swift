//
//  GiniBankConfigurationTransferAndCleanupTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import Testing
import UIKit
import GiniBankAPILibrary
@testable import GiniBankSDK
@testable import GiniCaptureSDK

extension GiniConfigurationSharedStateSuite {

    /**
     Fills the remaining coverage gaps of `GiniBankConfiguration`:
     `updateConfiguration(withCaptureConfiguration:)`, `updateFont(_:for:)`,
     the parameterized `cleanup(...)` overload and the Skonto transfer summary
     (`sendTransferSummaryWithSkonto` and its compound-extraction helpers).

     Nested in the shared-state suite because `updateConfiguration` writes into
     `GiniBankConfiguration.shared`.
     */
    @Suite("GiniBankConfiguration transfer-back, cleanup and Skonto summary")
    struct GiniBankConfigurationTransferAndCleanupTests {

        // MARK: - updateFont

        @Test("Updating a font stores it for the given text style")
        func updateFontStoresCustomFont() {
            let configuration = GiniBankConfiguration()
            let customFont = UIFont.systemFont(ofSize: 33)

            configuration.updateFont(customFont, for: .body)

            #expect(configuration.textStyleFonts[.body] == customFont)
        }

        // MARK: - updateConfiguration(withCaptureConfiguration:)

        @Test("Updating from a capture configuration copies the flags back into the shared bank configuration")
        func updateConfigurationCopiesCaptureFlagsIntoShared() {
            /// Swap in a fresh shared instance so the mutations never leak
            /// into other suites; restore the original at the end.
            let originalShared = GiniBankConfiguration.shared
            GiniBankConfiguration.shared = GiniBankConfiguration()
            defer { GiniBankConfiguration.shared = originalShared }

            let captureConfiguration = GiniConfiguration()
            captureConfiguration.statusBarStyle = .darkContent
            captureConfiguration.multipageEnabled = true
            captureConfiguration.openWithEnabled = true
            captureConfiguration.qrCodeScanningEnabled = true
            captureConfiguration.onlyQRCodeScanningEnabled = true
            captureConfiguration.fileImportSupportedTypes = .pdf
            captureConfiguration.flashToggleEnabled = true
            captureConfiguration.flashOnByDefault = true
            captureConfiguration.onboardingShowAtLaunch = true
            captureConfiguration.onboardingShowAtFirstLaunch = false
            captureConfiguration.shouldShowSupportedFormatsScreen = false
            captureConfiguration.shouldShowDragAndDropTutorial = false
            captureConfiguration.transactionDocsEnabled = false
            captureConfiguration.entryPoint = .field
            captureConfiguration.debugModeOn = true
            captureConfiguration.giniErrorLoggerIsOn = false
            captureConfiguration.productTag = .cxExtractions

            GiniBankConfiguration.shared.updateConfiguration(withCaptureConfiguration: captureConfiguration)

            let shared = GiniBankConfiguration.shared
            #expect(shared.statusBarStyle == .darkContent)
            #expect(shared.multipageEnabled)
            #expect(shared.openWithEnabled)
            #expect(shared.qrCodeScanningEnabled)
            #expect(shared.onlyQRCodeScanningEnabled)
            #expect(shared.fileImportSupportedTypes == .pdf)
            #expect(shared.flashToggleEnabled)
            #expect(shared.flashOnByDefault)
            #expect(shared.onboardingShowAtLaunch)
            #expect(!shared.onboardingShowAtFirstLaunch)
            #expect(!shared.shouldShowSupportedFormatsScreen)
            #expect(!shared.shouldShowDragAndDropTutorial)
            #expect(!shared.transactionDocsEnabled)
            #expect(shared.entryPoint == .field)
            #expect(shared.debugModeOn)
            #expect(!shared.giniErrorLoggerIsOn)
            #expect(shared.productTag == .cxExtractions)
        }

        // MARK: - cleanup(paymentRecipient:...)

        @Test("Cleanup sends feedback with line items and releases the document service")
        func cleanupSendsFeedbackWithLineItems() {
            let configuration = GiniBankConfiguration()
            let documentService = DocumentServiceMock()
            configuration.documentService = documentService
            configuration.lineItems = [[makeExtraction(name: "quantity", value: "1")]]

            configuration.cleanup(paymentRecipient: "Acme GmbH",
                                  paymentReference: "REF-2026-001",
                                  paymentPurpose: "Invoice March",
                                  iban: "DE89370400440532013000",
                                  bic: "COBADEFFXXX",
                                  amountToPay: ExtractionAmount(value: 99.99, currency: .EUR))

            #expect(documentService.sendFeedbackCallCount == 1)
            #expect(documentService.capturedFlatExtractions?.count == 6,
                    "Recipient, reference, purpose, IBAN, BIC and amount should be sent")
            #expect(documentService.capturedCompoundExtractions?["lineItems"] != nil,
                    "The stored line items must be forwarded as compound extractions")
            #expect(documentService.resetToInitialStateCallCount == 1)
            #expect(configuration.documentService == nil,
                    "Cleanup must release the document service")
            #expect(configuration.lineItems == nil,
                    "Cleanup must release the stored line items")
        }

        @Test("Cleanup without line items sends feedback without compound extractions")
        func cleanupWithoutLineItemsSendsPlainFeedback() {
            let configuration = GiniBankConfiguration()
            let documentService = DocumentServiceMock()
            configuration.documentService = documentService

            configuration.cleanup(paymentRecipient: "Acme GmbH",
                                  paymentReference: "REF-2026-002",
                                  paymentPurpose: "Invoice April",
                                  iban: "DE89370400440532013000",
                                  bic: "COBADEFFXXX",
                                  amountToPay: ExtractionAmount(value: 12.50, currency: .EUR))

            #expect(documentService.sendFeedbackCallCount == 1)
            #expect(documentService.capturedCompoundExtractions == nil)
            #expect(configuration.documentService == nil)
        }

        @Test("Cleanup without a document service is a safe no-op")
        func cleanupWithoutDocumentServiceIsNoOp() {
            let configuration = GiniBankConfiguration()
            configuration.lineItems = [[makeExtraction(name: "quantity", value: "1")]]

            configuration.cleanup(paymentRecipient: "Acme GmbH",
                                  paymentReference: "REF-2026-003",
                                  paymentPurpose: "Invoice May",
                                  iban: "DE89370400440532013000",
                                  bic: "COBADEFFXXX",
                                  amountToPay: ExtractionAmount(value: 1, currency: .EUR))

            #expect(configuration.lineItems != nil,
                    "Without a document service the stored state must stay untouched")
        }

        // MARK: - Skonto transfer summary

        @Test("Skonto transfer summary sends the calculated discounts and line items")
        func skontoTransferSummarySendsCalculatedDiscounts() throws {
            let configuration = GiniBankConfiguration()
            let documentService = DocumentServiceMock()
            configuration.documentService = documentService

            let extractionResult = try ExtractionResultFixture.load(named: "skontoDiscounts")
            configuration.skontoDiscounts = extractionResult.skontoDiscounts
            configuration.lineItems = [[makeExtraction(name: "quantity", value: "2")]]

            /// The guard only passes when the amount matches the fixture's
            /// `skontoAmountToPayCalculated` value, so derive it from the fixture.
            let amountToPayString = try #require(configuration.skontoDiscounts?.first?
                .first { $0.name == "skontoAmountToPayCalculated" }?.value)
            let amountExtraction = makeExtraction(name: "amountToPay", value: amountToPayString)

            configuration.sendTransferSummaryWithSkonto(amountToPayExtraction: amountExtraction,
                                                        amountToPayString: amountToPayString)

            #expect(documentService.sendSkontoFeedbackCallCount == 1)
            #expect(documentService.capturedSkontoRetryCount == 3)
            #expect(documentService.capturedSkontoFlatExtractions?.count == 1)

            let compoundExtractions = try #require(documentService.capturedSkontoCompoundExtractions)
            let skontoGroup = try #require(compoundExtractions["skontoDiscounts"]?.first)
            let sentNames = Set(skontoGroup.compactMap { $0.name })
            #expect(sentNames == ["skontoAmountToPayCalculated",
                                  "skontoPercentageDiscountedCalculated",
                                  "skontoDueDateCalculated"],
                    "Only the calculated Skonto fields should be sent back")
            #expect(compoundExtractions["lineItems"] != nil,
                    "Stored line items must be merged into the Skonto feedback")
        }

        @Test("Skonto transfer summary without stored line items omits them")
        func skontoTransferSummaryWithoutLineItemsOmitsThem() throws {
            let configuration = GiniBankConfiguration()
            let documentService = DocumentServiceMock()
            configuration.documentService = documentService

            let extractionResult = try ExtractionResultFixture.load(named: "skontoDiscounts")
            configuration.skontoDiscounts = extractionResult.skontoDiscounts
            let amountToPayString = try #require(configuration.skontoDiscounts?.first?
                .first { $0.name == "skontoAmountToPayCalculated" }?.value)
            let amountExtraction = makeExtraction(name: "amountToPay", value: amountToPayString)

            configuration.sendTransferSummaryWithSkonto(amountToPayExtraction: amountExtraction,
                                                        amountToPayString: amountToPayString)

            let compoundExtractions = try #require(documentService.capturedSkontoCompoundExtractions)
            #expect(compoundExtractions["lineItems"] == nil)
            #expect(compoundExtractions["skontoDiscounts"] != nil)
        }

        @Test("Skonto transfer summary is not sent when the amount does not match the calculated discount")
        func skontoTransferSummaryNotSentWhenAmountDiffers() throws {
            let configuration = GiniBankConfiguration()
            let documentService = DocumentServiceMock()
            configuration.documentService = documentService
            let extractionResult = try ExtractionResultFixture.load(named: "skontoDiscounts")
            configuration.skontoDiscounts = extractionResult.skontoDiscounts

            let amountExtraction = makeExtraction(name: "amountToPay", value: "9999.99:EUR")
            configuration.sendTransferSummaryWithSkonto(amountToPayExtraction: amountExtraction,
                                                        amountToPayString: "9999.99:EUR")

            #expect(documentService.sendSkontoFeedbackCallCount == 0,
                    "Feedback must only be sent when the Skonto discount was actually applied")
        }

        @Test("Skonto transfer summary is not sent without Skonto discounts")
        func skontoTransferSummaryNotSentWithoutDiscounts() {
            let configuration = GiniBankConfiguration()
            let documentService = DocumentServiceMock()
            configuration.documentService = documentService

            let amountExtraction = makeExtraction(name: "amountToPay", value: "10.00:EUR")
            configuration.sendTransferSummaryWithSkonto(amountToPayExtraction: amountExtraction,
                                                        amountToPayString: "10.00:EUR")

            #expect(documentService.sendSkontoFeedbackCallCount == 0)
        }

        // MARK: - Helpers

        private func makeExtraction(name: String,
                                    value: String) -> Extraction {
            Extraction(box: nil,
                       candidates: nil,
                       entity: name,
                       value: value,
                       name: name)
        }
    }
}
