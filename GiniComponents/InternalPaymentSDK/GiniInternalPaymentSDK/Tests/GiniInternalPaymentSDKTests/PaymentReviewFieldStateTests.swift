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

        #expect(sut.fieldState(for: .recipient, hasError: true) == .error, "fieldState must return .error when hasError is true")
    }

    @Test("active field with no error returns .focused")
    func activeFieldReturnsFocused() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.activeField = .iban

        #expect(sut.fieldState(for: .iban, hasError: false) == .focused, "fieldState must return .focused for the active field when hasError is false")
    }

    @Test("non-active field with no error returns .normal")
    func nonActiveFieldReturnsNormal() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.activeField = .recipient

        #expect(sut.fieldState(for: .iban, hasError: false) == .normal, "fieldState must return .normal for a non-active field when hasError is false")
    }

    @Test("nil active field returns .normal")
    func nilActiveFieldReturnsNormal() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.activeField = nil

        #expect(sut.fieldState(for: .amount, hasError: false) == .normal, "fieldState must return .normal when active field is nil")
    }

    // MARK: - Simultaneous error + focus (HEAL-368 regression guard)

    // When the user taps IBAN while amount has a validation error, both fields must
    // independently reflect their own state. The error state on amount must not be
    // cleared by the focus change to IBAN, and IBAN must not inherit the error.
    @Test("IBAN focused while amount has error: IBAN returns .focused, amount returns .error")
    func ibanFocusedWhileAmountHasError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.activeField = .iban

        let ibanState = sut.fieldState(for: .iban, hasError: false)
        let amountState = sut.fieldState(for: .amount, hasError: true)

        #expect(ibanState == .focused, "IBAN must be .focused when it is the active field")
        #expect(amountState == .error, "Amount must stay .error while IBAN is focused — focus change must not clear the error")
    }

    @Test("amount focused while IBAN has error: amount returns .focused, IBAN returns .error")
    func amountFocusedWhileIBANHasError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.activeField = .amount

        let amountState = sut.fieldState(for: .amount, hasError: false)
        let ibanState = sut.fieldState(for: .iban, hasError: true)

        #expect(amountState == .focused, "Amount must be .focused when it is the active field")
        #expect(ibanState == .error, "IBAN must stay .error while amount is focused — focus change must not clear the error")
    }

    @Test("error takes precedence over focus for the same field")
    func errorTakesPrecedenceOverFocusOnSameField() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.activeField = .amount

        let state = sut.fieldState(for: .amount, hasError: true)

        #expect(state == .error, "Error must take precedence over focus — a focused field with a validation error must show .error, not .focused")
    }
}
