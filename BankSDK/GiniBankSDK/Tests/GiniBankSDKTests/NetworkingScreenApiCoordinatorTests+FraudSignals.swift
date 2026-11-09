//
//  NetworkingScreenApiCoordinatorTests+FraudSignals.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

@testable import GiniBankAPILibrary
@testable import GiniBankSDK
@testable import GiniCaptureSDK
import XCTest

// MARK: - Fraud-signal boundary + feedback hygiene

extension NetworkingScreenApiCoordinatorTests {

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

    func testAnalysisResultHasNoFraudSignalKeysWhenFraudSignalsPresent() {
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

        XCTAssertNil(analysisResult.extractions["signalCode"],
                     "AnalysisResult.extractions must not carry 'signalCode' when fraud signals are present")
        XCTAssertNil(analysisResult.extractions["severity"],
                     "AnalysisResult.extractions must not carry 'severity' when fraud signals are present")
        XCTAssertNil(analysisResult.extractions["creditorCountry"],
                     "AnalysisResult.extractions must not carry 'creditorCountry' when fraud signals are present")
        XCTAssertTrue(analysisResult.candidates.isEmpty,
                      "AnalysisResult.candidates must not grow from fraud signals")
        XCTAssertEqual(analysisResult.extractions.keys.sorted(), ["amountToPay"],
                       "Only the top-level extractions should survive — fraud data must not leak")
    }

    // MARK: - feedback hygiene

    func testStripFraudSignalsRemovesFraudKeyFromCompoundExtractions() {
        let dict: [String: [[Extraction]]] = [
            "lineItems": [[Extraction(box: nil, candidates: nil, entity: "amount",
                                      value: "1:EUR", name: "baseGross")]],
            GiniBankConfiguration.fraudSignalsFeedbackKey: [qrPrintedIbanMismatchGroup()]
        ]

        let stripped = GiniBankConfiguration.stripFraudSignals(dict)

        XCTAssertEqual(Set(stripped?.keys ?? [:].keys), Set(["lineItems"]),
                       "stripFraudSignals must drop the fraudSignals key and keep everything else")
    }

    func testStripFraudSignalsPassesThroughNil() {
        XCTAssertNil(GiniBankConfiguration.stripFraudSignals(nil))
    }

    func testStripFraudSignalsIsNoOpWhenAbsent() {
        let dict: [String: [[Extraction]]] = [
            "lineItems": [[Extraction(box: nil, candidates: nil, entity: "amount",
                                      value: "1:EUR", name: "baseGross")]]
        ]

        let stripped = GiniBankConfiguration.stripFraudSignals(dict)

        XCTAssertEqual(stripped?.keys.sorted(), ["lineItems"])
    }

    func testCleanupWithPaymentRecipientFeedbackPayloadHasNoFraudSignals() {
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

        XCTAssertEqual(serviceMock.sendFeedbackCallCount, 1)
        XCTAssertNil(serviceMock.capturedCompoundExtractions?[GiniBankConfiguration.fraudSignalsFeedbackKey],
                     "cleanup(paymentRecipient:…) must never emit fraudSignals in feedback")
    }

    func testCXTransferSummaryFeedbackPayloadHasNoFraudSignals() {
        let configuration = GiniBankConfiguration()
        let serviceMock = DocumentServiceMock()
        configuration.documentService = serviceMock
        configuration.productTag = .cxExtractions

        configuration.sendTransferSummary(extractions: ["iban": "GB29NWBK60161331926819",
                                                        "bic": "NWBKGB2L"])

        XCTAssertEqual(serviceMock.sendFeedbackCallCount, 1)
        XCTAssertNil(serviceMock.capturedCompoundExtractions?[GiniBankConfiguration.fraudSignalsFeedbackKey],
                     "CX sendTransferSummary(extractions:) must never emit fraudSignals in feedback")
    }

    func testSEPATransferSummaryFeedbackPayloadHasNoFraudSignals() {
        let configuration = GiniBankConfiguration()
        let serviceMock = DocumentServiceMock()
        configuration.documentService = serviceMock
        configuration.productTag = .sepaExtractions
        configuration.lineItems = [[Extraction(box: nil, candidates: nil, entity: "amount",
                                               value: "1:EUR", name: "baseGross")]]

        configuration.sendTransferSummary(extractions: ["iban": "DE89370400440532013000",
                                                        "bic": "COBADEFFXXX",
                                                        "amountToPay": "950.00:EUR"])

        XCTAssertEqual(serviceMock.sendFeedbackCallCount, 1)
        XCTAssertNil(serviceMock.capturedCompoundExtractions?[GiniBankConfiguration.fraudSignalsFeedbackKey],
                     "SEPA sendTransferSummary(extractions:) must never emit fraudSignals in feedback")
    }
}
