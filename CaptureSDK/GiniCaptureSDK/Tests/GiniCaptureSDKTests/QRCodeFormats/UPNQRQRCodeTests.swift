//
//  UPNQRQRCodeTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import Foundation
@testable import GiniCaptureSDK

@Suite("UPNQR QR Code")
struct UPNQRQRCodeTests {

    private func makeUPNQR(amountCents: String = "00000048050",
                            reference: String = "SI00 1234-5678",
                            iban: String = "DE89370400440532013000",
                            bic: String = "LJBASI2X",
                            payee: String = "Gini d.o.o.") -> String {
        var lines = Array(repeating: "", count: 20)
        lines[0]  = "UPNQR"
        lines[8]  = amountCents
        lines[12] = reference
        lines[13] = bic
        lines[14] = iban
        lines[16] = payee
        return lines.joined(separator: "\n")
    }

    @Test func detectedAsUPNQR() {
        let doc = GiniQRCodeDocument(scannedString: makeUPNQR())
        #expect(doc.qrCodeFormat == .upnqr)
    }

    @Test func extractsAllFields() {
        let doc = GiniQRCodeDocument(scannedString: makeUPNQR())
        #expect(doc.extractedParameters["iban"] == "DE89370400440532013000")
        #expect(doc.extractedParameters["paymentRecipient"] == "Gini d.o.o.")
        #expect(doc.extractedParameters["amountToPay"] == "480.50:EUR")
        #expect(doc.extractedParameters["bic"] == "LJBASI2X")
        #expect(doc.extractedParameters["paymentReference"] == "SI00 1234-5678")
    }

    @Test func convertsCentsToDecimalEUR() {
        let doc = GiniQRCodeDocument(scannedString: makeUPNQR(amountCents: "00000048050"))
        #expect(doc.extractedParameters["amountToPay"] == "480.50:EUR")
    }

    @Test func emptyReferenceOmitsPaymentReference() {
        let doc = GiniQRCodeDocument(scannedString: makeUPNQR(reference: ""))
        #expect(doc.extractedParameters["paymentReference"] == nil)
    }

    @Test func fallsBackToPayerReferenceWhenPaymentReferenceIsEmpty() {
        var lines = Array(repeating: "", count: 20)
        lines[0]  = "UPNQR"
        lines[4]  = "SI01-999"
        lines[8]  = "0000010000"
        lines[14] = "DE89370400440532013000"
        lines[16] = "Gini d.o.o."
        let doc = GiniQRCodeDocument(scannedString: lines.joined(separator: "\n"))
        #expect(doc.extractedParameters["paymentReference"] == "SI01-999")
    }
}
