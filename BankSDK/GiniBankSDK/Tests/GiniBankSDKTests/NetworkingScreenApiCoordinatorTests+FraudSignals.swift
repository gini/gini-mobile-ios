//
//  NetworkingScreenApiCoordinatorTests+FraudSignals.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import Foundation
@testable import GiniBankAPILibrary
@testable import GiniBankSDK
@testable import GiniCaptureSDK

@Suite("Fraud signals / boundary + feedback hygiene")
struct FraudSignalBoundaryTests {

    // MARK: Fixture helpers

    private func qrPrintedIbanMismatchGroup() -> [Extraction] {
        [
            Extraction(box: nil, candidates: nil, entity: "text",
                       value: "QR_PRINTED_IBAN_MISMATCH", name: "signalCode"),
            Extraction(box: nil, candidates: nil, entity: "text",
                       value: "CHECK", name: "severity"),
            Extraction(box: nil, candidates: nil, entity: "iban",
                       value: "DE89370400440532013000", name: "iban")
        ]
    }

    private func ibanCountryMismatchGroup() -> [Extraction] {
        [
            Extraction(box: nil, candidates: nil, entity: "text",
                       value: "IBAN_COUNTRY_MISMATCH", name: "signalCode"),
            Extraction(box: nil, candidates: nil, entity: "text",
                       value: "STOP", name: "severity"),
            Extraction(box: nil, candidates: nil, entity: "iban",
                       value: "GB29NWBK60161331926819", name: "iban"),
            Extraction(box: nil, candidates: nil, entity: "text",
                       value: "DE", name: "creditorCountry")
        ]
    }

    private func resultWithFraudSignals() -> ExtractionResult {
        let amount = Extraction(box: nil,
                                candidates: nil,
                                entity: "amount",
                                value: "1200.00:EUR",
                                name: "amountToPay")
        let result = ExtractionResult(extractions: [amount], candidates: [:])
        result.fraudSignals = [qrPrintedIbanMismatchGroup(),
                               ibanCountryMismatchGroup()]
        return result
    }

    // MARK: - AnalysisResult boundary

    @Test("AnalysisResult carries no fraud-signal keys when the source ExtractionResult does")
    func analysisResultHasNoFraudSignalKeysWhenFraudSignalsPresent() {
        let extractionResult = resultWithFraudSignals()

        let extractionsDict: [String: Extraction] = Dictionary(
            uniqueKeysWithValues: extractionResult.extractions.compactMap {
                guard let name = $0.name else { return nil }
                return (name, $0)
            }
        )
        let analysisResult = AnalysisResult(extractions: extractionsDict,
                                            lineItems: extractionResult.lineItems,
                                            images: [],
                                            candidates: extractionResult.candidates)

        #expect(analysisResult.extractions["signalCode"] == nil,
                "AnalysisResult.extractions must not carry 'signalCode' when fraud signals are present")
        #expect(analysisResult.extractions["severity"] == nil,
                "AnalysisResult.extractions must not carry 'severity' when fraud signals are present")
        #expect(analysisResult.extractions["creditorCountry"] == nil,
                "AnalysisResult.extractions must not carry 'creditorCountry' when fraud signals are present")
        #expect(analysisResult.candidates.isEmpty,
                "AnalysisResult.candidates must not grow from fraud signals")
        #expect(analysisResult.extractions.keys.sorted() == ["amountToPay"],
                "Only the top-level extractions should survive — fraud data must not leak")
    }

    // MARK: - feedback hygiene

    @Test("stripFraudSignals removes the fraudSignals key and keeps every sibling")
    func stripFraudSignalsRemovesFraudKeyFromCompoundExtractions() {
        let dict: [String: [[Extraction]]] = [
            "lineItems": [[Extraction(box: nil, candidates: nil, entity: "amount",
                                      value: "1:EUR", name: "baseGross")]],
            GiniBankConfiguration.fraudSignalsFeedbackKey: [qrPrintedIbanMismatchGroup()]
        ]

        let stripped = GiniBankConfiguration.stripFraudSignals(dict)

        #expect(Set(stripped?.keys ?? [:].keys) == Set(["lineItems"]),
                "stripFraudSignals must drop the fraudSignals key and keep everything else")
    }

    @Test("stripFraudSignals returns nil when the input is nil")
    func stripFraudSignalsPassesThroughNil() {
        #expect(GiniBankConfiguration.stripFraudSignals(nil) == nil)
    }

    @Test("stripFraudSignals is a no-op when the fraudSignals key is already absent")
    func stripFraudSignalsIsNoOpWhenAbsent() {
        let dict: [String: [[Extraction]]] = [
            "lineItems": [[Extraction(box: nil, candidates: nil, entity: "amount",
                                      value: "1:EUR", name: "baseGross")]]
        ]

        let stripped = GiniBankConfiguration.stripFraudSignals(dict)

        #expect(stripped?.keys.sorted() == ["lineItems"])
    }

    @Test("cleanup(paymentRecipient:…) never emits fraudSignals in its feedback payload")
    func cleanupWithPaymentRecipientFeedbackPayloadHasNoFraudSignals() {
        let configuration = GiniBankConfiguration()
        let serviceMock = DocumentServiceMock()
        configuration.documentService = serviceMock
        configuration.lineItems = [[Extraction(box: nil, candidates: nil, entity: "amount",
                                               value: "1:EUR", name: "baseGross")]]

        configuration.cleanup(paymentRecipient: "Acme GmbH",
                              paymentReference: "REF",
                              paymentPurpose: "Invoice",
                              iban: "DE89370400440532013000",
                              bic: "COBADEFFXXX",
                              amountToPay: ExtractionAmount(value: Decimal(99.99), currency: .EUR))

        #expect(serviceMock.sendFeedbackCallCount == 1)
        #expect(serviceMock.capturedCompoundExtractions?[GiniBankConfiguration.fraudSignalsFeedbackKey] == nil,
                "cleanup(paymentRecipient:…) must never emit fraudSignals in feedback")
    }

    @Test("CX sendTransferSummary(extractions:) never emits fraudSignals in its feedback payload")
    func cxTransferSummaryFeedbackPayloadHasNoFraudSignals() {
        let configuration = GiniBankConfiguration()
        let serviceMock = DocumentServiceMock()
        configuration.documentService = serviceMock
        configuration.productTag = .cxExtractions

        configuration.sendTransferSummary(extractions: ["iban": "GB29NWBK60161331926819",
                                                        "bic": "NWBKGB2L"])

        #expect(serviceMock.sendFeedbackCallCount == 1)
        #expect(serviceMock.capturedCompoundExtractions?[GiniBankConfiguration.fraudSignalsFeedbackKey] == nil,
                "CX sendTransferSummary(extractions:) must never emit fraudSignals in feedback")
    }

    @Test("SEPA sendTransferSummary(extractions:) never emits fraudSignals in its feedback payload")
    func sepaTransferSummaryFeedbackPayloadHasNoFraudSignals() {
        let configuration = GiniBankConfiguration()
        let serviceMock = DocumentServiceMock()
        configuration.documentService = serviceMock
        configuration.productTag = .sepaExtractions
        configuration.lineItems = [[Extraction(box: nil, candidates: nil, entity: "amount",
                                               value: "1:EUR", name: "baseGross")]]

        configuration.sendTransferSummary(extractions: ["iban": "DE89370400440532013000",
                                                        "bic": "COBADEFFXXX",
                                                        "amountToPay": "950.00:EUR"])

        #expect(serviceMock.sendFeedbackCallCount == 1)
        #expect(serviceMock.capturedCompoundExtractions?[GiniBankConfiguration.fraudSignalsFeedbackKey] == nil,
                "SEPA sendTransferSummary(extractions:) must never emit fraudSignals in feedback")
    }
}
