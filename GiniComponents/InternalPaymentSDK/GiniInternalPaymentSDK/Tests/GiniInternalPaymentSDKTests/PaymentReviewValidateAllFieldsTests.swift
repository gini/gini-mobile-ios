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
        #expect(sut.validateAllFields() == true, "validateAllFields must return true when all fields are valid")
    }

    @Test("invalid recipient makes validateAllFields return false")
    func invalidRecipientFails() {
        let sut = makeFullyPopulatedSUT()
        sut.recipientInputState.text = ""
        #expect(sut.validateAllFields() == false, "validateAllFields must return false when recipient is invalid")
    }

    @Test("invalid IBAN makes validateAllFields return false")
    func invalidIBANFails() {
        let sut = makeFullyPopulatedSUT()
        sut.ibanInputState.text = "INVALID"
        #expect(sut.validateAllFields() == false, "validateAllFields must return false when IBAN is invalid")
    }

    @Test("empty amount text makes validateAllFields return false")
    func emptyAmountTextFails() {
        let sut = makeFullyPopulatedSUT()
        sut.amountInputState.text = ""
        #expect(sut.validateAllFields() == false, "validateAllFields must return false when amount text is empty")
    }

    @Test("zero amount value makes validateAllFields return false")
    func zeroAmountValueFails() {
        let sut = makeFullyPopulatedSUT()
        sut.amountToPay = Price(value: 0, currencyCode: "EUR")
        #expect(sut.validateAllFields() == false, "validateAllFields must return false when amount value is zero")
    }

    @Test("empty purpose makes validateAllFields return false")
    func emptyPurposeFails() {
        let sut = makeFullyPopulatedSUT()
        sut.paymentPurposeInputState.text = ""
        #expect(sut.validateAllFields() == false, "validateAllFields must return false when payment purpose is empty")
    }

    @Test("all validators run even when first field is invalid")
    func allValidatorsRunNonShortCircuit() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        _ = sut.validateAllFields()

        // All four error properties must be set — proves validateAllFields
        // does not short-circuit after the first failure.
        #expect(sut.recipientError != nil, "validateAllFields must set recipientError when recipient is empty")
        #expect(sut.ibanError != nil, "validateAllFields must set ibanError when IBAN is empty")
        #expect(sut.amountError != nil, "validateAllFields must set amountError when amount is empty")
        #expect(sut.paymentPurposeError != nil, "validateAllFields must set paymentPurposeError when purpose is empty")
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
        #expect(sut.validateAllFields() == true, "validateAllFields must return true after all fields are set to valid values")

        #expect(sut.recipientError == nil, "validateAllFields must clear recipientError on a successful validation")
        #expect(sut.ibanError == nil, "validateAllFields must clear ibanError on a successful validation")
        #expect(sut.amountError == nil, "validateAllFields must clear amountError on a successful validation")
        #expect(sut.paymentPurposeError == nil, "validateAllFields must clear paymentPurposeError on a successful validation")
    }
}
