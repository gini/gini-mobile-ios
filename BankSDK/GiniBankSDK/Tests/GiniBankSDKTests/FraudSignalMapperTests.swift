//
//  FraudSignalMapperTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
@_spi(GiniCaptureInternal) @testable import GiniBankAPILibrary
@testable import GiniBankSDK

@Suite("FraudSignalMapper")
struct FraudSignalMapperTests {

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

    @Test("Both known signals map to typed values with the right code, severity, IBAN and creditor country")
    func mapsBothKnownSignals() throws {
        let result = resultWithRaw([qrPrintedIbanMismatchGroup(),
                                    ibanCountryMismatchGroup()])

        let signals = FraudSignalMapper.map(extractionResult: result, fraudSignalsEnabled: true)

        try #require(signals.count == 2)
        #expect(signals[0].code == .qrPrintedIbanMismatch)
        #expect(signals[0].severity == .check)
        #expect(signals[0].iban == "DE89370400440532013000")
        #expect(signals[0].creditorCountry == nil)

        #expect(signals[1].code == .ibanCountryMismatch)
        #expect(signals[1].severity == .stop)
        #expect(signals[1].iban == "GB29NWBK60161331926819")
        #expect(signals[1].creditorCountry == "DE")
    }

    // MARK: - Error paths

    @Test("Unknown signalCode is dropped; a known sibling still survives")
    func dropsUnknownSignalCode() {
        let unknown: [Extraction] = [
            extraction(name: "signalCode", value: "FOO_BAR"),
            extraction(name: "severity", value: "CHECK"),
            extraction(name: "iban", value: "DE89370400440532013000")
        ]
        let result = resultWithRaw([unknown, qrPrintedIbanMismatchGroup()])

        let signals = FraudSignalMapper.map(extractionResult: result, fraudSignalsEnabled: true)

        #expect(signals.count == 1)
        #expect(signals.first?.code == .qrPrintedIbanMismatch)
    }

    @Test("Every element having an unknown signalCode yields no typed signals")
    func emptyWhenAllSignalsUnknown() {
        let unknown: [Extraction] = [
            extraction(name: "signalCode", value: "FOO_BAR"),
            extraction(name: "severity", value: "CHECK"),
            extraction(name: "iban", value: "DE89370400440532013000")
        ]
        let result = resultWithRaw([unknown])

        #expect(FraudSignalMapper.map(extractionResult: result, fraudSignalsEnabled: true).isEmpty)
    }

    @Test("A nil fraudSignalsRaw yields an empty array, not a crash")
    func emptyWhenRawIsNil() {
        let result = resultWithRaw(nil)

        #expect(FraudSignalMapper.map(extractionResult: result, fraudSignalsEnabled: true).isEmpty)
    }

    @Test("An empty fraudSignalsRaw yields an empty array")
    func emptyWhenRawIsEmpty() {
        let result = resultWithRaw([])

        #expect(FraudSignalMapper.map(extractionResult: result, fraudSignalsEnabled: true).isEmpty)
    }

    @Test("Element missing severity is dropped")
    func dropsSignalMissingSeverity() {
        let missingSeverity: [Extraction] = [
            extraction(name: "signalCode", value: "QR_PRINTED_IBAN_MISMATCH"),
            extraction(name: "iban", value: "DE89370400440532013000")
        ]
        let result = resultWithRaw([missingSeverity])

        #expect(FraudSignalMapper.map(extractionResult: result, fraudSignalsEnabled: true).isEmpty)
    }

    @Test("Element with an unknown severity vocabulary is dropped")
    func dropsSignalWithUnknownSeverity() {
        let result = resultWithRaw([qrPrintedIbanMismatchGroup(severity: "MAYBE")])

        #expect(FraudSignalMapper.map(extractionResult: result, fraudSignalsEnabled: true).isEmpty)
    }

    @Test("Element with whitespace-only IBAN is dropped")
    func dropsSignalWithEmptyIban() {
        let result = resultWithRaw([qrPrintedIbanMismatchGroup(iban: "   ")])

        #expect(FraudSignalMapper.map(extractionResult: result, fraudSignalsEnabled: true).isEmpty)
    }

    @Test("IBAN_COUNTRY_MISMATCH without creditorCountry is dropped")
    func dropsIBANCountryMismatchMissingCreditorCountry() {
        let result = resultWithRaw([ibanCountryMismatchGroup(creditorCountry: nil)])

        #expect(FraudSignalMapper.map(extractionResult: result, fraudSignalsEnabled: true).isEmpty)
    }

    @Test("QR_PRINTED_IBAN_MISMATCH without creditorCountry is kept")
    func keepsQRPrintedIBANMismatchWithoutCreditorCountry() throws {
        let result = resultWithRaw([qrPrintedIbanMismatchGroup()])

        let signals = FraudSignalMapper.map(extractionResult: result, fraudSignalsEnabled: true)
        try #require(signals.count == 1)
        #expect(signals.first?.creditorCountry == nil)
    }

    // MARK: - Dedup

    @Test("Two groups mapping to the same code dedupe — the first element wins")
    func dedupesByCodeKeepingFirst() {
        let firstQR = qrPrintedIbanMismatchGroup(iban: "DE89370400440532013000")
        let secondQR = qrPrintedIbanMismatchGroup(iban: "DE11111111111111111111")
        let result = resultWithRaw([firstQR, secondQR])

        let signals = FraudSignalMapper.map(extractionResult: result, fraudSignalsEnabled: true)

        #expect(signals.count == 1)
        #expect(signals.first?.iban == "DE89370400440532013000")
    }

    // MARK: - Client-configuration flag

    @Test("Flag off suppresses even valid raw signals")
    func flagOffReturnsEmptyEvenWhenRawSignalsPresent() {
        let result = resultWithRaw([qrPrintedIbanMismatchGroup(),
                                    ibanCountryMismatchGroup()])

        #expect(FraudSignalMapper.map(extractionResult: result, fraudSignalsEnabled: false).isEmpty)
    }

    @Test("Flag off with nil raw yields an empty array, not a crash")
    func flagOffWithNilRawIsEmpty() {
        let result = resultWithRaw(nil)

        #expect(FraudSignalMapper.map(extractionResult: result, fraudSignalsEnabled: false).isEmpty)
    }
}
