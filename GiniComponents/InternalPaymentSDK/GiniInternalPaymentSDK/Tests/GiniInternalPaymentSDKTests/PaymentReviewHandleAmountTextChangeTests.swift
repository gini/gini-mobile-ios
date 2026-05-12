//
//  PaymentReviewHandleAmountTextChangeTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
@testable import GiniInternalPaymentSDK

@Suite("PaymentReviewPaymentInformationObservableModel — handleAmountTextChange")
@MainActor
struct PaymentReviewHandleAmountTextChangeTests {

    @Test("valid amount text clears error and updates amountToPay while field is focused")
    func validTextClearsErrorWhenFocused() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.amountInputState.hasError = true
        sut.isAmountFieldFocused = true

        sut.handleAmountTextChange(updatedText: "12,50")

        #expect(sut.amountInputState.hasError == false, "handleAmountTextChange with valid text must clear hasError while the user is actively typing")
        #expect(sut.amountToPay.value > 0, "handleAmountTextChange with valid text must update amountToPay to a positive value")
    }

    @Test("non-parsable text still clears hasError without crashing while field is focused")
    func nonParsableTextClearsErrorWhenFocused() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.amountInputState.hasError = true
        sut.isAmountFieldFocused = true

        sut.handleAmountTextChange(updatedText: "abc")

        #expect(sut.amountInputState.hasError == false, "handleAmountTextChange with non-parsable text must still clear hasError without crashing while the user is actively typing")
    }

    @Test("text change does not clear error when field is not focused (programmatic change)")
    func textChangeDoesNotClearErrorWhenNotFocused() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.amountInputState.hasError = true
        sut.isAmountFieldFocused = false

        sut.handleAmountTextChange(updatedText: "12,50")

        #expect(sut.amountInputState.hasError == true,
                "programmatic text change (isAmountFieldFocused == false) must not clear a validation error set by the pay button")
    }
}
