//
//  PaymentReviewUpdateFieldErrorStatesTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK

@Suite("PaymentReviewPaymentInformationObservableModel — updateFieldErrorStates")
@MainActor
struct PaymentReviewUpdateFieldErrorStatesTests {

    @Test("updateFieldErrorStates mirrors error properties into input states")
    func errorStatesMirrored() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.recipientError = "Invalid recipient"
        sut.ibanError = "Invalid IBAN"
        sut.amountError = nil
        sut.paymentPurposeError = "Purpose required"

        sut.updateFieldErrorStates()

        #expect(sut.recipientInputState.hasError == true, "updateFieldErrorStates must set hasError on recipientInputState when recipientError is set")
        #expect(sut.recipientInputState.errorMessage == "Invalid recipient", "updateFieldErrorStates must mirror recipientError message into recipientInputState.errorMessage")
        #expect(sut.ibanInputState.hasError == true, "updateFieldErrorStates must set hasError on ibanInputState when ibanError is set")
        #expect(sut.amountInputState.hasError == false, "updateFieldErrorStates must leave hasError false on amountInputState when amountError is nil")
        #expect(sut.paymentPurposeInputState.hasError == true, "updateFieldErrorStates must set hasError on paymentPurposeInputState when paymentPurposeError is set")
    }

    @Test("updateFieldErrorStates clears error when property is nil")
    func clearsErrorWhenNil() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.recipientInputState.hasError = true
        sut.recipientError = nil

        sut.updateFieldErrorStates()

        #expect(sut.recipientInputState.hasError == false, "updateFieldErrorStates must clear hasError on recipientInputState when recipientError is nil")
    }

    @Test("pay button shows errors when all fields are empty")
    func validateThenUpdateShowsErrors() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())

        let isValid = sut.validateAllFields()
        sut.updateFieldErrorStates()

        #expect(isValid == false, "validateAllFields must return false when all fields are empty")
        #expect(sut.recipientInputState.hasError == true, "updateFieldErrorStates must set hasError on recipientInputState after validate with empty recipient")
        #expect(sut.ibanInputState.hasError == true, "updateFieldErrorStates must set hasError on ibanInputState after validate with empty IBAN")
        #expect(sut.amountInputState.hasError == true, "updateFieldErrorStates must set hasError on amountInputState after validate with empty amount")
        #expect(sut.paymentPurposeInputState.hasError == true, "updateFieldErrorStates must set hasError on paymentPurposeInputState after validate with empty purpose")
    }
}
