//
//  SPDQRCodeTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import Foundation
@testable import GiniCaptureSDK

@Suite("SPD QR Code")
struct SPDQRCodeTests {

    private let validSPD = "SPD*1.0*ACC:CZ6508000000192000145399*AM:100.50*CC:CZK*RN:Test Recipient*MSG:Invoice 123*"

    @Test func detectedAsSPD() {
        let doc = GiniQRCodeDocument(scannedString: validSPD)
        #expect(doc.qrCodeFormat == .spd)
    }

    @Test func extractsAllFields() {
        let doc = GiniQRCodeDocument(scannedString: validSPD)
        #expect(doc.extractedParameters["iban"] == "CZ6508000000192000145399")
        #expect(doc.extractedParameters["amountToPay"] == "100.50:CZK")
        #expect(doc.extractedParameters["paymentRecipient"] == "Test Recipient")
        #expect(doc.extractedParameters["paymentReference"] == "Invoice 123")
    }

    @Test func amountHasNoCurrencySuffixWhenCCMissing() {
        let doc = GiniQRCodeDocument(scannedString: "SPD*1.0*ACC:CZ6508000000192000145399*AM:100.50*RN:Test Recipient*")
        #expect(doc.extractedParameters["amountToPay"] == "100.50")
    }

    @Test func ibanNilWhenACCMissing() {
        let doc = GiniQRCodeDocument(scannedString: "SPD*1.0*AM:100.50*CC:CZK*RN:Test Recipient*")
        #expect(doc.extractedParameters["iban"] == nil)
    }

    @Test func combinesAmountAndCurrencyWhenCCPrecedesAM() {
        // AM and CC may appear in any order; currency must not be dropped when CC comes first.
        let doc = GiniQRCodeDocument(scannedString: "SPD*1.0*ACC:CZ6508000000192000145399*CC:CZK*AM:100.50*")
        #expect(doc.extractedParameters["amountToPay"] == "100.50:CZK")
    }
}
