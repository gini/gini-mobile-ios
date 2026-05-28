//
//  PaymentInfoTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
@testable import GiniInternalPaymentSDK

@Suite("PaymentInfo")
struct PaymentInfoTests {

    @Test("isComplete is true when all required fields are non-empty")
    func isCompleteWhenAllFieldsFilled() {
        let info = PaymentInfo(recipient: "Gini GmbH",
                               iban: "DE89370400440532013000",
                               amount: "100.00:EUR",
                               purpose: "Invoice 42",
                               paymentUniversalLink: "https://bank.example/pay",
                               paymentProviderId: "provider-1")
        #expect(info.isComplete == true)
    }

    @Test("isComplete is false when recipient is empty")
    func isCompleteIsFalseWhenRecipientEmpty() {
        let info = PaymentInfo(recipient: "",
                               iban: "DE89370400440532013000",
                               amount: "100.00:EUR",
                               purpose: "Invoice",
                               paymentUniversalLink: "",
                               paymentProviderId: "p")
        #expect(info.isComplete == false)
    }

    @Test("isComplete is false when iban is empty")
    func isCompleteIsFalseWhenIbanEmpty() {
        let info = PaymentInfo(recipient: "Recipient",
                               iban: "",
                               amount: "100.00:EUR",
                               purpose: "Invoice",
                               paymentUniversalLink: "",
                               paymentProviderId: "p")
        #expect(info.isComplete == false)
    }

    @Test("isComplete is false when amount is empty")
    func isCompleteIsFalseWhenAmountEmpty() {
        let info = PaymentInfo(recipient: "Recipient",
                               iban: "DE89370400440532013000",
                               amount: "",
                               purpose: "Invoice",
                               paymentUniversalLink: "",
                               paymentProviderId: "p")
        #expect(info.isComplete == false)
    }

    @Test("isComplete is false when purpose is empty")
    func isCompleteIsFalseWhenPurposeEmpty() {
        let info = PaymentInfo(recipient: "Recipient",
                               iban: "DE89370400440532013000",
                               amount: "100.00:EUR",
                               purpose: "",
                               paymentUniversalLink: "",
                               paymentProviderId: "p")
        #expect(info.isComplete == false)
    }

    @Test("iban is uppercased on init")
    func ibanIsUppercasedOnInit() {
        let info = PaymentInfo(recipient: "R",
                               iban: "de89370400440532013000",
                               amount: "1.00:EUR",
                               purpose: "P",
                               paymentUniversalLink: "",
                               paymentProviderId: "p")
        #expect(info.iban == "DE89370400440532013000")
    }

    @Test("sourceDocumentLocation defaults to nil")
    func sourceDocumentLocationDefaultsToNil() {
        let info = PaymentInfo(recipient: "R",
                               iban: "DE89370400440532013000",
                               amount: "1.00:EUR",
                               purpose: "P",
                               paymentUniversalLink: "",
                               paymentProviderId: "p")
        #expect(info.sourceDocumentLocation == nil)
    }

    @Test("sourceDocumentLocation is stored when provided")
    func sourceDocumentLocationStoredWhenProvided() {
        let info = PaymentInfo(sourceDocumentLocation: "https://example.com/doc",
                               recipient: "R",
                               iban: "DE89370400440532013000",
                               amount: "1.00:EUR",
                               purpose: "P",
                               paymentUniversalLink: "",
                               paymentProviderId: "p")
        #expect(info.sourceDocumentLocation == "https://example.com/doc")
    }

}
