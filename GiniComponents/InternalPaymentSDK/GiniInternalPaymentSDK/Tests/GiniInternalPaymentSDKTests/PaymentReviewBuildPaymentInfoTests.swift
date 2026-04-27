//
//  PaymentReviewBuildPaymentInfoTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import GiniHealthAPILibrary
import GiniUtilites
@testable import GiniInternalPaymentSDK

@Suite("PaymentReviewPaymentInformationObservableModel — buildPaymentInfo")
@MainActor
struct PaymentReviewBuildPaymentInfoTests {

    @Test("buildPaymentInfo maps field states to PaymentInfo")
    func buildPaymentInfoMapsFields() {
        let provider = PaymentProvider.test
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.recipientInputState.text = "Gini GmbH"
        sut.ibanInputState.text = "DE89370400440532013000"
        sut.paymentPurposeInputState.text = "Invoice 2026"
        sut.amountToPay = Price(value: 12.50, currencyCode: "EUR")

        let info = sut.buildPaymentInfo()

        #expect(info.recipient == "Gini GmbH")
        #expect(info.iban == "DE89370400440532013000")
        #expect(info.purpose == "Invoice 2026")
        #expect(info.paymentProviderId == provider.id)
        #expect(info.paymentUniversalLink == provider.universalLinkIOS)
    }
}
