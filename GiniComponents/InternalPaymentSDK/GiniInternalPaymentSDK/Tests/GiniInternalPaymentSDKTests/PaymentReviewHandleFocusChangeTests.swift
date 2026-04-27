//
//  PaymentReviewHandleFocusChangeTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
@testable import GiniInternalPaymentSDK

@Suite("PaymentReviewPaymentInformationObservableModel — handleFocusChange")
@MainActor
struct PaymentReviewHandleFocusChangeTests {

    @Test("focus gained clears hasError")
    func focusGainedClearsError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.recipientInputState.hasError = true

        sut.handleFocusChange(isFocused: true,
                              inputState: \.recipientInputState,
                              validate: sut.validateRecipient,
                              error: \.recipientError)

        #expect(sut.recipientInputState.hasError == false, "focus gained must clear hasError on the input state")
    }

    @Test("focus lost with valid text sets no error")
    func focusLostValidTextNoError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.recipientInputState.text = "Gini GmbH"

        sut.handleFocusChange(isFocused: false,
                              inputState: \.recipientInputState,
                              validate: sut.validateRecipient,
                              error: \.recipientError)

        #expect(sut.recipientInputState.hasError == false, "focus lost with valid text must not set hasError")
    }

    @Test("focus lost with empty text sets hasError and errorMessage")
    func focusLostEmptyTextSetsError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.recipientInputState.text = ""

        sut.handleFocusChange(isFocused: false,
                              inputState: \.recipientInputState,
                              validate: sut.validateRecipient,
                              error: \.recipientError)

        #expect(sut.recipientInputState.hasError == true, "focus lost with empty text must set hasError on the input state")
        #expect(sut.recipientInputState.errorMessage != nil, "focus lost with empty text must set a non-nil errorMessage")
    }

    @Test("focus lost with invalid IBAN sets hasError")
    func focusLostInvalidIBANSetsError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.ibanInputState.text = "NOTANIBAN"

        sut.handleFocusChange(isFocused: false,
                              inputState: \.ibanInputState,
                              validate: sut.validateIBAN,
                              error: \.ibanError)

        #expect(sut.ibanInputState.hasError == true, "focus lost with invalid IBAN must set hasError on the IBAN input state")
    }
}
