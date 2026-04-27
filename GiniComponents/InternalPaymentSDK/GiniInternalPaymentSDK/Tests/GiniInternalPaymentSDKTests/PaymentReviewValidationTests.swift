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
        #expect(sut.validateRecipient("") == false, "validateRecipient must return false for an empty string")
        #expect(sut.recipientError != nil, "validateRecipient must set recipientError for an empty string")
    }

    @Test("whitespace-only recipient is invalid")
    func whitespaceRecipientIsInvalid() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        #expect(sut.validateRecipient("   ") == false, "validateRecipient must return false for a whitespace-only string")
        #expect(sut.recipientError != nil, "validateRecipient must set recipientError for a whitespace-only string")
    }

    @Test("non-empty recipient is valid and clears error")
    func validRecipientClearsError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        _ = sut.validateRecipient("") // seed an error first
        #expect(sut.validateRecipient("Gini GmbH") == true, "validateRecipient must return true for a non-empty recipient")
        #expect(sut.recipientError == nil, "validateRecipient must clear recipientError for a valid recipient")
    }

    // MARK: validateIBAN

    @Test("empty IBAN is invalid")
    func emptyIBANIsInvalid() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        #expect(sut.validateIBAN("") == false, "validateIBAN must return false for an empty string")
        #expect(sut.ibanError != nil, "validateIBAN must set ibanError for an empty string")
    }

    @Test("malformed IBAN is invalid")
    func malformedIBANIsInvalid() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        #expect(sut.validateIBAN("NOTANIBAN") == false, "validateIBAN must return false for a malformed IBAN")
        #expect(sut.ibanError != nil, "validateIBAN must set ibanError for a malformed IBAN")
    }

    @Test("valid German IBAN is accepted and clears error")
    func validIBANClearsError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        _ = sut.validateIBAN("") // seed an error first
        #expect(sut.validateIBAN("DE89370400440532013000") == true, "validateIBAN must return true for a valid German IBAN")
        #expect(sut.ibanError == nil, "validateIBAN must clear ibanError for a valid IBAN")
    }

    // MARK: validateAmount

    @Test("empty amount string is invalid")
    func emptyAmountIsInvalid() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        #expect(sut.validateAmount("", amount: 0) == false, "validateAmount must return false for an empty amount string")
        #expect(sut.amountError != nil, "validateAmount must set amountError for an empty amount string")
    }

    @Test("zero decimal amount is invalid")
    func zeroAmountIsInvalid() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        #expect(sut.validateAmount("0.00", amount: 0) == false, "validateAmount must return false for a zero amount")
        #expect(sut.amountError != nil, "validateAmount must set amountError for a zero amount")
    }

    @Test("positive amount is valid and clears error")
    func positiveAmountClearsError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        _ = sut.validateAmount("", amount: 0)
        #expect(sut.validateAmount("12.50", amount: 12.50) == true, "validateAmount must return true for a positive amount")
        #expect(sut.amountError == nil, "validateAmount must clear amountError for a valid positive amount")
    }

    // MARK: validatePaymentPurpose

    @Test("empty purpose is invalid")
    func emptyPurposeIsInvalid() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        #expect(sut.validatePaymentPurpose("") == false, "validatePaymentPurpose must return false for an empty string")
        #expect(sut.paymentPurposeError != nil, "validatePaymentPurpose must set paymentPurposeError for an empty string")
    }

    @Test("non-empty purpose is valid and clears error")
    func validPurposeClearsError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        _ = sut.validatePaymentPurpose("")
        #expect(sut.validatePaymentPurpose("Invoice 1234") == true, "validatePaymentPurpose must return true for a non-empty purpose")
        #expect(sut.paymentPurposeError == nil, "validatePaymentPurpose must clear paymentPurposeError for a valid purpose")
    }
}
