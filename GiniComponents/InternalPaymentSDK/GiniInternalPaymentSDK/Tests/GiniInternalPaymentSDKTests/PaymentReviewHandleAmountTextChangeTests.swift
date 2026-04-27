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

    @Test("valid amount text clears error and updates amountToPay")
    func validTextClearsError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.amountInputState.hasError = true

        sut.handleAmountTextChange(updatedText: "12,50")

        #expect(sut.amountInputState.hasError == false, "handleAmountTextChange with valid text must clear hasError")
        #expect(sut.amountToPay.value > 0, "handleAmountTextChange with valid text must update amountToPay to a positive value")
    }

    @Test("non-parsable text still clears hasError without crashing")
    func nonParsableTextClearsError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.amountInputState.hasError = true

        sut.handleAmountTextChange(updatedText: "abc")

        #expect(sut.amountInputState.hasError == false, "handleAmountTextChange with non-parsable text must still clear hasError without crashing")
    }
}
