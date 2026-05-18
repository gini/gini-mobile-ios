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

// MARK: - clearErrorOnTextChange

@Suite("PaymentReviewPaymentInformationObservableModel — clearErrorOnTextChange")
@MainActor
struct PaymentReviewClearErrorOnTextChangeTests {

    @Test("clears hasError and errorMessage when hasError is true")
    func clearsErrorWhenErrorIsSet() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.recipientInputState.hasError = true
        sut.recipientInputState.errorMessage = "Recipient is required"

        sut.clearErrorOnTextChange(for: \.recipientInputState)

        #expect(sut.recipientInputState.hasError == false, "clearErrorOnTextChange must set hasError to false")
        #expect(sut.recipientInputState.errorMessage == nil, "clearErrorOnTextChange must clear errorMessage")
    }

    @Test("is a no-op when hasError is already false")
    func isNoOpWhenNoError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.recipientInputState.hasError = false
        sut.recipientInputState.errorMessage = nil

        sut.clearErrorOnTextChange(for: \.recipientInputState)

        #expect(sut.recipientInputState.hasError == false, "clearErrorOnTextChange must not flip hasError when it is already false")
    }

    @Test("works for any field via the key path parameter")
    func worksForIBANField() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.ibanInputState.hasError = true
        sut.ibanInputState.errorMessage = "Invalid IBAN"

        sut.clearErrorOnTextChange(for: \.ibanInputState)

        #expect(sut.ibanInputState.hasError == false, "clearErrorOnTextChange must clear the field identified by the key path")
    }
}
