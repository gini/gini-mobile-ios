//
//  HUB3QRCodeTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import XCTest
@testable import GiniCaptureSDK

@Suite("HUB3 QR Code")
struct HUB3QRCodeTests {

    private func makeHUB3(currency: String = "EUR",
                           amountCents: String = "000000000010000",
                           payee: String = "Gini d.o.o.",
                           iban: String = "DE89370400440532013000",
                           reference: String = "HR00 1234567890") -> String {
        var lines = Array(repeating: "", count: 14)
        lines[0]  = "HRVHUB30"
        lines[1]  = currency
        lines[2]  = amountCents
        lines[6]  = payee
        lines[9]  = iban
        lines[11] = reference
        return lines.joined(separator: "\n")
    }

    @Test func detectedAsHUB3() {
        let doc = GiniQRCodeDocument(scannedString: makeHUB3())
        #expect(doc.qrCodeFormat == .hub3)
    }

    @Test func extractsAllFields() {
        let doc = GiniQRCodeDocument(scannedString: makeHUB3())
        #expect(doc.extractedParameters["iban"] == "DE89370400440532013000")
        #expect(doc.extractedParameters["paymentRecipient"] == "Gini d.o.o.")
        #expect(doc.extractedParameters["amountToPay"] == "100.00:EUR")
        #expect(doc.extractedParameters["paymentReference"] == "HR00 1234567890")
    }

    @Test func convertsCentsToDecimalEUR() {
        let doc = GiniQRCodeDocument(scannedString: makeHUB3(amountCents: "000000000010000"))
        #expect(doc.extractedParameters["amountToPay"] == "100.00:EUR")
    }

    @Test func paymentReferenceUsesCallNumberFieldDirectly() {
        let doc = GiniQRCodeDocument(scannedString: makeHUB3(reference: "HR99 555-666"))
        #expect(doc.extractedParameters["paymentReference"] == "HR99 555-666")
    }
}
