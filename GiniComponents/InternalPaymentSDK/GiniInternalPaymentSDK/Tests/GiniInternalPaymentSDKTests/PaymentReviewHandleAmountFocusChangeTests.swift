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
}
