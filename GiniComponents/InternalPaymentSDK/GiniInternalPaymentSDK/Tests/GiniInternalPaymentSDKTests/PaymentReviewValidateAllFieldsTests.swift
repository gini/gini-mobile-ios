//
//  PaymentReviewValidateAllFieldsTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import GiniHealthAPILibrary
import GiniUtilites
@testable import GiniInternalPaymentSDK

@Suite("PaymentReviewPaymentInformationObservableModel — validateAllFields")
@MainActor
struct PaymentReviewValidateAllFieldsTests {

    private func makeFullyPopulatedSUT() -> PaymentReviewPaymentInformationObservableModel {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.recipientInputState.text = "Gini GmbH"
        sut.ibanInputState.text = "DE89370400440532013000"
        sut.amountInputState.text = "12.50"
        sut.amountToPay = Price(value: 12.50, currencyCode: "EUR")
        sut.paymentPurposeInputState.text = "Invoice 2026"
        return sut
    }

    @Test("all valid fields returns true")
    func allValidFieldsReturnsTrue() {
        let sut = makeFullyPopulatedSUT()
        #expect(sut.validateAllFields() == true)
    }

    @Test("invalid recipient makes validateAllFields return false")
    func invalidRecipientFails() {
        let sut = makeFullyPopulatedSUT()
        sut.recipientInputState.text = ""
        #expect(sut.validateAllFields() == false)
    }

    @Test("invalid IBAN makes validateAllFields return false")
    func invalidIBANFails() {
        let sut = makeFullyPopulatedSUT()
        sut.ibanInputState.text = "INVALID"
        #expect(sut.validateAllFields() == false)
    }

    @Test("empty amount text makes validateAllFields return false")
    func emptyAmountTextFails() {
        let sut = makeFullyPopulatedSUT()
        sut.amountInputState.text = ""
        #expect(sut.validateAllFields() == false)
    }

    @Test("zero amount value makes validateAllFields return false")
    func zeroAmountValueFails() {
        let sut = makeFullyPopulatedSUT()
        sut.amountToPay = Price(value: 0, currencyCode: "EUR")
        #expect(sut.validateAllFields() == false)
    }

    @Test("empty purpose makes validateAllFields return false")
    func emptyPurposeFails() {
        let sut = makeFullyPopulatedSUT()
        sut.paymentPurposeInputState.text = ""
        #expect(sut.validateAllFields() == false)
    }

    @Test("all validators run even when first field is invalid")
    func allValidatorsRunNonShortCircuit() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        _ = sut.validateAllFields()

        // All four error properties must be set — proves validateAllFields
        // does not short-circuit after the first failure.
        #expect(sut.recipientError != nil)
        #expect(sut.ibanError != nil)
        #expect(sut.amountError != nil)
        #expect(sut.paymentPurposeError != nil)
    }

    @Test("errors are cleared on a subsequent successful call")
    func errorsAreClearedOnSuccess() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        _ = sut.validateAllFields() // seed errors

        sut.recipientInputState.text = "Gini GmbH"
        sut.ibanInputState.text = "DE89370400440532013000"
        sut.amountInputState.text = "12.50"
        sut.amountToPay = Price(value: 12.50, currencyCode: "EUR")
        sut.paymentPurposeInputState.text = "Invoice 2026"
        #expect(sut.validateAllFields() == true)

        #expect(sut.recipientError == nil)
        #expect(sut.ibanError == nil)
        #expect(sut.amountError == nil)
        #expect(sut.paymentPurposeError == nil)
    }
}
