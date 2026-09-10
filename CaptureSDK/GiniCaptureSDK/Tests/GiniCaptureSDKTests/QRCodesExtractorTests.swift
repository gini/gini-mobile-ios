//
//  QRCodesExtractorTests.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import Foundation
import Testing
@testable import GiniCaptureSDK

/**
 Swift Testing suite for `QRCodesExtractor`.

 Every test case is driven by a single consolidated JSON fixture at
 `Tests/GiniCaptureSDKTests/Resources/qrCodesExtractorFixtures.json`.
 The root of that file is a `[String: QRCodeFixture]` map keyed by a
 stable id (e.g. `"bezahl_all_fields"`); each entry carries the raw QR
 input string and the expected extracted key/value pairs.

 `expected` uses optional string values so a fixture can express the
 three distinct outcomes the extractor produces:
 - a real value (`String`) — key must be present with that exact value,
 - an empty string (`""`) — key must be present with an empty string,
 - an absent key (`null`) — key must be missing from the result.
 */
@Suite("QRCodesExtractor")
struct QRCodesExtractorTests {

    private static let fixtures: [String: QRCodeFixture] = {
        guard let data = GiniCaptureTestsHelper.fileData(named: "qrCodesExtractorFixtures",
                                                         fileExtension: "json") else {
            fatalError("Missing qrCodesExtractorFixtures.json in tests")
        }
        do {
            return try JSONDecoder().decode([String: QRCodeFixture].self, from: data)
        } catch {
            fatalError("Could not decode qrCodesExtractorFixtures.json: \(error)")
        }
    }()

    private func fixture(_ id: String,
                         sourceLocation: SourceLocation = #_sourceLocation) throws -> QRCodeFixture {
        try #require(Self.fixtures[id],
                     "Missing fixture id: \(id)",
                     sourceLocation: sourceLocation)
    }

    /**
     Compares the actual `[String: String]` extraction result against the
     fixture's `expected` map.

     - A non-nil expected value asserts that the actual dictionary contains
       that exact string for the key (including `""` when the extractor is
       documented to emit an empty string).
     - A `nil` expected value asserts that the key is absent from the
       dictionary — mirroring the original `XCTAssertNil(parameters[key])`
       assertions from the XCTest suite.
     */
    private func assertMatches(_ actual: [String: String],
                               _ expected: [String: String?],
                               sourceLocation: SourceLocation = #_sourceLocation) {
        for (key, expectedValue) in expected {
            if let expectedValue {
                #expect(actual[key] == expectedValue,
                        "Key \"\(key)\" expected \"\(expectedValue)\", got \"\(actual[key] ?? "nil")\"",
                        sourceLocation: sourceLocation)
            } else {
                #expect(actual[key] == nil,
                        "Key \"\(key)\" expected absent, got \"\(actual[key] ?? "nil")\"",
                        sourceLocation: sourceLocation)
            }
        }
    }

    // MARK: - extractParameters(from:withFormat:)

    @Test("Bezahl format is dispatched through the format-based extractor")
    func extractsBezahlViaFormatDispatcher() throws {
        let f = try fixture("bezahl_dispatcher")
        let parameters = QRCodesExtractor.extractParameters(from: f.input,
                                                            withFormat: .bezahl)
        assertMatches(parameters, f.expected)
    }

    @Test("EPC06912 format is dispatched through the format-based extractor")
    func extractsEPC06912ViaFormatDispatcher() throws {
        let f = try fixture("epc06912_dispatcher")
        let parameters = QRCodesExtractor.extractParameters(from: f.input,
                                                            withFormat: .epc06912)
        assertMatches(parameters, f.expected)
    }

    @Test("EPS4Mobile format returns the raw URL under epsCodeUrlKey")
    func extractsEPS4MobileViaFormatDispatcher() throws {
        let f = try fixture("eps4mobile_url")
        let parameters = QRCodesExtractor.extractParameters(from: f.input,
                                                            withFormat: .eps4mobile)
        assertMatches(parameters, f.expected)
    }

    @Test("Gini QR code format returns the raw URL under giniCodeUrlKey")
    func extractsGiniQRCodeViaFormatDispatcher() throws {
        let f = try fixture("giniqrcode_url")
        let parameters = QRCodesExtractor.extractParameters(from: f.input,
                                                            withFormat: .giniQRCode)
        assertMatches(parameters, f.expected)
    }

    @Test("Nil format returns an empty dictionary")
    func nilFormatReturnsEmpty() {
        let parameters = QRCodesExtractor.extractParameters(from: "any string",
                                                            withFormat: nil)
        #expect(parameters.isEmpty, "When format is nil, should return empty dictionary")
    }

    // MARK: - extractParameters(fromBezahlCodeString:)

    @Test("Bezahl code with every field populated is fully extracted")
    func bezahlAllFields() throws {
        let f = try fixture("bezahl_all_fields")
        let parameters = QRCodesExtractor.extractParameters(fromBezahlCodeString: f.input)
        assertMatches(parameters, f.expected)
    }

    @Test("Bezahl code with only IBAN omits every other key")
    func bezahlMissingFields() throws {
        let f = try fixture("bezahl_missing_fields")
        let parameters = QRCodesExtractor.extractParameters(fromBezahlCodeString: f.input)
        assertMatches(parameters, f.expected)
    }

    @Test("Bezahl code with invalid IBAN drops the iban key after validation")
    func bezahlInvalidIBAN() throws {
        let f = try fixture("bezahl_invalid_iban")
        let parameters = QRCodesExtractor.extractParameters(fromBezahlCodeString: f.input)
        assertMatches(parameters, f.expected)
    }

    @Test("Bezahl code falls back to reason1 when reason is absent")
    func bezahlReason1Fallback() throws {
        /// Reason1 is intentionally read from the raw `queryParameters`, so
        /// percent-encoded values won't be decoded — see the extractor for
        /// the known behaviour this fixture mirrors.
        let f = try fixture("bezahl_reason1_fallback")
        let parameters = QRCodesExtractor.extractParameters(fromBezahlCodeString: f.input)
        assertMatches(parameters, f.expected)
    }

    @Test("Bezahl code URL-decodes special characters in name and reason")
    func bezahlSpecialCharacters() throws {
        let f = try fixture("bezahl_special_characters")
        let parameters = QRCodesExtractor.extractParameters(fromBezahlCodeString: f.input)
        assertMatches(parameters, f.expected)
    }

    // MARK: - extractParameters(fromEPC06912CodeString:)

    @Test("EPC06912 code with every field populated is fully extracted")
    func epc06912AllFields() throws {
        let f = try fixture("epc06912_all_fields")
        let parameters = QRCodesExtractor.extractParameters(fromEPC06912CodeString: f.input)
        assertMatches(parameters, f.expected)
    }

    @Test("EPC06912 code with only the first two lines returns empty strings for every field")
    func epc06912MinimalFields() throws {
        let f = try fixture("epc06912_minimal_fields")
        let parameters = QRCodesExtractor.extractParameters(fromEPC06912CodeString: f.input)
        assertMatches(parameters, f.expected)
    }

    @Test("EPC06912 code with an empty amount line still extracts every other field")
    func epc06912EmptyAmount() throws {
        let f = try fixture("epc06912_empty_amount")
        let parameters = QRCodesExtractor.extractParameters(fromEPC06912CodeString: f.input)
        assertMatches(parameters, f.expected)
    }

    @Test("EPC06912 code with an invalid IBAN returns an empty IBAN string")
    func epc06912InvalidIBAN() throws {
        let f = try fixture("epc06912_invalid_iban")
        let parameters = QRCodesExtractor.extractParameters(fromEPC06912CodeString: f.input)
        assertMatches(parameters, f.expected)
    }

    @Test("EPC06912 code from an empty string returns empty strings for every field")
    func epc06912EmptyString() throws {
        let f = try fixture("epc06912_empty_string")
        let parameters = QRCodesExtractor.extractParameters(fromEPC06912CodeString: f.input)
        assertMatches(parameters, f.expected)
    }

    // MARK: - QRCodesFormat markers

    @Test("QRCodesFormat markers match their expected prefixes")
    func formatMarkersMatchPrefixes() {
        #expect(QRCodesFormat.epc06912.formatMarker == "BCD",
                "EPC06912 format should have BCD marker")
        #expect(QRCodesFormat.eps4mobile.formatMarker == "epspayment://",
                "EPS4Mobile format should have epspayment:// prefix")
        #expect(QRCodesFormat.bezahl.formatMarker == "bank://",
                "Bezahl format should have bank:// prefix")
        #expect(QRCodesFormat.giniQRCode.formatMarker == "https://pay.gini.net/",
                "Gini QR code format should have https://pay.gini.net/ prefix")
    }

    // MARK: - normalize(amount:currency:) exercised through public methods

    @Test("Amount prefixed with a three-letter currency code is normalized to amount:currency")
    func normalizeAmountWithCurrencyPrefix() throws {
        let f = try fixture("epc06912_currency_prefix")
        let parameters = QRCodesExtractor.extractParameters(fromEPC06912CodeString: f.input)
        assertMatches(parameters, f.expected)
    }

    @Test("Amount paired with an explicit currency parameter is normalized to amount:currency")
    func normalizeAmountWithExplicitCurrency() throws {
        let f = try fixture("bezahl_explicit_currency")
        let parameters = QRCodesExtractor.extractParameters(fromBezahlCodeString: f.input)
        assertMatches(parameters, f.expected)
    }
}

// MARK: - Fixture support

/**
 Uniform shape of each entry in `qrCodesExtractorFixtures.json`.

 `expected` uses optional string values so a fixture can express the
 three distinct outcomes the extractor produces — see the suite doc
 comment above for the exact semantics.
 */
private struct QRCodeFixture: Decodable {
    let input: String
    let expected: [String: String?]
}
