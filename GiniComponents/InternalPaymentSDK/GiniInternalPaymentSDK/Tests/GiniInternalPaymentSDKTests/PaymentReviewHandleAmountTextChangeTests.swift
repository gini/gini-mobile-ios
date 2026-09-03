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

    @Test("text change does not clear error — handleAmountTextChange never clears error regardless of focus state")
    func textChangeDoesNotClearError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.amountInputState.hasError = true
        sut.isAmountFieldFocused = false

        sut.handleAmountTextChange(updatedText: "12,50")

        #expect(sut.amountInputState.hasError == true,
                "handleAmountTextChange must never clear a validation error — error clearing is handled by the view's onChange(of: text) guard, not the model")
    }
}
