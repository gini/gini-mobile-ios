//
//  TransferSummaryExtractionsTests.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//


import XCTest
@testable import GiniBankSDK
@testable import GiniCaptureSDK
@testable import GiniBankAPILibrary

class TransferSummaryExtractionsTests: XCTestCase {

    let config = GiniBankConfiguration.shared

    struct ExtractionInput {
        var paymentRecipient: String
        var paymentReference: String
        var paymentPurpose: String
        var iban: String
        var bic: String
        var amount: String
        var instantPayment: Bool?
    }

    private func generateExtractions(from input: ExtractionInput) -> [Extraction] {
        return config.generateBasicExtractions(paymentRecipient: input.paymentRecipient,
                                               paymentReference: input.paymentReference,
                                               paymentPurpose: input.paymentPurpose,
                                               iban: input.iban,
                                               bic: input.bic,
                                               amountToPayString: input.amount,
                                               instantPayment: input.instantPayment)
    }

    private func assertExtractionExists(_ extractions: [Extraction],
                                        name: String,
                                        value: String? = nil,
                                        entity: String? = nil) {
        let match = extractions.first { extraction in
            let nameMatches = extraction.name == name
            let valueMatches = value == nil || extraction.value == value
            let entityMatches = entity == nil || extraction.entity == entity
            return nameMatches && valueMatches && entityMatches
        }
        let expectedMessage = """
                              Expected extraction with name '\(name)', \
                              value '\(value ?? "*")', \
                              entity '\(entity ?? "*")' not found
                              """
        XCTAssertNotNil(match, expectedMessage)
    }

    // MARK: - Field + Entity Constants

    enum Field {
        static let paymentRecipient = "paymentRecipient"
        static let paymentReference = "paymentReference"
        static let paymentPurpose = "paymentPurpose"
        static let iban = "iban"
        static let bic = "bic"
        static let amountToPay = "amountToPay"
        static let instantPayment = "instantPayment"
    }

    enum Entity {
        static let companyName = "companyname"
        static let reference = "reference"
        static let text = "text"
        static let iban = "iban"
        static let bic = "bic"
        static let amount = "amount"
        static let instantPayment = "instantPayment"
    }

    // MARK: - Tests

    func testGenerateBasicExtractionsReturnsCorrectExtractions() {
        let amount = ExtractionAmount(value: 99.99, currency: .EUR)
        let paymentRecipientName = "Otto"
        let input = ExtractionInput(paymentRecipient: paymentRecipientName,
                                    paymentReference: "REF-001",
                                    paymentPurpose: "Invoice March",
                                    iban: "DE89370400440532013000",
                                    bic: "COBADEFFXXX",
                                    amount: amount.formattedString(),
                                    instantPayment: false)

        let extractions = generateExtractions(from: input)

        XCTAssertEqual(extractions.count, 7)
        assertExtractionExists(extractions, name: Field.paymentRecipient, value: paymentRecipientName)
        assertExtractionExists(extractions, name: Field.amountToPay, value: amount.formattedString())
        assertExtractionExists(extractions, name: Field.instantPayment, value: "false")
    }

    func testGenerateBasicExtractionsWithEmptyStrings() {
        let input = ExtractionInput(paymentRecipient: "",
                                    paymentReference: "",
                                    paymentPurpose: "",
                                    iban: "",
                                    bic: "",
                                    amount: "")

        let extractions = generateExtractions(from: input)

        XCTAssertEqual(extractions.count, 6)
        XCTAssertTrue(extractions.allSatisfy { $0.value == "" })
    }

    func testGenerateBasicExtractionsWithInvalidIbanFormat() {
        let input = ExtractionInput(paymentRecipient: "Bonprix",
                                    paymentReference: "INV123",
                                    paymentPurpose: "Payment",
                                    iban: "INVALID_IBAN",
                                    bic: "DEUTDEFF",
                                    amount: "123.00",
                                    instantPayment: false)

        let extractions = generateExtractions(from: input)

        assertExtractionExists(extractions, name: Field.iban, value: "INVALID_IBAN")
        XCTAssertFalse(input.iban.hasPrefix("DE"), "IBAN should normally start with 'DE' in Germany")
    }

    func testGenerateBasicExtractionsFieldCoverage() {
        let amount = ExtractionAmount(value: 50.00, currency: .EUR)
        let input = ExtractionInput(paymentRecipient: "Tchibo",
                                    paymentReference: "REF-321",
                                    paymentPurpose: "Payment for coffee",
                                    iban: "DE44500105175407324931",
                                    bic: "INGDDEFFXXX",
                                    amount: amount.formattedString(),
                                    instantPayment: true)

        let extractions = generateExtractions(from: input)

        let expectedFields = [(Field.paymentRecipient, Entity.companyName),
                              (Field.paymentReference, Entity.reference),
                              (Field.paymentPurpose, Entity.text),
                              (Field.iban, Entity.iban),
                              (Field.bic, Entity.bic),
                              (Field.amountToPay, Entity.amount),
                              (Field.instantPayment, Entity.instantPayment)]

        for (name, entity) in expectedFields {
            assertExtractionExists(extractions, name: name, entity: entity)
        }
    }

    func testGenerateBasicExtractionsValueMapping() {
        let input = ExtractionInput(paymentRecipient: "Some Company",
                                    paymentReference: "Ref-0001",
                                    paymentPurpose: "Consulting Services",
                                    iban: "DE00123456780000000000",
                                    bic: "BANKDEFFXXX",
                                    amount: "123.45",
                                    instantPayment: true)

        let extractions = generateExtractions(from: input)

        let expectedValues = [(Field.paymentRecipient, input.paymentRecipient),
                              (Field.paymentReference, input.paymentReference),
                              (Field.paymentPurpose, input.paymentPurpose),
                              (Field.iban, input.iban),
                              (Field.bic, input.bic),
                              (Field.amountToPay, input.amount),
                              (Field.instantPayment, input.instantPayment == true ? "true" : "false")]

        for (name, value) in expectedValues {
            assertExtractionExists(extractions, name: name, value: value)
        }
    }
}

