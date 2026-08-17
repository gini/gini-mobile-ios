//
//  SPCQRCodeTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import Foundation
@testable import GiniCaptureSDK

@Suite("SPC QR Code")
struct SPCQRCodeTests {

    private func makeSPC(referenceType: String = "QRR",
                         reference: String = "210000000003139471430009017",
                         iban: String = "DE89370400440532013000") -> String {
        var lines = Array(repeating: "", count: 31)
        lines[0]  = "SPC"
        lines[1]  = "0200"
        lines[2]  = "1"
        lines[3]  = iban
        lines[4]  = "S"
        lines[5]  = "Test Recipient"
        lines[18] = "1234.50"
        lines[19] = "CHF"
        lines[27] = referenceType
        lines[28] = reference
        return lines.joined(separator: "\n")
    }

    @Test func detectedAsSPC() {
        let doc = GiniQRCodeDocument(scannedString: makeSPC())
        #expect(doc.qrCodeFormat == .spc)
    }

    @Test func extractsIBANRecipientAndAmount() {
        let doc = GiniQRCodeDocument(scannedString: makeSPC())
        #expect(doc.extractedParameters["iban"] == "DE89370400440532013000")
        #expect(doc.extractedParameters["paymentRecipient"] == "Test Recipient")
        #expect(doc.extractedParameters["amountToPay"] == "1234.50:CHF")
    }

    @Test func extractsReferenceWhenQRR() {
        let doc = GiniQRCodeDocument(scannedString: makeSPC())
        #expect(doc.extractedParameters["paymentReference"] == "210000000003139471430009017")
    }

    @Test func noReferenceWhenNON() {
        let doc = GiniQRCodeDocument(scannedString: makeSPC(referenceType: "NON",
                                                            reference: "210000000003139471430009017"))
        #expect(doc.extractedParameters["paymentReference"] == nil)
    }

    @Test func nilFormatForInvalidIBAN() {
        let doc = GiniQRCodeDocument(scannedString: makeSPC(iban: "NOTANIBAN"))
        #expect(doc.qrCodeFormat == nil)
    }
}
