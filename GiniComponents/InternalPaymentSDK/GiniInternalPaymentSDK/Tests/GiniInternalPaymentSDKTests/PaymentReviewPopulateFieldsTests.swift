//
//  PaymentReviewPopulateFieldsTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import GiniHealthAPILibrary
import GiniUtilites
@testable import GiniInternalPaymentSDK

@Suite("PaymentReviewPaymentInformationObservableModel — populateFieldsIfNeeded")
@MainActor
struct PaymentReviewPopulateFieldsTests {

    @Test("populates fields from PaymentInfo on first call")
    func populatesFromPaymentInfo() {
        let paymentInfo = PaymentInfo(recipient: "Gini GmbH",
                                     iban: "DE89370400440532013000",
                                     amount: "12.50:EUR",
                                     purpose: "Invoice 2026",
                                     paymentUniversalLink: "https://example.com",
                                     paymentProviderId: "test")
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test(paymentInfo: paymentInfo))

        sut.populateFieldsIfNeeded()

        #expect(sut.recipientInputState.text == "Gini GmbH")
        #expect(sut.ibanInputState.text == "DE89370400440532013000")
        #expect(sut.paymentPurposeInputState.text == "Invoice 2026")
    }

    @Test("populates fields from extractions on first call")
    func populatesFromExtractions() {
        let extractions = [
            Extraction(box: nil, candidates: "", entity: "text", value: "Gini GmbH", name: "payment_recipient"),
            Extraction(box: nil, candidates: "", entity: "iban", value: "DE89370400440532013000", name: "iban"),
            Extraction(box: nil, candidates: "", entity: "text", value: "Invoice 2026", name: "payment_purpose"),
            Extraction(box: nil, candidates: "", entity: "amount", value: "12.50:EUR", name: "amount_to_pay")
        ]
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test(extractions: extractions))

        sut.populateFieldsIfNeeded()

        #expect(sut.recipientInputState.text == "Gini GmbH")
        #expect(sut.ibanInputState.text == "DE89370400440532013000")
        #expect(sut.paymentPurposeInputState.text == "Invoice 2026")
    }

    @Test("second call is a no-op (idempotent)")
    func isIdempotent() {
        let paymentInfo = PaymentInfo(recipient: "Gini GmbH",
                                     iban: "DE89370400440532013000",
                                     amount: "12.50:EUR",
                                     purpose: "Invoice 2026",
                                     paymentUniversalLink: "https://example.com",
                                     paymentProviderId: "test")
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test(paymentInfo: paymentInfo))
        sut.populateFieldsIfNeeded()
        sut.recipientInputState.text = "Changed"
        sut.populateFieldsIfNeeded()

        #expect(sut.recipientInputState.text == "Changed",
                "second populateFieldsIfNeeded must not overwrite manually changed fields")
    }
}
