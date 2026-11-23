//
//  FraudWarningIBANResolverTests.swift
//  GiniBankSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit
import Testing
@testable import GiniBankAPILibrary
import GiniCaptureSDK
@testable import GiniBankSDK

/**
 Covers `FraudWarningIBANResolver.resolve(result:extractionResult:fraudSignalsEnabled:)`
 — the suppression rules (R2/R3/R4) and the three-variant branching added in
 PP-4090.
 */
@Suite("FraudWarningIBANResolver")
struct FraudWarningIBANResolverTests {

    // MARK: - R2 — backend-flag gate

    @Test("returns nil when fraudSignalsEnabled is false")
    func returnsNilWhenFraudSignalsEnabledIsFalse() {
        let extractionResult = Self.extractionResult(withFraudSignals: [
            Self.signalGroup(code: "QR_PRINTED_IBAN_MISMATCH", iban: "PL12 1000 0111 0100 1000")
        ])
        let result = Self.analysisResult(candidates: ["DE89 3704 0044 0532 0130 00"])

        let resolved = FraudWarningIBANResolver.resolve(result: result,
                                                         extractionResult: extractionResult,
                                                         fraudSignalsEnabled: false)

        #expect(resolved == nil)
    }

    // MARK: - R3 — no triggering signal

    @Test("returns nil when the mapper produces no signals at all")
    func returnsNilWhenNoFraudSignals() {
        let extractionResult = Self.extractionResult(withFraudSignals: [])
        let result = Self.analysisResult(candidates: ["DE89 3704 0044 0532 0130 00"])

        let resolved = FraudWarningIBANResolver.resolve(result: result,
                                                         extractionResult: extractionResult,
                                                         fraudSignalsEnabled: true)

        #expect(resolved == nil)
    }

    // MARK: - R4 — QR signal unexplainable (no printed candidate survives)

    @Test("returns nil when QR signal present but the printed-IBAN filter empties the candidate list")
    func returnsNilWhenPrintedCandidateFilterEmpty() {
        let qrIban = "PL12 1000 0111 0100 1000"
        let extractionResult = Self.extractionResult(withFraudSignals: [
            Self.signalGroup(code: "QR_PRINTED_IBAN_MISMATCH", iban: qrIban)
        ])
        /// Only candidate equals the QR IBAN → filter drops it, nothing left to contrast against.
        let result = Self.analysisResult(candidates: [qrIban])

        let resolved = FraudWarningIBANResolver.resolve(result: result,
                                                         extractionResult: extractionResult,
                                                         fraudSignalsEnabled: true)

        #expect(resolved == nil)
    }

    // MARK: - QR vs Printed happy path

    @Test("returns .qrPrinted when only the QR signal fires and a printed IBAN survives")
    func returnsQrPrintedWhenAllConditionsMet() {
        let qrIban = "PL12 1000 0111 0100 1000"
        let printedIban = "DE89 3704 0044 0532 0130 00"
        let extractionResult = Self.extractionResult(withFraudSignals: [
            Self.signalGroup(code: "QR_PRINTED_IBAN_MISMATCH", iban: qrIban)
        ])
        let result = Self.analysisResult(candidates: [qrIban, printedIban])

        let resolved = FraudWarningIBANResolver.resolve(result: result,
                                                         extractionResult: extractionResult,
                                                         fraudSignalsEnabled: true)

        #expect(resolved == .qrPrinted(qrIBAN: qrIban, printedIBAN: printedIban))
    }

    // MARK: - Country-only variant

    @Test("returns .country when only the country signal fires with sender + country")
    func returnsCountryWhenOnlyCountrySignalWithSender() {
        let countryIban = "PL12 1000 0111 0100 1000"
        let extractionResult = Self.extractionResult(withFraudSignals: [
            Self.signalGroup(code: "IBAN_COUNTRY_MISMATCH",
                             iban: countryIban,
                             creditorCountry: "DE")
        ])
        let result = Self.analysisResult(candidates: ["DE89 3704 0044 0532 0130 00"],
                                          paymentRecipient: "Elektro Brandt GmbH")

        let resolved = FraudWarningIBANResolver.resolve(result: result,
                                                         extractionResult: extractionResult,
                                                         fraudSignalsEnabled: true)

        #expect(resolved == .country(senderName: "Elektro Brandt GmbH",
                                     senderCountry: "DE",
                                     iban: countryIban))
    }

    @Test("returns .country with senderName nil when paymentRecipient is missing")
    func returnsCountryWithNilSenderWhenRecipientMissing() {
        let countryIban = "PL12 1000 0111 0100 1000"
        let extractionResult = Self.extractionResult(withFraudSignals: [
            Self.signalGroup(code: "IBAN_COUNTRY_MISMATCH",
                             iban: countryIban,
                             creditorCountry: "DE")
        ])
        let result = Self.analysisResult(candidates: ["DE89 3704 0044 0532 0130 00"],
                                          paymentRecipient: nil)

        let resolved = FraudWarningIBANResolver.resolve(result: result,
                                                         extractionResult: extractionResult,
                                                         fraudSignalsEnabled: true)

        #expect(resolved == .country(senderName: nil, senderCountry: "DE", iban: countryIban))
    }

    @Test("returns .country with senderName nil when paymentRecipient is whitespace-only")
    func returnsCountryWithNilSenderWhenRecipientWhitespaceOnly() {
        let countryIban = "PL12 1000 0111 0100 1000"
        let extractionResult = Self.extractionResult(withFraudSignals: [
            Self.signalGroup(code: "IBAN_COUNTRY_MISMATCH",
                             iban: countryIban,
                             creditorCountry: "DE")
        ])
        let result = Self.analysisResult(candidates: ["DE89 3704 0044 0532 0130 00"],
                                          paymentRecipient: "   \n")

        let resolved = FraudWarningIBANResolver.resolve(result: result,
                                                         extractionResult: extractionResult,
                                                         fraudSignalsEnabled: true)

        #expect(resolved == .country(senderName: nil, senderCountry: "DE", iban: countryIban))
    }

    @Test("returns nil when only country signal fires but creditorCountry is missing")
    func returnsNilWhenCountrySignalHasNoCreditorCountry() {
        /// The mapper drops `.ibanCountryMismatch` entries without `creditorCountry`, so
        /// upstream we see no signal at all → nothing to show.
        let extractionResult = Self.extractionResult(withFraudSignals: [
            Self.signalGroup(code: "IBAN_COUNTRY_MISMATCH",
                             iban: "PL12 1000 0111 0100 1000",
                             creditorCountry: nil)
        ])
        let result = Self.analysisResult(candidates: ["DE89 3704 0044 0532 0130 00"])

        let resolved = FraudWarningIBANResolver.resolve(result: result,
                                                         extractionResult: extractionResult,
                                                         fraudSignalsEnabled: true)

        #expect(resolved == nil)
    }

    // MARK: - Combined variant

    @Test("returns .combined when both signals fire with a printed survivor")
    func returnsCombinedWhenBothSignalsFire() {
        let qrIban = "PL12 1000 0111 0100 1000"
        let printedIban = "DE89 3704 0044 0532 0130 00"
        let extractionResult = Self.extractionResult(withFraudSignals: [
            Self.signalGroup(code: "QR_PRINTED_IBAN_MISMATCH", iban: qrIban),
            Self.signalGroup(code: "IBAN_COUNTRY_MISMATCH", iban: qrIban, creditorCountry: "DE")
        ])
        let result = Self.analysisResult(candidates: [qrIban, printedIban],
                                          paymentRecipient: "Elektro Brandt GmbH")

        let resolved = FraudWarningIBANResolver.resolve(result: result,
                                                         extractionResult: extractionResult,
                                                         fraudSignalsEnabled: true)

        #expect(resolved == .combined(senderName: "Elektro Brandt GmbH",
                                      senderCountry: "DE",
                                      qrIBAN: qrIban,
                                      printedIBAN: printedIban))
    }

    @Test("degrades to .qrPrinted when both signals fire but creditorCountry is missing")
    func degradesToQrPrintedWhenCountryCreditorMissing() {
        let qrIban = "PL12 1000 0111 0100 1000"
        let printedIban = "DE89 3704 0044 0532 0130 00"
        let extractionResult = Self.extractionResult(withFraudSignals: [
            Self.signalGroup(code: "QR_PRINTED_IBAN_MISMATCH", iban: qrIban),
            Self.signalGroup(code: "IBAN_COUNTRY_MISMATCH", iban: qrIban, creditorCountry: nil)
        ])
        let result = Self.analysisResult(candidates: [qrIban, printedIban],
                                          paymentRecipient: "Elektro Brandt GmbH")

        let resolved = FraudWarningIBANResolver.resolve(result: result,
                                                         extractionResult: extractionResult,
                                                         fraudSignalsEnabled: true)

        #expect(resolved == .qrPrinted(qrIBAN: qrIban, printedIBAN: printedIban))
    }

    // MARK: - Printed-IBAN filter details

    @Test("excludes the QR IBAN even when whitespace and casing differ")
    func excludesQrIbanAcrossNormalization() {
        /// QR signal carries the IBAN in spaced form; a candidate shows the same IBAN in
        /// compact lowercase — both normalize equal, so the candidate must be dropped.
        let extractionResult = Self.extractionResult(withFraudSignals: [
            Self.signalGroup(code: "QR_PRINTED_IBAN_MISMATCH",
                             iban: "PL12 1000 0111 0100 1000")
        ])
        let result = Self.analysisResult(candidates: [
            "pl121000011101001000",
            "DE89 3704 0044 0532 0130 00"
        ])

        let resolved = FraudWarningIBANResolver.resolve(result: result,
                                                         extractionResult: extractionResult,
                                                         fraudSignalsEnabled: true)

        #expect(resolved == .qrPrinted(qrIBAN: "PL12 1000 0111 0100 1000",
                                       printedIBAN: "DE89 3704 0044 0532 0130 00"))
    }

    @Test("dedupes by normalized form and returns the first-seen survivor")
    func dedupesByNormalizedFormPreservingFirstSeen() {
        let extractionResult = Self.extractionResult(withFraudSignals: [
            Self.signalGroup(code: "QR_PRINTED_IBAN_MISMATCH",
                             iban: "PL12 1000 0111 0100 1000")
        ])
        let result = Self.analysisResult(candidates: [
            "DE89 3704 0044 0532 0130 00",         // first-seen wins
            "de89 3704 0044 0532 0130 00",         // dupe (case) — dropped
            "DE8937040044053201 3000"              // dupe (whitespace) — dropped
        ])

        let resolved = FraudWarningIBANResolver.resolve(result: result,
                                                         extractionResult: extractionResult,
                                                         fraudSignalsEnabled: true)

        #expect(resolved == .qrPrinted(qrIBAN: "PL12 1000 0111 0100 1000",
                                       printedIBAN: "DE89 3704 0044 0532 0130 00"))
    }

    @Test("skips empty and whitespace-only candidate values")
    func skipsEmptyAndWhitespaceOnlyCandidateValues() {
        let extractionResult = Self.extractionResult(withFraudSignals: [
            Self.signalGroup(code: "QR_PRINTED_IBAN_MISMATCH",
                             iban: "PL12 1000 0111 0100 1000")
        ])
        let result = Self.analysisResult(candidates: [
            "",                                      // empty → skip
            "   ",                                   // whitespace-only → skip
            "DE89 3704 0044 0532 0130 00"
        ])

        let resolved = FraudWarningIBANResolver.resolve(result: result,
                                                         extractionResult: extractionResult,
                                                         fraudSignalsEnabled: true)

        #expect(resolved == .qrPrinted(qrIBAN: "PL12 1000 0111 0100 1000",
                                       printedIBAN: "DE89 3704 0044 0532 0130 00"))
    }

    @Test("falls back to the \"ibans\" candidate-dict key when extractions[iban].candidates is nil")
    func fallsBackToIbansKeyWhenExtractionLacksCandidatesPointer() {
        let extractionResult = Self.extractionResult(withFraudSignals: [
            Self.signalGroup(code: "QR_PRINTED_IBAN_MISMATCH",
                             iban: "PL12 1000 0111 0100 1000")
        ])
        /// IBAN extraction has `candidates: nil` (no explicit key), but the top-level
        /// candidate dict still has an "ibans" bucket — resolver must find it via the
        /// fallback key.
        let result = Self.analysisResult(candidateKey: nil,
                                          candidates: ["DE89 3704 0044 0532 0130 00"])

        let resolved = FraudWarningIBANResolver.resolve(result: result,
                                                         extractionResult: extractionResult,
                                                         fraudSignalsEnabled: true)

        #expect(resolved == .qrPrinted(qrIBAN: "PL12 1000 0111 0100 1000",
                                       printedIBAN: "DE89 3704 0044 0532 0130 00"))
    }

    // MARK: - Fixture helpers

    private static func signalGroup(code: String,
                                    iban: String,
                                    creditorCountry: String? = nil) -> [Extraction] {
        var group = [
            Extraction(box: nil, candidates: nil, entity: "text",
                       value: code, name: "signalCode"),
            Extraction(box: nil, candidates: nil, entity: "text",
                       value: "CHECK", name: "severity"),
            Extraction(box: nil, candidates: nil, entity: "iban",
                       value: iban, name: "iban")
        ]
        if let creditorCountry {
            group.append(Extraction(box: nil, candidates: nil, entity: "text",
                                     value: creditorCountry, name: "creditorCountry"))
        }
        return group
    }

    private static func extractionResult(withFraudSignals signals: [[Extraction]]) -> ExtractionResult {
        let result = ExtractionResult(extractions: [], candidates: [:])
        result.fraudSignals = signals.isEmpty ? nil : signals
        return result
    }

    /**
     Builds an `AnalysisResult` with a single `"iban"` extraction whose
     `.candidates` key routes to a top-level `"ibans"` bucket containing the
     given string values. Optionally adds a `paymentRecipient` extraction.
     */
    private static func analysisResult(candidateKey: String? = "ibans",
                                        candidates: [String],
                                        paymentRecipient: String? = nil) -> AnalysisResult {
        let ibanExtraction = Extraction(box: nil,
                                         candidates: candidateKey,
                                         entity: "iban",
                                         value: candidates.first ?? "",
                                         name: "iban")
        var extractions: [String: Extraction] = ["iban": ibanExtraction]
        if let paymentRecipient {
            extractions["paymentRecipient"] = Extraction(box: nil,
                                                          candidates: nil,
                                                          entity: "text",
                                                          value: paymentRecipient,
                                                          name: "paymentRecipient")
        }
        let candidateObjects = candidates.map {
            Extraction.Candidate(box: nil, entity: "iban", value: $0)
        }
        return AnalysisResult(extractions: extractions,
                               images: [],
                               candidates: ["ibans": candidateObjects])
    }
}
