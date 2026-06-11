//
//  GiniQRCodeDocumentTests.swift
//  GiniCapture_Example
//
//  Created by Enrique del Pozo Gómez on 12/5/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniCaptureSDK
final class GiniQRCodeDocumentTests: XCTestCase {
    
    let giniConfiguration: GiniConfiguration = GiniConfiguration()
    
    func testBezahlQRCodeExtractions() {
        let qrDocument = GiniQRCodeDocument(scannedString:
                "bank://singlepaymentsepa?name=Gini Online Shop&reason=A12345-6789&" +
                "iban=DE89370400440532013000&bic=GINIBICXXX&amount=47,65&currency=EUR")

        XCTAssertNoThrow(try GiniCaptureDocumentValidator.validate(qrDocument,
                                                                  withConfig: giniConfiguration),
                         "should throw an error since is valid")
        XCTAssertEqual(qrDocument.extractedParameters["amountToPay"], "47,65:EUR",
                       "amountToPay should match")
        XCTAssertEqual(qrDocument.extractedParameters["paymentRecipient"], "Gini Online Shop",
                       "paymentRecipient should match")
        XCTAssertEqual(qrDocument.extractedParameters["paymentReference"], "A12345-6789",
                       "paymentReference should match")
        XCTAssertEqual(qrDocument.extractedParameters["iban"], "DE89370400440532013000",
                       "iban should match")
        XCTAssertEqual(qrDocument.extractedParameters["bic"], "GINIBICXXX",
                       "bic should match")
    }
    
    func testEPC06912QRCodeExtractions() {
        let scannedString = "BCD\n001\n2\nSCT\nGENODEF1KIL\nMax Mustermann\nDE52210900070088299309\n" +
            "EUR1456.89\n\n457845789452\n\nDiverse Autoteile, Re 789452 KN 457845"
        let qrDocument = GiniQRCodeDocument(scannedString: scannedString)
        XCTAssertNoThrow(try GiniCaptureDocumentValidator.validate(qrDocument,
                                                                  withConfig: giniConfiguration),
                         "should throw an error since is valid")
        XCTAssertEqual(qrDocument.extractedParameters["amountToPay"], "1456.89:EUR",
                       "amountToPay should match")
        XCTAssertEqual(qrDocument.extractedParameters["paymentRecipient"], "Max Mustermann",
                       "paymentRecipient should match")
        XCTAssertEqual(qrDocument.extractedParameters["paymentReference"], "457845789452",
                       "paymentReference should match")
        XCTAssertEqual(qrDocument.extractedParameters["iban"], "DE52210900070088299309",
                       "iban should match")
        XCTAssertEqual(qrDocument.extractedParameters["bic"], "GENODEF1KIL",
                       "bic should match")

    }

    func testEPC06912QRCodeWithDoubleNewLineExtractions() {
        let scannedString = "BCD\r\n001\r\n1\r\nSCT\r\nGENODEF1AB1\r\r\nADJULEX Rechtsanwaelte Feldmann, Klug & Partner\r\r\nDE72795625140001046462\r\r\nEUR54.15\r\n\r\n3372/12 RgNr.: 2201207\r\n"
        let qrDocument = GiniQRCodeDocument(scannedString: scannedString)
        XCTAssertNoThrow(try GiniCaptureDocumentValidator.validate(qrDocument,
                                                                  withConfig: giniConfiguration),
                         "should throw an error since is valid")
        XCTAssertEqual(qrDocument.extractedParameters["amountToPay"], "54.15:EUR",
                       "amountToPay should match")
        XCTAssertEqual(qrDocument.extractedParameters["paymentRecipient"], "ADJULEX Rechtsanwaelte Feldmann, Klug & Partner",
                       "paymentRecipient should match")
        XCTAssertEqual(qrDocument.extractedParameters["paymentReference"], "3372/12 RgNr.: 2201207",
                       "paymentReference should match")
        XCTAssertEqual(qrDocument.extractedParameters["iban"], "DE72795625140001046462",
                       "iban should match")
        XCTAssertEqual(qrDocument.extractedParameters["bic"], "GENODEF1AB1",
                       "bic should match")
    }
    
    func testNotValidQRCodeFormat() {
        let qrDocument = GiniQRCodeDocument(scannedString: "invalidQRCodeFormat")
        XCTAssertThrowsError(try GiniCaptureDocumentValidator.validate(qrDocument,
                                                                      withConfig: giniConfiguration)) { error in
            XCTAssertTrue(error as? DocumentValidationError == DocumentValidationError.qrCodeFormatNotValid,
                          "validation should throw a DocumentaValidationError")
        }
    }
    
    func testNotValidEPC06912QRCodeFormat() {
        let scannedString = "1\n003\n3\nSCT\n5\n6\n7\n8\n9\n10\n11"
        let qrDocument = GiniQRCodeDocument(scannedString: scannedString)
        XCTAssertThrowsError(try GiniCaptureDocumentValidator.validate(qrDocument,
                                                                      withConfig: giniConfiguration),
                             "validation should throw a DocumentaValidationError")
    }
    
    func testGiroCodeQRWithInvalidIBAN(){
        let scannedString = "BCD\n001\n1\nSCT\n\nMister Smith\nDE0212030000000020251\nEUR30\n\n\nTest"
        let qrDocument = GiniQRCodeDocument(scannedString: scannedString)
        XCTAssertThrowsError(try GiniCaptureDocumentValidator.validate(qrDocument,
                                                                      withConfig: giniConfiguration),
                             "validation should throw a DocumentaValidationError")
    }
    
    func testValidStuzzaQR(){
        let scannedString = "BCD\n001\n1\nSCT\nABCDATWW\nExample with fictive data\nAT611904300234573201\nEUR24.2"
        let qrDocument = GiniQRCodeDocument(scannedString: scannedString)
        XCTAssertNoThrow(try GiniCaptureDocumentValidator.validate(qrDocument,
                                                                  withConfig: giniConfiguration),
                         "should not throw an error since qr code is valid")
    }

    func testEPC06912QRCodeWithNullBytePaddedNameExtractions() {
        // EPC QR code where the beneficiary name is padded with null bytes (0x00).
        // Reproduces the Sparkasse case reported by Patrick Horlebein: Apple's QR scanner
        // treats 0x00 as a string terminator, so we must strip them before parsing.
        let nullPaddedName = "AUTOHAUS MARTIN WURST GMBH\u{0000}\u{0000}\u{0000}"
        let scannedString = "BCD\r\n001\r\n2\r\nSCT\r\nGENODES1NUE\r\n\(nullPaddedName)\r\nDE72795625140001046462\r\nEUR123.45\r\n\r\nReference\r\n"
        let qrDocument = GiniQRCodeDocument(scannedString: scannedString)
        XCTAssertNoThrow(try GiniCaptureDocumentValidator.validate(qrDocument,
                                                                  withConfig: giniConfiguration),
                         "should not throw for EPC QR code with null-padded name")
        XCTAssertEqual(qrDocument.extractedParameters["paymentRecipient"], "AUTOHAUS MARTIN WURST GMBH",
                       "null bytes must be stripped from name")
        XCTAssertEqual(qrDocument.extractedParameters["iban"], "DE72795625140001046462",
                       "iban should match")
        XCTAssertEqual(qrDocument.extractedParameters["amountToPay"], "123.45:EUR",
                       "amountToPay should match")
        XCTAssertEqual(qrDocument.extractedParameters["paymentReference"], "Reference",
                       "paymentReference should match")
        XCTAssertEqual(qrDocument.extractedParameters["bic"], "GENODES1NUE",
                       "bic should match")
    }

    func testEPC06912QRCodeSpacesAndNullPaddedNameWithAmountAndReferenceAtLine10() {
        // Realistic Sparkasse QR code structure:
        // - name padded with spaces then null bytes (0x00)
        // - amount has spaces between currency and value ("EUR    10214.94")
        // - reference is at line 10 (unstructured), line 9 (structured) is empty
        let spaces = String(repeating: " ", count: 16)
        let nulls = String(repeating: "\u{0000}", count: 29)
        let paddedName = "AUTOHAUS MARTIN WURST GMBH\(spaces)\(nulls)"
        let scannedString = "BCD\r\n001\r\n2\r\nSCT\r\nGENODES1NUE\r\n\(paddedName)\r\nDE72795625140001046462\r\nEUR    10214.94\r\n\r\n\r\nRg. 21129 - 8160263 vom 02.04.2026\r\n"
        let qrDocument = GiniQRCodeDocument(scannedString: scannedString)
        XCTAssertNoThrow(try GiniCaptureDocumentValidator.validate(qrDocument,
                                                                  withConfig: giniConfiguration),
                         "should not throw for Sparkasse-style EPC QR code")
        XCTAssertEqual(qrDocument.extractedParameters["paymentRecipient"], "AUTOHAUS MARTIN WURST GMBH",
                       "trailing spaces and null bytes must be stripped from name")
        XCTAssertEqual(qrDocument.extractedParameters["iban"], "DE72795625140001046462",
                       "iban should match")
        XCTAssertEqual(qrDocument.extractedParameters["amountToPay"], "10214.94:EUR",
                       "spaces between currency code and value must be stripped")
        XCTAssertEqual(qrDocument.extractedParameters["paymentReference"], "Rg. 21129 - 8160263 vom 02.04.2026",
                       "reference at line 10 must be used when line 9 is empty")
        XCTAssertEqual(qrDocument.extractedParameters["bic"], "GENODES1NUE",
                       "bic should match")
    }

    func testEPC06912QRCodeMissingIBANDoesNotCrash() {
        // Malformed EPC QR code: starts with BCD but IBAN field (index 6) is absent
        // Reproduces PP-2591: "AUTOHAUS MARTIN WURST GMBH" case where QR code stops at beneficiary name
        let scannedString = "BCD\r\n001\r\n2\r\nSCT\r\nGENODES1NUE\r\nAUTOHAUS MARTIN WURST GMBH"
        let qrDocument = GiniQRCodeDocument(scannedString: scannedString)
        XCTAssertThrowsError(try GiniCaptureDocumentValidator.validate(qrDocument,
                                                                      withConfig: giniConfiguration),
                             "should throw a validation error for EPC QR code missing IBAN") { error in
            XCTAssertTrue(error as? DocumentValidationError == DocumentValidationError.qrCodeFormatNotValid,
                          "should throw qrCodeFormatNotValid")
        }
        XCTAssertNil(qrDocument.qrCodeFormat,
                     "qrCodeFormat should be nil for EPC QR code missing IBAN")
    }

    // MARK: - unpackByteModePayload regression tests

    func testUnpackByteModePayloadNonByteModeReturnsNil() {
        // Numeric mode indicator (0b0001) — not byte mode, must return nil
        let numericMode = Data([0b0001_0000, 0x00, 0x00])
        XCTAssertNil(Camera.unpackByteModePayload(numericMode, version: 10))
    }

    func testUnpackByteModePayloadInsufficientBytesReturnsNil() {
        // mode=byte, count=200 (0x00C8) encoded in 16-bit:
        // byte 0: 0x40 (mode=0100, count bits 15–12=0000)
        // byte 1: 0x0C (count bits 11–4 = 0x0C)
        // byte 2: 0x80 (count bits 3–0 = 0x8, no data)
        // 3 bytes provided vs. 2+200=202 needed — must return nil rather than crash
        let tooShort = Data([0x40, 0x0C, 0x80])
        XCTAssertNil(Camera.unpackByteModePayload(tooShort, version: 10))
    }

    func testUnpackByteModePayloadRoundtrip() {
        // Build the exact errorCorrectedPayload bit stream for "BCD" and verify extraction
        let content: [UInt8] = [0x42, 0x43, 0x44] // "BCD"

        // Pack using 16-bit count (version 10+):
        // [0100][0000 0000 0000 0011][0100 0010 0100 0011 0100 0100][0000 padding]
        // Byte 0: 0x40  (mode=0100, count bits 15–12=0000)
        // Byte 1: 0x00  (count bits 11–4=00000000)
        // Byte 2: 0x34  (count bits 3–0=0011=3, 'B' high nibble=0100)
        // Byte 3: 0x24  ('B' low nibble=0010, 'C' high nibble=0100)
        // Byte 4: 0x34  ('C' low nibble=0011, 'D' high nibble=0100)
        // Byte 5: 0x40  ('D' low nibble=0100, terminator=0000)
        let payload = Data([0x40, 0x00, 0x34, 0x24, 0x34, 0x40])
        let result = Camera.unpackByteModePayload(payload, version: 10)
        XCTAssertEqual(result, Data(content), "extracted bytes must match original content")
    }

    // MARK: - Umlaut encoding tests

    func testUnpackByteModePayloadISO88591UmlautFallsBackToLatin1() {
        // 'Ü' in ISO 8859-1 = 0xDC. String(utf8) fails on 0xDC because it is a
        // 2-byte UTF-8 leader with no valid continuation byte — Latin-1 fallback is used.
        //
        // Payload: mode=byte, count=2 (16-bit), content=[0xDC, 0x00]
        // Byte 0: 0x40  (mode=0100, count bits 15–12=0000)
        // Byte 1: 0x00  (count bits 11–4=00000000)
        // Byte 2: 0x2D  (count bits 3–0=0010, 'Ü' high nibble=1101)
        // Byte 3: 0xC0  ('Ü' low nibble=1100, null high nibble=0000)
        // Byte 4: 0x00  (null low nibble=0000, terminator=0000)
        let payload = Data([0x40, 0x00, 0x2D, 0xC0, 0x00])
        guard let extracted = Camera.unpackByteModePayload(payload, version: 10) else {
            return XCTFail("unpackByteModePayload returned nil")
        }
        XCTAssertEqual(extracted, Data([0xDC, 0x00]))
        let cleanData = extracted.filter { $0 != 0x00 }
        let decoded = String(data: cleanData, encoding: .utf8) ?? String(data: cleanData, encoding: .isoLatin1)
        XCTAssertEqual(decoded, "Ü", "ISO 8859-1 umlaut must be recovered via Latin-1 fallback")
    }

    func testUnpackByteModePayloadUTF8UmlautDecodesWithoutFallback() {
        // 'Ü' in UTF-8 = [0xC3, 0x9C]. String(utf8) succeeds — Latin-1 fallback is never reached.
        // If the order were reversed (Latin-1 first), 0xC3 0x9C would decode as "Ã" — wrong.
        //
        // Payload: mode=byte, count=3 (16-bit), content=[0xC3, 0x9C, 0x00]
        // Byte 0: 0x40  (mode=0100, count bits 15–12=0000)
        // Byte 1: 0x00  (count bits 11–4=00000000)
        // Byte 2: 0x3C  (count bits 3–0=0011, 0xC3 high nibble=1100)
        // Byte 3: 0x39  (0xC3 low nibble=0011, 0x9C high nibble=1001)
        // Byte 4: 0xC0  (0x9C low nibble=1100, null high nibble=0000)
        // Byte 5: 0x00  (null low nibble=0000, terminator=0000)
        let payload = Data([0x40, 0x00, 0x3C, 0x39, 0xC0, 0x00])
        guard let extracted = Camera.unpackByteModePayload(payload, version: 10) else {
            return XCTFail("unpackByteModePayload returned nil")
        }
        XCTAssertEqual(extracted, Data([0xC3, 0x9C, 0x00]))
        let cleanData = extracted.filter { $0 != 0x00 }
        let decoded = String(data: cleanData, encoding: .utf8) ?? String(data: cleanData, encoding: .isoLatin1)
        XCTAssertEqual(decoded, "Ü", "UTF-8 umlaut must decode via UTF-8 without Latin-1 fallback")
    }

    func testEPC06912QRCodeISO88591UmlautNameExtracts() {
        // Character set "2" = ISO 8859-1. Camera decodes via Latin-1 fallback;
        // by the time the string reaches GiniQRCodeDocument it is a Swift String.
        let scannedString = "BCD\n001\n2\nSCT\nGENODEF1KIL\nMüller GmbH & Co. KG\nDE52210900070088299309\nEUR250.00"
        let qrDocument = GiniQRCodeDocument(scannedString: scannedString)
        XCTAssertNoThrow(try GiniCaptureDocumentValidator.validate(qrDocument, withConfig: giniConfiguration))
        XCTAssertEqual(qrDocument.extractedParameters["paymentRecipient"], "Müller GmbH & Co. KG")
    }

    func testEPC06912QRCodeUTF8UmlautNameExtracts() {
        // Character set "1" = UTF-8. Camera decodes via String(utf8) first path.
        let scannedString = "BCD\n001\n1\nSCT\nGENODEF1KIL\nMüller GmbH & Co. KG\nDE52210900070088299309\nEUR250.00"
        let qrDocument = GiniQRCodeDocument(scannedString: scannedString)
        XCTAssertNoThrow(try GiniCaptureDocumentValidator.validate(qrDocument, withConfig: giniConfiguration))
        XCTAssertEqual(qrDocument.extractedParameters["paymentRecipient"], "Müller GmbH & Co. KG")
    }

    // MARK: - EPC extractor regression tests

    func testEPC06912QRCodeReferenceAtLine9StillExtractedWhenPresent() {
        // Regression: the line-10 fallback must not shadow a valid structured reference at line 9
        let scannedString = "BCD\n001\n2\nSCT\nGENODEF1KIL\nMax Mustermann\nDE52210900070088299309\n" +
            "EUR1456.89\n\n457845789452\n\nDiverse Autoteile"
        let qrDocument = GiniQRCodeDocument(scannedString: scannedString)
        XCTAssertEqual(qrDocument.extractedParameters["paymentReference"], "457845789452",
                       "structured reference at line 9 must take priority over line 10")
    }

    func testEPC06912QRCodeAmountWithoutSpacesNormalisesCorrectly() {
        // Regression: trimming the amount quantity must not corrupt already-clean amounts
        let scannedString = "BCD\n001\n2\nSCT\nGENODEF1KIL\nMax Mustermann\nDE52210900070088299309\nEUR1456.89"
        let qrDocument = GiniQRCodeDocument(scannedString: scannedString)
        XCTAssertEqual(qrDocument.extractedParameters["amountToPay"], "1456.89:EUR")
    }

    // MARK: - EPC field-separator edge cases

    func testEPC06912QRCodeBareCRSeparatorParsesCorrectly() {
        // Some QR generators use bare \r (CR only) as line endings without \n.
        // splitlines relies on .components(separatedBy: .newlines) to handle these.
        let scannedString = "BCD\r001\r2\rSCT\rGENODEF1KIL\rMax Mustermann\rDE52210900070088299309\rEUR99.00\r\r12345\r"
        let qrDocument = GiniQRCodeDocument(scannedString: scannedString)
        XCTAssertNoThrow(try GiniCaptureDocumentValidator.validate(qrDocument, withConfig: giniConfiguration))
        XCTAssertEqual(qrDocument.extractedParameters["iban"], "DE52210900070088299309")
        XCTAssertEqual(qrDocument.extractedParameters["amountToPay"], "99.00:EUR")
        XCTAssertEqual(qrDocument.extractedParameters["paymentReference"], "12345")
    }

    func testEPC06912QRCodeIBANWithSpacesIsAcceptedButStoredWithSpaces() {
        // IBANValidator.isValid strips spaces before the mod-97 check, so a grouped IBAN
        // like "DE52 2109 ..." passes validation. The QR is therefore accepted as valid EPC.
        // However, extractedParameters retains the original spaces — the backend receives
        // a spaced IBAN. If the backend ever enforces no-space IBANs, this will need fixing.
        let scannedString = "BCD\n001\n2\nSCT\nGENODEF1KIL\nMax Mustermann\nDE52 2109 0007 0088 2993 09\nEUR99.00"
        let qrDocument = GiniQRCodeDocument(scannedString: scannedString)
        XCTAssertNoThrow(try GiniCaptureDocumentValidator.validate(qrDocument, withConfig: giniConfiguration),
                         "IBANValidator strips spaces so the grouped IBAN is still accepted")
        XCTAssertEqual(qrDocument.extractedParameters["iban"], "DE52 2109 0007 0088 2993 09",
                       "spaces are preserved in extractedParameters")
    }

    func testEPC06912QRCodeAmountWithCommaDecimalPreservedAsIs() {
        // The EPC spec requires a decimal point, but some generators produce "EUR1.234,56".
        // normalize keeps the comma in the quantity — this documents current behaviour.
        // If the backend starts rejecting comma decimals, this test will catch the regression.
        let scannedString = "BCD\n001\n2\nSCT\nGENODEF1KIL\nMax Mustermann\nDE52210900070088299309\nEUR1.234,56"
        let qrDocument = GiniQRCodeDocument(scannedString: scannedString)
        XCTAssertEqual(qrDocument.extractedParameters["amountToPay"], "1.234,56:EUR")
    }

    func testGiniQRCode() {
        let scannedString = "https://pay.gini.net/482a6cc2-8247-4724-af5d-24cc44408254"
        let qrDocument = GiniQRCodeDocument(scannedString: scannedString)
        XCTAssertNoThrow(try GiniCaptureDocumentValidator.validate(qrDocument,
                                                                  withConfig: giniConfiguration),
                         "should not throw an error since qr code is valid")
        XCTAssertEqual(qrDocument.qrCodeFormat, .giniQRCode)
    }

    // MARK: - resolveQRString

    func testResolveQRStringWithNilDescriptorReturnsFallback() {
        // When there is no CIQRCodeDescriptor the original stringValue must be returned unchanged
        XCTAssertEqual(Camera.resolveQRString(descriptor: nil, fallbackStringValue: "bank://test"),
                       "bank://test")
    }

    func testResolveQRStringWithNilDescriptorAndNilFallbackReturnsNil() {
        XCTAssertNil(Camera.resolveQRString(descriptor: nil, fallbackStringValue: nil))
    }

    // MARK: - resolveQRString(payload:version:fallbackStringValue:)

    func testResolveQRStringPayloadNonByteModeReturnsFallback() {
        // Numeric-mode indicator (0b0001) — unpackByteModePayload returns nil → fallback
        let numericPayload = Data([0b0001_0000, 0x00, 0x00])
        XCTAssertEqual(Camera.resolveQRString(payload: numericPayload,
                                              version: 1,
                                              fallbackStringValue: "fallback"),
                       "fallback")
    }

    func testResolveQRStringPayloadNonByteModeNilFallbackReturnsNil() {
        let numericPayload = Data([0b0001_0000, 0x00, 0x00])
        XCTAssertNil(Camera.resolveQRString(payload: numericPayload,
                                            version: 1,
                                            fallbackStringValue: nil))
    }

    func testResolveQRStringPayloadNoNullBytesReturnsFallback() {
        // Payload for "Hello" (5 bytes, no 0x00): contentData.contains(0x00) is false → fallback.
        // Byte layout (version 1, 8-bit count=5):
        //   [0100][00000101][01001000 01100101 01101100 01101100 01101111][0000 term]
        let payload = Data([0x40, 0x54, 0x86, 0x56, 0xC6, 0xC6, 0xF0])
        XCTAssertEqual(Camera.resolveQRString(payload: payload,
                                              version: 1,
                                              fallbackStringValue: "original"),
                       "original")
    }

    func testResolveQRStringPayloadWithNullByteDecodesUTF8() {
        // Payload for "Hello\0" (6 bytes): null byte present, content is valid UTF-8.
        // After stripping nulls resolveQRString must return "Hello".
        // Byte layout (version 1, 8-bit count=6):
        //   [0100][00000110][01001000 01100101 01101100 01101100 01101111 00000000][0000 term]
        let payload = Data([0x40, 0x64, 0x86, 0x56, 0xC6, 0xC6, 0xF0, 0x00])
        XCTAssertEqual(Camera.resolveQRString(payload: payload,
                                              version: 1,
                                              fallbackStringValue: "fallback"),
                       "Hello")
    }

    func testResolveQRStringPayloadLatin1NullTerminatedFallsBackToLatin1() {
        // Payload for [0xDC, 0x00] — "Ü\0" in ISO 8859-1.
        // 0xDC is not valid UTF-8, so String(utf8) returns nil and Latin-1 fallback is used.
        // Byte layout (version 1, 8-bit count=2):
        //   [0100][00000010][11011100 00000000][0000 term]
        let payload = Data([0x40, 0x2D, 0xC0, 0x00])
        XCTAssertEqual(Camera.resolveQRString(payload: payload,
                                              version: 1,
                                              fallbackStringValue: "fallback"),
                       "Ü")
    }

    func testResolveQRStringPayloadAllNullsYieldsEmptyString() {
        // Payload where every content byte is 0x00: after stripping all nulls cleanData
        // is empty. String(data:Data(), encoding:.utf8) returns "" — not nil — so
        // resolveQRString returns "" rather than the fallback.
        // Byte layout (version 1, 8-bit count=2, content=[0x00, 0x00]):
        //   [0100][00000010][00000000 00000000][0000 term]
        let payload = Data([0x40, 0x20, 0x00, 0x00])
        XCTAssertEqual(Camera.resolveQRString(payload: payload,
                                              version: 1,
                                              fallbackStringValue: "fallback"),
                       "")
    }

    // MARK: - unpackByteModePayload — version 1–9 path

    func testUnpackByteModePayloadVersion19Roundtrip() {
        // Payload for "BCD" encoded with version 1 (8-bit character count).
        // Bit layout (40 bits = 5 bytes):
        //   [0100][00000011][01000010 01000011 01000100][0000 terminator]
        //   Byte 0: 0x40  (mode=0100, count bits 7–4=0000)
        //   Byte 1: 0x34  (count bits 3–0=0011, 'B' bits 7–4=0100)
        //   Byte 2: 0x24  ('B' bits 3–0=0010, 'C' bits 7–4=0100)
        //   Byte 3: 0x34  ('C' bits 3–0=0011, 'D' bits 7–4=0100)
        //   Byte 4: 0x40  ('D' bits 3–0=0100, terminator=0000)
        let payload = Data([0x40, 0x34, 0x24, 0x34, 0x40])
        XCTAssertEqual(Camera.unpackByteModePayload(payload, version: 1),
                       Data([0x42, 0x43, 0x44]),
                       "version 1 (8-bit count) must extract 'BCD' correctly")
    }

    func testUnpackByteModePayloadSingleByteReturnsNil() {
        // Fewer than 2 bytes — cannot read the mode indicator
        XCTAssertNil(Camera.unpackByteModePayload(Data([0x40]), version: 1))
    }

    func testUnpackByteModePayloadVersion10TwoBytesReturnsNil() {
        // version >= 10 needs 3 bytes to read the 16-bit count; 2 bytes must return nil
        XCTAssertNil(Camera.unpackByteModePayload(Data([0x40, 0x00]), version: 10))
    }

    func testUnpackByteModePayloadZeroCharCountReturnsNil() {
        // Both nibbles of the 8-bit count are zero → charCount = 0 → must return nil
        XCTAssertNil(Camera.unpackByteModePayload(Data([0x40, 0x00]), version: 1))
    }

    // MARK: - EPC extractor missing-field branches

    func testEPC06912QRCodeEmptyBICYieldsEmptyString() {
        // Line 4 (BIC) is empty — extractor must return "" for the "bic" key
        let scannedString = "BCD\n001\n1\nSCT\n\nMax Mustermann\nDE52210900070088299309\nEUR100.00"
        let qrDocument = GiniQRCodeDocument(scannedString: scannedString)
        XCTAssertEqual(qrDocument.extractedParameters["bic"], "")
    }

    func testEPC06912QRCodeEmptyNameYieldsEmptyString() {
        // Line 5 (beneficiary name) is empty — extractor must return "" for "paymentRecipient"
        let scannedString = "BCD\n001\n1\nSCT\nGENODEF1KIL\n\nDE52210900070088299309\nEUR100.00"
        let qrDocument = GiniQRCodeDocument(scannedString: scannedString)
        XCTAssertEqual(qrDocument.extractedParameters["paymentRecipient"], "")
    }

    func testEPC06912QRCodeBothReferencesEmptyYieldsEmptyString() {
        // Both structured reference (line 9) and unstructured reference (line 10) are empty —
        // extractor must return "" for "paymentReference"
        let scannedString = "BCD\n001\n1\nSCT\nGENODEF1KIL\nMax Mustermann\nDE52210900070088299309\nEUR100.00\n\n\n"
        let qrDocument = GiniQRCodeDocument(scannedString: scannedString)
        XCTAssertEqual(qrDocument.extractedParameters["paymentReference"], "")
    }

    func testEPC06912QRCodeAmountWithoutCurrencyPrefixYieldsEmptyAmount() {
        // Amount field has no 3-letter currency prefix — normalize() returns nil,
        // so "amountToPay" must be "" rather than a malformed string
        let scannedString = "BCD\n001\n1\nSCT\nGENODEF1KIL\nMax Mustermann\nDE52210900070088299309\n1456.89"
        let qrDocument = GiniQRCodeDocument(scannedString: scannedString)
        XCTAssertEqual(qrDocument.extractedParameters["amountToPay"], "")
    }

    func testEPC06912QRCodeMissingAmountFieldYieldsEmptyAmount() {
        // Amount field (line 7) is absent entirely — extractor must return "" for "amountToPay"
        let scannedString = "BCD\n001\n1\nSCT\nGENODEF1KIL\nMax Mustermann\nDE52210900070088299309"
        let qrDocument = GiniQRCodeDocument(scannedString: scannedString)
        XCTAssertEqual(qrDocument.extractedParameters["amountToPay"], "")
    }

    // MARK: - qrCodeFormat edge cases

    func testEPC06912QRCodeUnknownCharacterSetIsStillParsed() {
        // Character set "3" is outside the EPC spec (only "1"=UTF-8 and "2"=ISO 8859-1 are valid).
        // The SDK logs a warning but continues rather than rejecting the QR code outright.
        let scannedString = "BCD\n001\n3\nSCT\nGENODEF1KIL\nMax Mustermann\nDE52210900070088299309\nEUR100.00"
        let qrDocument = GiniQRCodeDocument(scannedString: scannedString)
        XCTAssertEqual(qrDocument.qrCodeFormat, .epc06912,
                       "unknown charset must still resolve to epc06912 when IBAN is valid")
        XCTAssertNoThrow(try GiniCaptureDocumentValidator.validate(qrDocument,
                                                                   withConfig: giniConfiguration))
    }
}
