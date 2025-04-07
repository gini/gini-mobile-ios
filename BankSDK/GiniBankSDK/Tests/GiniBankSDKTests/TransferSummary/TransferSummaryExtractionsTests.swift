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
        var instantPayment: String
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
        let match = extractions.first(where: { $0.name == name && (value == nil || $0.value == value) && (entity == nil || $0.entity == entity) })
        XCTAssertNotNil(match, "Expected extraction with name '\(name)', value '\(value ?? "*")', entity '\(entity ?? "*")' not found")
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

    func test_generateBasicExtractions_returnsCorrectExtractions() {
        let amount = ExtractionAmount(value: 99.99, currency: .EUR)
        let input = ExtractionInput(paymentRecipient: "Test AG",
                                    paymentReference: "REF-001",
                                    paymentPurpose: "Invoice March",
                                    iban: "DE89370400440532013000",
                                    bic: "COBADEFFXXX",
                                    amount: amount.formattedString(),
                                    instantPayment: "false")

        let extractions = generateExtractions(from: input)

        XCTAssertEqual(extractions.count, 7)
        assertExtractionExists(extractions, name: Field.paymentRecipient, value: "Test AG")
        assertExtractionExists(extractions, name: Field.amountToPay, value: amount.formattedString())
        assertExtractionExists(extractions, name: Field.instantPayment, value: "false")
    }

    func test_generateBasicExtractions_withEmptyStrings() {
        let input = ExtractionInput(paymentRecipient: "",
                                    paymentReference: "",
                                    paymentPurpose: "",
                                    iban: "",
                                    bic: "",
                                    amount: "",
                                    instantPayment: "")

        let extractions = generateExtractions(from: input)

        XCTAssertEqual(extractions.count, 7)
        XCTAssertTrue(extractions.allSatisfy { $0.value == "" })
    }

    func test_generateBasicExtractions_withInvalidIbanFormat() {
        let input = ExtractionInput(paymentRecipient: "Acme Inc",
                                    paymentReference: "INV123",
                                    paymentPurpose: "Payment",
                                    iban: "INVALID_IBAN",
                                    bic: "DEUTDEFF",
                                    amount: "123.00",
                                    instantPayment: "false")

        let extractions = generateExtractions(from: input)

        assertExtractionExists(extractions, name: Field.iban, value: "INVALID_IBAN")
        XCTAssertFalse(input.iban.hasPrefix("DE"), "IBAN should normally start with 'DE' in Germany")
    }

    func test_generateBasicExtractions_fieldCoverage() {
        let amount = ExtractionAmount(value: 50.00, currency: .EUR)
        let input = ExtractionInput(paymentRecipient: "Test AG",
                                    paymentReference: "REF-321",
                                    paymentPurpose: "Rent",
                                    iban: "DE44500105175407324931",
                                    bic: "INGDDEFFXXX",
                                    amount: amount.formattedString(),
                                    instantPayment: "true")

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

    func test_generateBasicExtractions_valueMapping() {
        let input = ExtractionInput(paymentRecipient: "Some Company",
                                    paymentReference: "Ref-0001",
                                    paymentPurpose: "Consulting Services",
                                    iban: "DE00123456780000000000",
                                    bic: "BANKDEFFXXX",
                                    amount: "123.45",
                                    instantPayment: "true")

        let extractions = generateExtractions(from: input)

        let expectedValues = [(Field.paymentRecipient, input.paymentRecipient),
                              (Field.paymentReference, input.paymentReference),
                              (Field.paymentPurpose, input.paymentPurpose),
                              (Field.iban, input.iban),
                              (Field.bic, input.bic),
                              (Field.amountToPay, input.amount),
                              (Field.instantPayment, input.instantPayment)]

        for (name, value) in expectedValues {
            assertExtractionExists(extractions, name: name, value: value)
        }
    }
}

