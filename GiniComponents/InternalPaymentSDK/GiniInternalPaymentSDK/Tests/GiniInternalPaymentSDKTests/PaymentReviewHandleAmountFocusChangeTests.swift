//
//  PaymentReviewHandleAmountFocusChangeTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import GiniHealthAPILibrary
import GiniUtilites
@testable import GiniInternalPaymentSDK

@Suite("PaymentReviewPaymentInformationObservableModel — handleAmountFocusChange")
@MainActor
struct PaymentReviewHandleAmountFocusChangeTests {

    @Test("focus gained sets text to raw numeric value")
    func focusGainedSetsRawText() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.amountToPay = Price(value: 12.50, currencyCode: "EUR")

        sut.handleAmountFocusChange(isFocused: true)

        #expect(sut.amountInputState.text == (sut.amountToPay.stringWithoutSymbol ?? ""), "focus gained must set amount text to the raw numeric value of amountToPay")
    }

    @Test("focus gained with zero amount does not pre-fill text")
    func focusGainedWithZeroAmountKeepsTextEmpty() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.amountToPay = Price(value: 0, currencyCode: "EUR")
        sut.amountInputState.text = ""

        sut.handleAmountFocusChange(isFocused: true)

        #expect(sut.amountInputState.text == "", "focus gained with zero amount must not pre-fill text — a programmatic '\"\" → \"0,00\"' change inside the async Task can race with UIKit first-responder setup and trigger a focus loss that re-shows the error")
    }

    @Test("focus lost with empty text sets hasError")
    func focusLostEmptyTextSetsError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.amountInputState.text = ""
        sut.amountToPay = Price(value: 0, currencyCode: "EUR")

        sut.handleAmountFocusChange(isFocused: false)

        #expect(sut.amountInputState.hasError == true, "focus lost with empty amount text must set hasError on amountInputState")
    }

    @Test("focus lost with valid positive amount clears error")
    func focusLostValidAmountClearsError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.amountToPay = Price(value: 12.50, currencyCode: "EUR")
        // Use stringWithoutSymbol so the text uses the same locale-specific decimal
        // separator that decimal() will parse correctly on any CI machine.
        sut.amountInputState.text = sut.amountToPay.stringWithoutSymbol ?? "12.50"

        sut.handleAmountFocusChange(isFocused: false)

        #expect(sut.amountInputState.hasError == false, "focus lost with a valid positive amount must clear hasError on amountInputState")
    }

    @Test("focus lost with zero parsed amount sets hasError")
    func focusLostZeroAmountSetsError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.amountInputState.text = "0"

        sut.handleAmountFocusChange(isFocused: false)

        #expect(sut.amountInputState.hasError == true, "focus lost with a zero parsed amount must set hasError on amountInputState")
    }

    @Test("focus lost with empty amount sets the expected errorMessage on amountInputState")
    func focusLostEmptyTextSetsErrorMessage() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.amountInputState.text = ""
        sut.amountToPay = Price(value: 0, currencyCode: "EUR")

        sut.handleAmountFocusChange(isFocused: false)

        #expect(sut.amountInputState.errorMessage == sut.model.strings.fieldErrors.amount,
                "focus lost with empty amount must set errorMessage to the localized amount error string")
    }

    // MARK: - Done button regression guard (HEAL-368)

    // The doneButtonBar calls handleAmountFocusChange(isFocused: false) directly, then
    // sets focusedField = nil which triggers a second call via onChange. Both calls must
    // leave the model in the same final state — no flipping of error flags.
    // The VoiceOver announcement is only posted on the first call (when the error is newly
    // introduced); the guard `!wasAlreadyInError` prevents a double-announcement on the
    // second call. UIAccessibility.post cannot be unit-tested directly, but the guard's
    // effect is verified indirectly: if hasError was already true on entry to the second
    // call, the announcement branch is skipped.
    @Test("focus gained when text is already raw does not change text")
    func focusGainedWithTextAlreadyRawDoesNotChangeText() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.amountToPay = Price(value: 12.50, currencyCode: "EUR")
        /// Pre-set the text to the raw value so the `rawText == amountInputState.text` branch is taken.
        sut.amountInputState.text = sut.amountToPay.stringWithoutSymbol ?? "12.50"
        let textBefore = sut.amountInputState.text

        sut.handleAmountFocusChange(isFocused: true)

        #expect(sut.amountInputState.text == textBefore, "focus gained with text already in raw format must not change the text")
    }

    @Test("focus gained when text is already raw does not immediately clear error (clears are deferred)")
    func focusGainedWithTextAlreadyRawDoesNotImmediatelyClearError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.amountToPay = Price(value: 12.50, currencyCode: "EUR")
        sut.amountInputState.text = sut.amountToPay.stringWithoutSymbol ?? "12.50"
        sut.amountInputState.hasError = true
        /// isAmountFieldFocused is false in this test — the deferred Task inside
        /// clearAmountErrorAfterKeyboardAppears will guard on it and be a no-op.

        sut.handleAmountFocusChange(isFocused: true)

        #expect(sut.amountInputState.hasError == true, "error must not be cleared immediately when the deferred-clear path is taken")
    }

    @Test("calling handleAmountFocusChange(isFocused: false) twice with valid amount stays error-free")
    func doubleCallWithValidAmountIsIdempotent() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.amountToPay = Price(value: 12.50, currencyCode: "EUR")
        sut.amountInputState.text = sut.amountToPay.stringWithoutSymbol ?? "12.50"

        sut.handleAmountFocusChange(isFocused: false)
        sut.handleAmountFocusChange(isFocused: false)

        #expect(sut.amountInputState.hasError == false, "double call with valid amount must not flip hasError — the Done button triggers this path")
    }

    @Test("calling handleAmountFocusChange(isFocused: false) twice with empty amount stays in error")
    func doubleCallWithEmptyAmountIsIdempotent() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.amountInputState.text = ""
        sut.amountToPay = Price(value: 0, currencyCode: "EUR")

        sut.handleAmountFocusChange(isFocused: false)
        sut.handleAmountFocusChange(isFocused: false)

        #expect(sut.amountInputState.hasError == true, "double call with empty amount must keep hasError set — the Done button triggers this path")
    }
}

// MARK: - applyAmountErrorClear

@Suite("PaymentReviewPaymentInformationObservableModel — applyAmountErrorClear")
@MainActor
struct PaymentReviewApplyAmountErrorClearTests {

    @Test("clears hasError and errorMessage")
    func clearsError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.amountInputState.hasError = true
        sut.amountInputState.errorMessage = "Amount is required"

        sut.applyAmountErrorClear()

        #expect(sut.amountInputState.hasError == false, "applyAmountErrorClear must set hasError to false")
        #expect(sut.amountInputState.errorMessage == nil, "applyAmountErrorClear must clear errorMessage")
    }

    @Test("is a no-op when no error is set")
    func isNoOpWhenNoError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.amountInputState.hasError = false
        sut.amountInputState.errorMessage = nil

        sut.applyAmountErrorClear()

        #expect(sut.amountInputState.hasError == false, "applyAmountErrorClear must not flip hasError when already false")
    }
}
