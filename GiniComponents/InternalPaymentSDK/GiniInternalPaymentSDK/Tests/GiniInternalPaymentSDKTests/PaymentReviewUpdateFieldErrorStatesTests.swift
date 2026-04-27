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

        #expect(sut.recipientInputState.hasError == true)
        #expect(sut.recipientInputState.errorMessage == "Invalid recipient")
        #expect(sut.ibanInputState.hasError == true)
        #expect(sut.amountInputState.hasError == false)
        #expect(sut.paymentPurposeInputState.hasError == true)
    }

    @Test("updateFieldErrorStates clears error when property is nil")
    func clearsErrorWhenNil() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.recipientInputState.hasError = true
        sut.recipientError = nil

        sut.updateFieldErrorStates()

        #expect(sut.recipientInputState.hasError == false)
    }

    @Test("pay button shows errors when all fields are empty")
    func validateThenUpdateShowsErrors() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())

        let isValid = sut.validateAllFields()
        sut.updateFieldErrorStates()

        #expect(isValid == false)
        #expect(sut.recipientInputState.hasError == true)
        #expect(sut.ibanInputState.hasError == true)
        #expect(sut.amountInputState.hasError == true)
        #expect(sut.paymentPurposeInputState.hasError == true)
    }
}
