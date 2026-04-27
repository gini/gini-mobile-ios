//
//  PaymentReviewValidationTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import GiniUtilites
@testable import GiniInternalPaymentSDK

@Suite("PaymentReviewPaymentInformationObservableModel — validation")
@MainActor
struct PaymentReviewValidationTests {

    // MARK: validateRecipient

    @Test("empty recipient is invalid and sets error")
    func emptyRecipientIsInvalid() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        #expect(sut.validateRecipient("") == false)
        #expect(sut.recipientError != nil)
    }

    @Test("whitespace-only recipient is invalid")
    func whitespaceRecipientIsInvalid() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        #expect(sut.validateRecipient("   ") == false)
        #expect(sut.recipientError != nil)
    }

    @Test("non-empty recipient is valid and clears error")
    func validRecipientClearsError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        _ = sut.validateRecipient("") // seed an error first
        #expect(sut.validateRecipient("Gini GmbH") == true)
        #expect(sut.recipientError == nil)
    }

    // MARK: validateIBAN

    @Test("empty IBAN is invalid")
    func emptyIBANIsInvalid() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        #expect(sut.validateIBAN("") == false)
        #expect(sut.ibanError != nil)
    }

    @Test("malformed IBAN is invalid")
    func malformedIBANIsInvalid() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        #expect(sut.validateIBAN("NOTANIBAN") == false)
        #expect(sut.ibanError != nil)
    }

    @Test("valid German IBAN is accepted and clears error")
    func validIBANClearsError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        _ = sut.validateIBAN("") // seed an error first
        #expect(sut.validateIBAN("DE89370400440532013000") == true)
        #expect(sut.ibanError == nil)
    }

    // MARK: validateAmount

    @Test("empty amount string is invalid")
    func emptyAmountIsInvalid() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        #expect(sut.validateAmount("", amount: 0) == false)
        #expect(sut.amountError != nil)
    }

    @Test("zero decimal amount is invalid")
    func zeroAmountIsInvalid() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        #expect(sut.validateAmount("0.00", amount: 0) == false)
        #expect(sut.amountError != nil)
    }

    @Test("positive amount is valid and clears error")
    func positiveAmountClearsError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        _ = sut.validateAmount("", amount: 0)
        #expect(sut.validateAmount("12.50", amount: 12.50) == true)
        #expect(sut.amountError == nil)
    }

    // MARK: validatePaymentPurpose

    @Test("empty purpose is invalid")
    func emptyPurposeIsInvalid() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        #expect(sut.validatePaymentPurpose("") == false)
        #expect(sut.paymentPurposeError != nil)
    }

    @Test("non-empty purpose is valid and clears error")
    func validPurposeClearsError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        _ = sut.validatePaymentPurpose("")
        #expect(sut.validatePaymentPurpose("Invoice 1234") == true)
        #expect(sut.paymentPurposeError == nil)
    }
}
