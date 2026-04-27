//
//  PaymentReviewFieldStateTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
@testable import GiniInternalPaymentSDK

@Suite("PaymentReviewPaymentInformationObservableModel — fieldState")
@MainActor
struct PaymentReviewFieldStateTests {

    @Test("hasError true returns .error regardless of active field")
    func errorStateReturnedWhenHasError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.activeField = .recipient

        #expect(sut.fieldState(for: .recipient, hasError: true) == .error)
    }

    @Test("active field with no error returns .focused")
    func activeFieldReturnsFocused() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.activeField = .iban

        #expect(sut.fieldState(for: .iban, hasError: false) == .focused)
    }

    @Test("non-active field with no error returns .normal")
    func nonActiveFieldReturnsNormal() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.activeField = .recipient

        #expect(sut.fieldState(for: .iban, hasError: false) == .normal)
    }

    @Test("nil active field returns .normal")
    func nilActiveFieldReturnsNormal() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.activeField = nil

        #expect(sut.fieldState(for: .amount, hasError: false) == .normal)
    }
}
