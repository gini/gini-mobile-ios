//
//  PayBySquareQRCodeTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import XCTest
@testable import GiniCaptureSDK

@Suite("Pay by Square QR Code")
struct PayBySquareQRCodeTests {

    let config = GiniConfiguration()

    // 16-char base32hex string. Upper nibble of bytes[0] = bysquareType != 0, so decode() returns nil.
    private let detectionString = "ABCDEF0123456789"

    @Test func detectedAsPayBySquare() {
        let doc = GiniQRCodeDocument(scannedString: detectionString)
        #expect(doc.qrCodeFormat == .payBySquare)
    }

    @Test func nonBase32HexStringNotDetected() {
        // 'W' is outside the base32hex alphabet (0–9, A–V); uppercasing won't rescue it
        let doc = GiniQRCodeDocument(scannedString: "WWWWWWWWWWWWWWWW")
        #expect(doc.qrCodeFormat != .payBySquare)
    }

    @Test func corruptPayloadYieldsEmptyParameters() {
        let doc = GiniQRCodeDocument(scannedString: detectionString)
        #expect(doc.extractedParameters.isEmpty)
    }

    @Test func corruptPayloadFailsValidation() {
        let doc = GiniQRCodeDocument(scannedString: detectionString)
        #expect(throws: DocumentValidationError.qrCodeFormatNotValid) {
            try GiniCaptureDocumentValidator.validate(doc, withConfig: config)
        }
    }

    // Official bysquare test vector from the bysquare spec (Confluence page 1300430853).
    // Encodes: IBAN SK2811000000002620154106, amount 12 EUR, variable symbol 2017001,
    // payment note "PAY bysquare - platba za webovú službu balík Wise".
    private let officialTestVector =
        "0008400060RT11GHI1H3ICS8RR40PJJKAMLODMK50MI251UDD11UNM7E306OLN8AGMJUTE" +
        "SOV4TTES0CMS44EP8OJ9JO3RQP89UE7GME4GHQ9GG62L461V517BI4186SI8J5KT45VUGH" +
        "OOG9AM35MC87I22BUPU8O2HQLVCDV1DMSQOT1BMEGH00"

    @Test func officialTestVectorDetectedAsPayBySquare() {
        let doc = GiniQRCodeDocument(scannedString: officialTestVector)
        #expect(doc.qrCodeFormat == .payBySquare)
    }

    @Test func officialTestVectorDecodesIBAN() {
        let doc = GiniQRCodeDocument(scannedString: officialTestVector)
        #expect(doc.extractedParameters["iban"] == "SK2811000000002620154106")
    }

    @Test func officialTestVectorDecodesAmount() {
        let doc = GiniQRCodeDocument(scannedString: officialTestVector)
        #expect(doc.extractedParameters["amountToPay"] == "12:EUR")
    }

    @Test func officialTestVectorDecodesPaymentReference() {
        // variableSymbol "2017001" + " " + paymentNote "PAY bysquare - platba za webovú službu balík Wise"
        let expected = "2017001 PAY bysquare - platba za webov\u{00FA} službu bal\u{00ED}k Wise"
        let doc = GiniQRCodeDocument(scannedString: officialTestVector)
        #expect(doc.extractedParameters["paymentReference"] == expected)
    }

    // Synthetic payment-order vector (paymentOptions=1, one account, no extensions) whose
    // beneficiary name is non-empty. The bysquare layout places two extension-presence flags
    // between the bank account and the beneficiary name, so the payee sits at field [16].
    // Regression guard for the beneficiary-index off-by bug (payeeName came back empty).
    private let beneficiaryVector =
        "0006000001K919RSC458AF4QJ6NUS2G6TL8ENCAV7O09E5DAUA1LMFJ72D0V200TU6BNT3" +
        "SGC80TTOS65JRAK7439GKVLUPIUAUH6IHCMFIOGAL28LRLPQFTAGSEBVH6RD52SI1PTNRQ" +
        "EEFVTAC3000"

    @Test func decodesBeneficiaryName() {
        let doc = GiniQRCodeDocument(scannedString: beneficiaryVector)
        #expect(doc.extractedParameters["paymentRecipient"] == "Test Payee GmbH")
    }

    @Test func beneficiaryVectorDecodesIBANAndAmount() {
        let doc = GiniQRCodeDocument(scannedString: beneficiaryVector)
        #expect(doc.extractedParameters["iban"] == "SK2811000000002620154106")
        #expect(doc.extractedParameters["amountToPay"] == "12.50:EUR")
    }

    @Test func officialTestVectorPassesValidation() {
        let doc = GiniQRCodeDocument(scannedString: officialTestVector)
        #expect(throws: Never.self) {
            try GiniCaptureDocumentValidator.validate(doc, withConfig: config)
        }
    }
}
