//
//  PaymentReviewAdjustAmountValueTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
@testable import GiniInternalPaymentSDK

@Suite("PaymentReviewPaymentInformationObservableModel — adjustAmountValue")
@MainActor
struct PaymentReviewAdjustAmountValueTests {

    @Test("valid amount string returns adjusted text and decimal value")
    func validAmountReturnsAdjustedPair() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        let result = sut.adjustAmountValue(text: "12,50")
        #expect(result != nil)
        #expect(result?.newValue ?? 0 > 0)
    }

    @Test("empty string returns nil")
    func emptyStringReturnsNil() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        #expect(sut.adjustAmountValue(text: "") == nil)
    }

    @Test("non-numeric string returns nil")
    func nonNumericReturnsNil() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        #expect(sut.adjustAmountValue(text: "abcdef") == nil)
    }
}
