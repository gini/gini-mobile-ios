//
//  CXTransferSummaryTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankSDK
@testable import GiniCaptureSDK
@testable import GiniBankAPILibrary

// MARK: - Tests

final class CXTransferSummaryTests: XCTestCase {

    private var configuration: GiniBankConfiguration!
    private var documentServiceMock: DocumentServiceMock!

    override func setUp() {
        super.setUp()
        configuration = GiniBankConfiguration()
        documentServiceMock = DocumentServiceMock()
        configuration.documentService = documentServiceMock
    }

    override func tearDown() {
        configuration = nil
        documentServiceMock = nil
        super.tearDown()
    }

    // MARK: - CX routing (productTag == .cxExtractions)

    func testCXTransferSummaryCallsSendFeedbackOnce() {
        configuration.productTag = .cxExtractions

        configuration.sendTransferSummary(extractions: ["iban": "GB29NWBK60161331926819",
                                                 "bic": "NWBKGB2L"])

        XCTAssertEqual(documentServiceMock.sendFeedbackCallCount, 1,
                       "sendFeedback must be called exactly once")
    }

    func testCXTransferSummaryUsesEmptyFlatExtractions() {
        configuration.productTag = .cxExtractions

        configuration.sendTransferSummary(extractions: ["iban": "GB29NWBK60161331926819"])

        XCTAssertEqual(documentServiceMock.capturedFlatExtractions?.count, 0,
                       "Flat extractions must be empty for CX — all data is in compoundExtractions")
    }

    func testCXTransferSummaryPlacesFieldsUnderCrossBorderPaymentKey() throws {
        configuration.productTag = .cxExtractions
        let fields: [String: String] = ["iban": "GB29NWBK60161331926819",
                                        "bic": "NWBKGB2L",
                                        "currency": "GBP"]

        configuration.sendTransferSummary(extractions: fields)

        let compound = try XCTUnwrap(documentServiceMock.capturedCompoundExtractions,
                                     "UpdatedCompoundExtractions must not be nil")
        let group = try XCTUnwrap(compound["crossBorderPayment"],
                                  "Compound must contain a 'crossBorderPayment' key")
        let capturedExtractions = try XCTUnwrap(group.first, "First group must exist")
        XCTAssertEqual(capturedExtractions.count, fields.count,
                       "Number of extractions must match number of input fields")

        for extraction in capturedExtractions {
            let name = try XCTUnwrap(extraction.name)
            let expectedValue = try XCTUnwrap(fields[name],
                                              "Field '\(name)' not found in input")
            XCTAssertEqual(extraction.value, expectedValue,
                           "Extraction value for '\(name)' must match confirmed input")
        }
    }

    func testCXTransferSummaryDoesNotProduceFlatExtractions() {
        configuration.productTag = .cxExtractions

        configuration.sendTransferSummary(extractions: ["iban": "GB29NWBK60161331926819"])

        XCTAssertEqual(documentServiceMock.capturedFlatExtractions?.count, 0,
                       "CX must not produce any flat extractions")
    }

    // MARK: - SEPA routing (productTag != .cxExtractions)

    func testSepaGenericMethodSendsAsFlatExtractions() {
        configuration.productTag = .sepaExtractions
        let extractions = ["iban": "DE89370400440532013000",
                           "bic": "COBADEFFXXX"]
        configuration.sendTransferSummary(extractions: extractions)

        XCTAssertGreaterThan(documentServiceMock.capturedFlatExtractions?.count ?? 0, 0,
                             "SEPA path must produce non-empty flat extractions")
        XCTAssertNil(documentServiceMock.capturedCompoundExtractions?["crossBorderPayment"],
                     "SEPA path must not produce a 'crossBorderPayment' compound key")
    }

    // MARK: - SEPA named overload unaffected

    func testSepaNamedOverloadDelegatesCorrectly() {
        configuration.productTag = .sepaExtractions

        configuration.sendTransferSummary(paymentRecipient: "Test GmbH",
                                   paymentReference: "REF-001",
                                   paymentPurpose: "Invoice",
                                   iban: "DE89370400440532013000",
                                   bic: "COBADEFFXXX",
                                   amountToPay: ExtractionAmount(value: 100.0, currency: .EUR))

        XCTAssertEqual(documentServiceMock.sendFeedbackCallCount, 1)
        XCTAssertGreaterThan(documentServiceMock.capturedFlatExtractions?.count ?? 0, 0,
                             "SEPA named overload must produce non-empty flat extractions")
        XCTAssertNil(documentServiceMock.capturedCompoundExtractions?["crossBorderPayment"],
                     "SEPA named overload must not produce a 'crossBorderPayment' key")
    }
}
