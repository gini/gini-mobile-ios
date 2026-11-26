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
 — the suppression rules and the three-variant branching.
 */
@Suite("FraudWarningIBANResolver")
struct FraudWarningIBANResolverTests {

    // MARK: - Backend-flag gate

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

    // MARK: - No triggering signal

    @Test("returns nil when the mapper produces no signals at all")
    func returnsNilWhenNoFraudSignals() {
        let extractionResult = Self.extractionResult(withFraudSignals: [])
        let result = Self.analysisResult(candidates: ["DE89 3704 0044 0532 0130 00"])

        let resolved = FraudWarningIBANResolver.resolve(result: result,
                                                         extractionResult: extractionResult,
                                                         fraudSignalsEnabled: true)

        #expect(resolved == nil)
    }

    // MARK: - QR signal unexplainable (no printed candidate survives)

    @Test("returns nil when QR signal present but the printed-IBAN filter empties the candidate list")
    func returnsNilWhenPrintedCandidateFilterEmpty() {
        let qrIban = "PL12 1000 0111 0100 1000"
        let extractionResult = Self.extractionResult(withFraudSignals: [
            Self.signalGroup(code: "QR_PRINTED_IBAN_MISMATCH", iban: qrIban)
        ])
        // Only candidate equals the QR IBAN → filter drops it, nothing left to contrast against.
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
        // QR signal carries the IBAN in spaced form; a candidate shows the same IBAN in
        // compact lowercase — both normalize equal, so the candidate must be dropped.
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
        // IBAN extraction has `candidates: nil` (no explicit key), but the top-level
        // candidate dict still has an "ibans" bucket — resolver must find it via the
        // fallback key.
        let result = Self.analysisResult(candidateKey: nil,
                                          candidates: ["DE89 3704 0044 0532 0130 00"])

        let resolved = FraudWarningIBANResolver.resolve(result: result,
                                                         extractionResult: extractionResult,
                                                         fraudSignalsEnabled: true)

        #expect(resolved == .qrPrinted(qrIBAN: "PL12 1000 0111 0100 1000",
                                       printedIBAN: "DE89 3704 0044 0532 0130 00"))
    }

    // MARK: - FraudWarningContent.shouldPresentIBANPicker

    @Test("shouldPresentIBANPicker is true for qrPrinted")
    func shouldPresentIBANPickerTrueForQrPrinted() {
        let content = FraudWarningContent.qrPrinted(qrIBAN: "PL12", printedIBAN: "DE89")

        #expect(content.shouldPresentIBANPicker == true)
    }

    @Test("shouldPresentIBANPicker is true for combined")
    func shouldPresentIBANPickerTrueForCombined() {
        let content = FraudWarningContent.combined(senderName: "Elektro Brandt GmbH",
                                                   senderCountry: "DE",
                                                   qrIBAN: "PL12",
                                                   printedIBAN: "DE89")

        #expect(content.shouldPresentIBANPicker == true)
    }

    @Test("shouldPresentIBANPicker is false for country")
    func shouldPresentIBANPickerFalseForCountry() {
        let content = FraudWarningContent.country(senderName: nil,
                                                  senderCountry: "DE",
                                                  iban: "PL12")

        #expect(content.shouldPresentIBANPicker == false)
    }

    // MARK: - FraudWarningContent.pickerIBANs

    @Test("pickerIBANs exposes both IBANs for qrPrinted")
    func pickerIBANsExposedForQrPrinted() {
        let content = FraudWarningContent.qrPrinted(qrIBAN: "PL12", printedIBAN: "DE89")

        #expect(content.pickerIBANs?.qrIBAN == "PL12")
        #expect(content.pickerIBANs?.printedIBAN == "DE89")
    }

    @Test("pickerIBANs exposes both IBANs for combined")
    func pickerIBANsExposedForCombined() {
        let content = FraudWarningContent.combined(senderName: nil,
                                                   senderCountry: "DE",
                                                   qrIBAN: "PL12",
                                                   printedIBAN: "DE89")

        #expect(content.pickerIBANs?.qrIBAN == "PL12")
        #expect(content.pickerIBANs?.printedIBAN == "DE89")
    }

    @Test("pickerIBANs is nil for country")
    func pickerIBANsNilForCountry() {
        let content = FraudWarningContent.country(senderName: nil,
                                                  senderCountry: "DE",
                                                  iban: "PL12")

        #expect(content.pickerIBANs == nil)
    }

    // MARK: - FraudWarningContent.hintCountryCode

    @Test("hintCountryCode returns the prefix when it differs from the sender country")
    func hintCountryCodeReturnsPrefixWhenDifferent() {
        #expect(FraudWarningContent.hintCountryCode(for: "PL12 1000 0111 0100 1000",
                                                    senderCountry: "DE") == "PL")
    }

    @Test("hintCountryCode returns nil when the prefix matches the sender country")
    func hintCountryCodeNilWhenMatchesSender() {
        #expect(FraudWarningContent.hintCountryCode(for: "de89 3704 0044 0532 0130 00",
                                                    senderCountry: "DE") == nil)
    }

    @Test("hintCountryCode returns nil for IBANs shorter than two characters")
    func hintCountryCodeNilForShortIBAN() {
        #expect(FraudWarningContent.hintCountryCode(for: "D", senderCountry: "DE") == nil)
    }

    @Test("hintCountryCode returns nil when the prefix is not two letters")
    func hintCountryCodeNilForNonLetterPrefix() {
        #expect(FraudWarningContent.hintCountryCode(for: "12 3704 0044",
                                                    senderCountry: "DE") == nil)
    }

    // MARK: - FraudCountryName.displayCountry

    @Test("display returns the localized country name for a known code")
    func displayReturnsLocalizedNameForKnownCode() {
        let name = FraudCountryName.displayCountry(code: "DE", in: Locale(identifier: "en"))

        #expect(name == "Germany")
    }

    @Test("display uppercases a lowercase input before resolving the region")
    func displayUppercasesLowercaseInput() {
        let name = FraudCountryName.displayCountry(code: "de", in: Locale(identifier: "en"))

        #expect(name == "Germany")
    }

    @Test("display falls back to the raw code when the locale returns an empty name")
    func displayFallsBackWhenLocaleReturnsEmpty() {
        let name = FraudCountryName.displayCountry(code: "", in: Locale(identifier: "en"))

        #expect(name == "")
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
