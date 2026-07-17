//
//  PayBySquareQRCodeTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import Foundation
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
    // beneficiary name is non-empty and which carries a valid CRC32 checksum. The bysquare
    // layout places two extension-presence flags between the bank account and the beneficiary
    // name, so the payee sits at field [16]. Regression guard for the beneficiary-index off-by
    // bug (payeeName came back empty).
    private let beneficiaryVector =
        "0006000046NDD9V2BE1292JFQB6ID43925N5B44410GB6T3V0MFFAURJBEJBJ5T5FKNPDLSSNQC6BJTNV7" +
        "V73AH0H65DTIL5AV5C5M0JPNVU3U0SD5DKFD82SDR1H66RLEO3IJUTGH38BJAG1BVVA1B400"

    // Same well-formed payload as `beneficiaryVector` but with a zeroed (invalid) CRC32 prefix.
    // It decompresses cleanly, so it isolates the checksum check: a decoder that verifies CRC32
    // must reject it and produce no parameters.
    private let invalidCRCVector =
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

    @Test func rejectsPayloadWithInvalidCRC() {
        // Decompresses to well-formed fields but the CRC32 prefix does not match, so decoding
        // must fail and yield no parameters.
        let doc = GiniQRCodeDocument(scannedString: invalidCRCVector)
        #expect(doc.extractedParameters.isEmpty)
    }

    @Test func invalidCRCPayloadFailsValidation() {
        let doc = GiniQRCodeDocument(scannedString: invalidCRCVector)
        #expect(throws: DocumentValidationError.qrCodeFormatNotValid) {
            try GiniCaptureDocumentValidator.validate(doc, withConfig: config)
        }
    }
}

@Suite("Pay by Square field mapping")
struct PayBySquareFieldMappingTests {

    /// Lays out the bysquare fields positionally in spec order (v1.1), independent of the
    /// decoder's `beneficiaryIdx` arithmetic. Because the beneficiary is placed by counting
    /// real fields rather than by the same formula the decoder uses, a regression in that
    /// arithmetic (off-by-one, wrong multiplier, dropped presence flags) makes the payee
    /// come back wrong and fails the test.
    ///
    /// Note: the block sizes (two presence flags, +4 standing order, +10 direct debit) are
    /// the same spec constants the decoder assumes; independently verifying *those* would
    /// require a real captured standing-order / direct-debit vector.
    private func buildFields(paymentOptions: Int,
                             banksCount: Int = 1,
                             iban: String = "SK2811000000002620154106",
                             beneficiary: String) -> [String] {
        var fields = [String](repeating: "", count: 12)   // header block [0]...[11]
        fields[2]  = String(paymentOptions)               // paymentType bitmask
        fields[3]  = "12.50"                               // amount
        fields[4]  = "EUR"                                 // currencyCode
        fields[6]  = "2017001"                             // variableSymbol
        fields[10] = "Note"                                // paymentNote
        fields[11] = String(banksCount)                    // bankAccountsCount

        // Bank accounts: IBAN + BIC per account; the first account carries the test IBAN.
        for index in 0..<banksCount {
            fields.append(index == 0 ? iban : "SK0000000000000000000000")
            fields.append("")   // BIC
        }
        // Two extension-presence flag fields always follow the bank accounts.
        fields.append((paymentOptions & 2) != 0 ? "1" : "0")
        fields.append((paymentOptions & 4) != 0 ? "1" : "0")
        // Standing-order extension block: 4 fields.
        if (paymentOptions & 2) != 0 { fields.append(contentsOf: Array(repeating: "so", count: 4)) }
        // Direct-debit extension block: 10 fields.
        if (paymentOptions & 4) != 0 { fields.append(contentsOf: Array(repeating: "dd", count: 10)) }
        // Beneficiary fields.
        fields.append(beneficiary)   // beneficiaryName
        fields.append("")            // beneficiary address line 1
        fields.append("")            // beneficiary address line 2
        return fields
    }

    @Test func paymentOrderBeneficiaryAtBaseIndex() {
        let fields = buildFields(paymentOptions: 1, beneficiary: "Payment Order Payee")
        #expect(PayBySquareDecoder.makePayment(fromFields: fields).payeeName == "Payment Order Payee")
    }

    @Test func standingOrderShiftsBeneficiary() {
        let fields = buildFields(paymentOptions: 2, beneficiary: "Standing Order Payee")
        #expect(PayBySquareDecoder.makePayment(fromFields: fields).payeeName == "Standing Order Payee")
    }

    @Test func directDebitShiftsBeneficiary() {
        let fields = buildFields(paymentOptions: 4, beneficiary: "Direct Debit Payee")
        #expect(PayBySquareDecoder.makePayment(fromFields: fields).payeeName == "Direct Debit Payee")
    }

    @Test func bothExtensionsShiftBeneficiary() {
        let fields = buildFields(paymentOptions: 6, beneficiary: "Both Extensions Payee")
        #expect(PayBySquareDecoder.makePayment(fromFields: fields).payeeName == "Both Extensions Payee")
    }

    @Test func multipleAccountsShiftBeneficiary() {
        let fields = buildFields(paymentOptions: 2, banksCount: 2, beneficiary: "Multi Account Payee")
        #expect(PayBySquareDecoder.makePayment(fromFields: fields).payeeName == "Multi Account Payee")
    }

    @Test func mapsCoreFieldsWithExtensionsPresent() {
        let fields = buildFields(paymentOptions: 4, beneficiary: "Payee")
        let payment = PayBySquareDecoder.makePayment(fromFields: fields)
        #expect(payment.iban == "SK2811000000002620154106")
        #expect(payment.amount == "12.50")
        #expect(payment.currency == "EUR")
        #expect(payment.paymentReference == "2017001 Note")
    }
}
