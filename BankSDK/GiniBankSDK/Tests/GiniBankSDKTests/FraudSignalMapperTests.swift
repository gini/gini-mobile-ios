//
//  FraudSignalMapperTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

@_spi(GiniCaptureInternal) @testable import GiniBankAPILibrary
@testable import GiniBankSDK
import XCTest

final class FraudSignalMapperTests: XCTestCase {

    // MARK: - Fixture helpers

    private func extraction(name: String, value: String) -> Extraction {
        Extraction(box: nil,
                   candidates: nil,
                   entity: "text",
                   value: value,
                   name: name)
    }

    private func qrPrintedIbanMismatchGroup(severity: String = "CHECK",
                                            iban: String = "DE89370400440532013000") -> [Extraction] {
        [
            extraction(name: "signalCode", value: "QR_PRINTED_IBAN_MISMATCH"),
            extraction(name: "severity", value: severity),
            extraction(name: "iban", value: iban)
        ]
    }

    private func ibanCountryMismatchGroup(severity: String = "STOP",
                                          iban: String = "GB29NWBK60161331926819",
                                          creditorCountry: String? = "DE") -> [Extraction] {
        var group: [Extraction] = [
            extraction(name: "signalCode", value: "IBAN_COUNTRY_MISMATCH"),
            extraction(name: "severity", value: severity),
            extraction(name: "iban", value: iban)
        ]
        if let creditorCountry {
            group.append(extraction(name: "creditorCountry", value: creditorCountry))
        }
        return group
    }

    private func resultWithRaw(_ raw: [[Extraction]]?) -> ExtractionResult {
        let result = ExtractionResult(extractions: [], candidates: [:])
        result.fraudSignalsRaw = raw
        return result
    }

    // MARK: - Happy path

    func testMapsBothKnownSignals() {
        let result = resultWithRaw([qrPrintedIbanMismatchGroup(),
                                    ibanCountryMismatchGroup()])

        let signals = FraudSignalMapper.map(extractionResult: result)

        XCTAssertEqual(signals.count, 2)
        XCTAssertEqual(signals[0].code, .qrPrintedIbanMismatch)
        XCTAssertEqual(signals[0].severity, .check)
        XCTAssertEqual(signals[0].iban, "DE89370400440532013000")
        XCTAssertNil(signals[0].creditorCountry)

        XCTAssertEqual(signals[1].code, .ibanCountryMismatch)
        XCTAssertEqual(signals[1].severity, .stop)
        XCTAssertEqual(signals[1].iban, "GB29NWBK60161331926819")
        XCTAssertEqual(signals[1].creditorCountry, "DE")
    }

    // MARK: - Error paths

    func testDropsUnknownSignalCode() {
        let unknown: [Extraction] = [
            extraction(name: "signalCode", value: "FOO_BAR"),
            extraction(name: "severity", value: "CHECK"),
            extraction(name: "iban", value: "DE89370400440532013000")
        ]
        let result = resultWithRaw([unknown, qrPrintedIbanMismatchGroup()])

        let signals = FraudSignalMapper.map(extractionResult: result)

        XCTAssertEqual(signals.count, 1)
        XCTAssertEqual(signals.first?.code, .qrPrintedIbanMismatch)
    }

    func testEmptyWhenAllSignalsUnknown() {
        let unknown: [Extraction] = [
            extraction(name: "signalCode", value: "FOO_BAR"),
            extraction(name: "severity", value: "CHECK"),
            extraction(name: "iban", value: "DE89370400440532013000")
        ]
        let result = resultWithRaw([unknown])

        XCTAssertTrue(FraudSignalMapper.map(extractionResult: result).isEmpty)
    }

    func testEmptyWhenRawIsNil() {
        let result = resultWithRaw(nil)

        XCTAssertTrue(FraudSignalMapper.map(extractionResult: result).isEmpty)
    }

    func testEmptyWhenRawIsEmpty() {
        let result = resultWithRaw([])

        XCTAssertTrue(FraudSignalMapper.map(extractionResult: result).isEmpty)
    }

    func testDropsSignalMissingSeverity() {
        let missingSeverity: [Extraction] = [
            extraction(name: "signalCode", value: "QR_PRINTED_IBAN_MISMATCH"),
            extraction(name: "iban", value: "DE89370400440532013000")
        ]
        let result = resultWithRaw([missingSeverity])

        XCTAssertTrue(FraudSignalMapper.map(extractionResult: result).isEmpty)
    }

    func testDropsSignalWithUnknownSeverity() {
        let result = resultWithRaw([qrPrintedIbanMismatchGroup(severity: "MAYBE")])

        XCTAssertTrue(FraudSignalMapper.map(extractionResult: result).isEmpty)
    }

    func testDropsSignalWithEmptyIban() {
        let result = resultWithRaw([qrPrintedIbanMismatchGroup(iban: "   ")])

        XCTAssertTrue(FraudSignalMapper.map(extractionResult: result).isEmpty)
    }

    func testDropsIBANCountryMismatchMissingCreditorCountry() {
        let result = resultWithRaw([ibanCountryMismatchGroup(creditorCountry: nil)])

        XCTAssertTrue(FraudSignalMapper.map(extractionResult: result).isEmpty)
    }

    func testKeepsQRPrintedIBANMismatchWithoutCreditorCountry() {
        let result = resultWithRaw([qrPrintedIbanMismatchGroup()])

        let signals = FraudSignalMapper.map(extractionResult: result)
        XCTAssertEqual(signals.count, 1)
        XCTAssertNil(signals.first?.creditorCountry)
    }

    // MARK: - Dedup

    func testDedupesByCodeKeepingFirst() {
        let firstQR = qrPrintedIbanMismatchGroup(iban: "DE89370400440532013000")
        let secondQR = qrPrintedIbanMismatchGroup(iban: "DE11111111111111111111")
        let result = resultWithRaw([firstQR, secondQR])

        let signals = FraudSignalMapper.map(extractionResult: result)

        XCTAssertEqual(signals.count, 1)
        XCTAssertEqual(signals.first?.iban, "DE89370400440532013000")
    }
}
