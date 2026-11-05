//
//  ExtractionsContainerTest.swift
//  GiniBankAPI-Unit-Tests
//
//  Created by Enrique del Pozo Gómez on 3/20/19.
//

import XCTest
@testable import GiniBankAPILibrary

final class ExtractionsContainerTest: XCTestCase {
    
    lazy var extractionsContainerJson = loadFile(withName: "extractionsContainer", ofType: "json")
    lazy var extractionsWOCandidatesJson = loadFile(withName: "extractionsContainerWOCandidates", ofType: "json")
    
    func testExtractionsContainerDecodingDoesNotThrow() {
        XCTAssertNoThrow(try JSONDecoder().decode(ExtractionsContainer.self, from: extractionsContainerJson),
                         "extractions container should be decoded")
    }
    
    func testExtractionsContainerWOCandidatesDecodingDoesNotThrow() {
        XCTAssertNoThrow(try JSONDecoder().decode(ExtractionsContainer.self, from: extractionsWOCandidatesJson),
                         "extractions container without candidates should be decoded")
    }
    
    func testCrossBorderPaymentDecoding() throws {
        let json = loadFile(withName: "extractionsContainerWithCrossBorderPayment", ofType: "json")
        let container = try JSONDecoder().decode(ExtractionsContainer.self, from: json)

        let crossBorderPayment = try XCTUnwrap(container.compoundExtractions?.crossBorderPayment,
                                               "crossBorderPayment should be present")

        XCTAssertEqual(crossBorderPayment.count, 1, "Expected 1 cross-border payment group")

        let group = try XCTUnwrap(crossBorderPayment.first, "First group should exist")
        XCTAssertEqual(group.count, 4, "Expected 4 extractions in the group")

        let fieldNames = group.compactMap { $0.name }
        XCTAssertTrue(fieldNames.contains("iban"), "Group should contain 'iban' extraction")
        XCTAssertTrue(fieldNames.contains("bic"), "Group should contain 'bic' extraction")
        XCTAssertTrue(fieldNames.contains("bankName"), "Group should contain 'bankName' extraction")
        XCTAssertTrue(fieldNames.contains("paymentRecipient"), "Group should contain 'paymentRecipient' extraction")

        let ibanExtraction = Extraction(box: Extraction.Box(height: 9.0,
                                                            left: 72.0,
                                                            page: 1,
                                                            top: 100.0,
                                                            width: 140.0),
                                        candidates: nil,
                                        entity: "iban",
                                        value: "GB29NWBK60161331926819",
                                        name: "iban")
        XCTAssertTrue(group.contains(ibanExtraction), "Group should contain the expected IBAN extraction with name set")
    }

    func testCreditNoteExtractionsDecoding() throws {
        let json = loadFile(withName: "extractionsContainerCreditNote", ofType: "json")
        let container = try JSONDecoder().decode(ExtractionsContainer.self, from: json)

        XCTAssertEqual(container.extractions.count, 8)
        XCTAssertEqual(container.extractions.first(where: { $0.name == "businessDocType" })?.value,
                       "CreditNote")
        XCTAssertEqual(container.extractions.first(where: { $0.name == "amountToPay" })?.value,
                       "12.75:EUR")
        XCTAssertNil(container.compoundExtractions, "Credit note payload carries no compound extractions")
        XCTAssertEqual(container.candidates.count, 4)
        XCTAssertEqual(container.candidates["ibans"]?.count, 2)
    }

    func testExtractionsContainerDecoding() throws {
        
        let container = try JSONDecoder().decode(ExtractionsContainer.self, from: extractionsContainerJson)
        
        XCTAssertEqual(container.extractions.count, 2)
        
        let extraction = Extraction(box: Extraction.Box(height: 9.0,
                                                        left: 521.48,
                                                        page: 1,
                                                        top: 459.11,
                                                        width: 27.519999999999982),
                                    candidates: "amounts",
                                    entity: "amount",
                                    value: "123.93:EUR",
                                    name: "amountToPay")
        
        XCTAssertTrue(container.extractions.contains(extraction))
        
        let lineItemExtraction = Extraction(box: Extraction.Box(height: 9.0,
                                                                left: 72.0,
                                                                page: 1,
                                                                top: 347.11,
                                                                width: 5.0),
                                            candidates: nil,
                                            entity: "number",
                                            value: "1",
                                            name: "quantity")
        
        XCTAssertEqual(container.compoundExtractions!.lineItems!.count, 3)
        XCTAssertEqual(container.compoundExtractions!.lineItems!.first!.count, 4)
        XCTAssertTrue(container.compoundExtractions!.lineItems!.first!.contains(lineItemExtraction))

        let candidate = Extraction.Candidate(box: Extraction.Box(height: 9.0,
                                                                 left: 521.48,
                                                                 page: 1,
                                                                 top: 459.11,
                                                                 width: 27.519999999999982),
                                             entity: "amount",
                                             value: "123.93:EUR")
        
        XCTAssertEqual(container.candidates.count, 2)
        XCTAssertEqual(container.candidates["amounts"]!.first, candidate)
    }

    // MARK: - Fraud signals (PP-3959)

    /**
     Base fixture that holds both known signals. All other scenarios (QR-only,
     country-only, unknown code, explicit empty) are derived from this by
     mutating the decoded JSON tree in-memory — one fixture on disk, one source
     of truth for the wire shape, scenario variance expressed in test code.
     */
    private func baseFraudSignalsJSON() throws -> [String: Any] {
        let data = loadFile(withName: "extractionsContainerWithFraudSignals", ofType: "json")
        return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any],
                             "Base fixture must decode as a JSON object")
    }

    private func decode(json: [String: Any]) throws -> ExtractionsContainer {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(ExtractionsContainer.self, from: data)
    }

    private func fraudSignalGroups(in json: [String: Any]) -> [[String: Any]]? {
        let compound = json["compoundExtractions"] as? [String: Any]
        return compound?["fraudSignals"] as? [[String: Any]]
    }

    private func setFraudSignalGroups(_ groups: [[String: Any]]?,
                                      in json: inout [String: Any]) {
        var compound = (json["compoundExtractions"] as? [String: Any]) ?? [:]
        if let groups {
            compound["fraudSignals"] = groups
        } else {
            compound.removeValue(forKey: "fraudSignals")
        }
        json["compoundExtractions"] = compound
    }

    /**
     Returns `(QR_PRINTED_IBAN_MISMATCH group, IBAN_COUNTRY_MISMATCH group)` from
     the base fixture, matched by the `signalCode.value` field.
     */
    private func knownGroups(in groups: [[String: Any]]) -> (qr: [String: Any], country: [String: Any])? {
        func codeValue(_ group: [String: Any]) -> String? {
            ((group["signalCode"] as? [String: Any])?["value"] as? String)
        }
        let qr = groups.first(where: { codeValue($0) == "QR_PRINTED_IBAN_MISMATCH" })
        let country = groups.first(where: { codeValue($0) == "IBAN_COUNTRY_MISMATCH" })
        guard let qr, let country else { return nil }
        return (qr, country)
    }

    private func byName(_ group: [Extraction]) -> [String: Extraction] {
        Dictionary(uniqueKeysWithValues: group.compactMap { extraction -> (String, Extraction)? in
            guard let name = extraction.name else { return nil }
            return (name, extraction)
        })
    }

    // MARK: Happy paths

    func testFraudSignalsQRPrintedIBANMismatchDecoding() throws {
        var json = try baseFraudSignalsJSON()
        let allGroups = try XCTUnwrap(fraudSignalGroups(in: json))
        let (qr, _) = try XCTUnwrap(knownGroups(in: allGroups))
        setFraudSignalGroups([qr], in: &json)

        let container = try decode(json: json)
        let groups = try XCTUnwrap(container.fraudSignalsRaw)

        XCTAssertEqual(groups.count, 1)
        let group = try XCTUnwrap(groups.first)
        XCTAssertEqual(group.count, 3, "QR_PRINTED_IBAN_MISMATCH carries 3 members")

        let fields = byName(group)
        XCTAssertEqual(fields["signalCode"]?.value, "QR_PRINTED_IBAN_MISMATCH")
        XCTAssertEqual(fields["severity"]?.value, "CHECK")
        XCTAssertEqual(fields["iban"]?.value, "DE89370400440532013000")
    }

    func testExtractionResultFraudSignalsQRPrintedIBANMismatchPassthrough() throws {
        var json = try baseFraudSignalsJSON()
        let allGroups = try XCTUnwrap(fraudSignalGroups(in: json))
        let (qr, _) = try XCTUnwrap(knownGroups(in: allGroups))
        setFraudSignalGroups([qr], in: &json)

        let container = try decode(json: json)
        let result = ExtractionResult(extractionsContainer: container)

        XCTAssertEqual(result.fraudSignalsRaw?.count, container.fraudSignalsRaw?.count)
        let resultNames = result.fraudSignalsRaw?.first?.compactMap { $0.name }.sorted()
        let containerNames = container.fraudSignalsRaw?.first?.compactMap { $0.name }.sorted()
        XCTAssertEqual(resultNames, containerNames)
    }

    func testFraudSignalsIBANCountryMismatchDecoding() throws {
        var json = try baseFraudSignalsJSON()
        let allGroups = try XCTUnwrap(fraudSignalGroups(in: json))
        let (_, country) = try XCTUnwrap(knownGroups(in: allGroups))
        setFraudSignalGroups([country], in: &json)

        let container = try decode(json: json)
        let groups = try XCTUnwrap(container.fraudSignalsRaw)

        XCTAssertEqual(groups.count, 1)
        let group = try XCTUnwrap(groups.first)
        XCTAssertEqual(group.count, 4, "IBAN_COUNTRY_MISMATCH carries 4 members")

        let fields = byName(group)
        XCTAssertEqual(fields["signalCode"]?.value, "IBAN_COUNTRY_MISMATCH")
        XCTAssertEqual(fields["severity"]?.value, "STOP")
        XCTAssertEqual(fields["iban"]?.value, "GB29NWBK60161331926819")
        XCTAssertEqual(fields["creditorCountry"]?.value, "DE")
    }

    func testExtractionResultFraudSignalsIBANCountryMismatchPassthrough() throws {
        var json = try baseFraudSignalsJSON()
        let allGroups = try XCTUnwrap(fraudSignalGroups(in: json))
        let (_, country) = try XCTUnwrap(knownGroups(in: allGroups))
        setFraudSignalGroups([country], in: &json)

        let container = try decode(json: json)
        let result = ExtractionResult(extractionsContainer: container)

        XCTAssertEqual(result.fraudSignalsRaw?.count, 1)
        XCTAssertEqual(result.fraudSignalsRaw?.first?.count, 4)
    }

    func testFraudSignalsBothDecoding() throws {
        let json = try baseFraudSignalsJSON()
        let container = try decode(json: json)
        let groups = try XCTUnwrap(container.fraudSignalsRaw)

        XCTAssertEqual(groups.count, 2)
        let codes = groups.compactMap { group in
            group.first(where: { $0.name == "signalCode" })?.value
        }
        XCTAssertEqual(Set(codes), Set(["QR_PRINTED_IBAN_MISMATCH", "IBAN_COUNTRY_MISMATCH"]))
    }

    func testExtractionResultFraudSignalsBothPassthrough() throws {
        let json = try baseFraudSignalsJSON()
        let container = try decode(json: json)
        let result = ExtractionResult(extractionsContainer: container)

        XCTAssertEqual(result.fraudSignalsRaw?.count, 2)
    }

    // MARK: Error paths

    func testFraudSignalsUnknownSignalDecoding() throws {
        var json = try baseFraudSignalsJSON()
        var allGroups = try XCTUnwrap(fraudSignalGroups(in: json))
        var qr = try XCTUnwrap(knownGroups(in: allGroups)).qr
        var codeExtraction = try XCTUnwrap(qr["signalCode"] as? [String: Any])
        codeExtraction["value"] = "FOO_BAR"
        qr["signalCode"] = codeExtraction
        allGroups = [qr]
        setFraudSignalGroups(allGroups, in: &json)

        let container = try decode(json: json)
        let groups = try XCTUnwrap(container.fraudSignalsRaw,
                                   "Unknown codes must not drop the element at decode time")

        XCTAssertEqual(groups.count, 1)
        let group = try XCTUnwrap(groups.first)
        XCTAssertEqual(byName(group)["signalCode"]?.value, "FOO_BAR")
    }

    func testExtractionResultFraudSignalsUnknownPassthrough() throws {
        var json = try baseFraudSignalsJSON()
        var allGroups = try XCTUnwrap(fraudSignalGroups(in: json))
        var qr = try XCTUnwrap(knownGroups(in: allGroups)).qr
        var codeExtraction = try XCTUnwrap(qr["signalCode"] as? [String: Any])
        codeExtraction["value"] = "FOO_BAR"
        qr["signalCode"] = codeExtraction
        allGroups = [qr]
        setFraudSignalGroups(allGroups, in: &json)

        let container = try decode(json: json)
        let result = ExtractionResult(extractionsContainer: container)

        XCTAssertEqual(result.fraudSignalsRaw?.count, 1)
    }

    func testFraudSignalsAbsentDecoding() throws {
        let json = loadFile(withName: "extractionsContainer", ofType: "json")
        let container = try JSONDecoder().decode(ExtractionsContainer.self, from: json)

        XCTAssertNil(container.fraudSignalsRaw, "Absent fraudSignals key must decode to nil")
        XCTAssertNotNil(container.compoundExtractions?.lineItems, "lineItems must still decode")
        XCTAssertFalse(container.extractions.isEmpty, "extractions must still decode")
    }

    func testExtractionResultFraudSignalsAbsentIsNil() throws {
        let json = loadFile(withName: "extractionsContainer", ofType: "json")
        let container = try JSONDecoder().decode(ExtractionsContainer.self, from: json)
        let result = ExtractionResult(extractionsContainer: container)

        XCTAssertNil(result.fraudSignalsRaw)
    }

    func testFraudSignalsEmptyArrayDecoding() throws {
        var json = try baseFraudSignalsJSON()
        setFraudSignalGroups([], in: &json)

        let container = try decode(json: json)
        let groups = try XCTUnwrap(container.fraudSignalsRaw,
                                   "Explicit [] must decode to an empty array, not nil")
        XCTAssertEqual(groups.count, 0)
    }

    func testExtractionResultFraudSignalsEmptyPassthrough() throws {
        var json = try baseFraudSignalsJSON()
        setFraudSignalGroups([], in: &json)

        let container = try decode(json: json)
        let result = ExtractionResult(extractionsContainer: container)

        XCTAssertEqual(result.fraudSignalsRaw?.count, 0)
    }
}
