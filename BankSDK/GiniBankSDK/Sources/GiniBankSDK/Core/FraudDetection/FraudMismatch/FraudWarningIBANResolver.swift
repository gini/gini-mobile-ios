//
//  FraudWarningIBANResolver.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import GiniBankAPILibrary
import GiniCaptureSDK

/**
 Resolves the content the fraud warning screen should display, or returns
 `nil` when the warning should be suppressed.

 Pure value transform, no instance state. The caller
 (`GiniBankNetworkingScreenApiCoordinator+FraudWarning.swift`) is responsible
 for the integrator-facing gate (`GiniBankConfiguration.fraudWarningEnabled`);
 the backend-pushed `ClientConfiguration.fraudSignalsEnabled` gate, the
 `FraudSignalMapper` call, and the three-variant branching live in here so
 one function decides the entire "should we present + with which content"
 question.

 Suppression rules (any one returns `nil`):
 - `fraudSignalsEnabled == false` — backend has the feature off for this client.
 - `FraudSignalMapper.map(...)` returns neither `.qrPrintedIbanMismatch` nor
   `.ibanCountryMismatch` — nothing to warn about.
 - A `.qrPrintedIbanMismatch` signal with no printed-IBAN candidate to
   contrast against is dropped; a lone country signal is still enough to
   render the country-only variant.
 */
enum FraudWarningIBANResolver {

    /**
     Resolves the content for the fraud warning screen, or returns `nil`
     when the warning must be suppressed.

     - Parameters:
       - result: `AnalysisResult` whose `candidates` and `extractions`
         source the printed-IBAN list and the sender name.
       - extractionResult: raw `ExtractionResult` from the same analysis,
         consumed by `FraudSignalMapper`.
       - fraudSignalsEnabled: backend client-configuration flag. `false`
         short-circuits to `nil`.
     - Returns: `FraudWarningContent` when at least one of the two signals
       resolves to a renderable layout, else `nil`.
     */
    static func resolve(result: AnalysisResult,
                        extractionResult: ExtractionResult,
                        fraudSignalsEnabled: Bool) -> FraudWarningContent? {
        guard fraudSignalsEnabled else { return nil }

        let signals = FraudSignalMapper.map(extractionResult: extractionResult,
                                            fraudSignalsEnabled: fraudSignalsEnabled)
        let qrSignal = signals.first(where: { $0.code == .qrPrintedIbanMismatch })
        let countrySignal = signals.first(where: { $0.code == .ibanCountryMismatch })
        let senderCountry = countrySignal?.creditorCountry?.uppercased()
        let senderName = Self.paymentRecipient(from: result)

        /// QR signal only produces a renderable row when there is a second
        /// printed IBAN to contrast against.
        let printedIBAN = qrSignal.flatMap { Self.firstPrintedIBAN(from: result,
                                                                   excluding: $0.iban) }

        switch (qrSignal?.iban, printedIBAN, countrySignal?.iban, senderCountry) {
        case let (qrIBAN?, printedIBAN?, _, senderCountry?):
            return .combined(senderName: senderName,
                             senderCountry: senderCountry,
                             qrIBAN: qrIBAN,
                             printedIBAN: printedIBAN)
        case let (qrIBAN?, printedIBAN?, _, _):
            return .qrPrinted(qrIBAN: qrIBAN, printedIBAN: printedIBAN)
        case let (_, _, countryIBAN?, senderCountry?):
            return .country(senderName: senderName,
                            senderCountry: senderCountry,
                            iban: countryIBAN)
        default:
            return nil
        }
    }

    // MARK: - Private helpers
    //
    // On iOS, `Extraction.candidates` is a `String?` KEY (e.g. `"ibans"`) into
    // the top-level `AnalysisResult.candidates: [String: [Extraction.Candidate]]`.
    // Two-step indirection.

    /**
     Walks the IBAN candidate list, trims empties, dedupes by normalized form,
     and excludes the QR IBAN after normalization. Returns the first survivor,
     or `nil` if none.
     */
    private static func firstPrintedIBAN(from result: AnalysisResult,
                                         excluding qrIBAN: String) -> String? {
        let key = result.extractions["iban"]?.candidates ?? "ibans"
        let raw = result.candidates[key] ?? []
        let qrKey = Self.normalize(qrIBAN)
        var seen = Set<String>()
        for candidate in raw {
            let trimmed = candidate.value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }
            let normalized = Self.normalize(trimmed)
            guard normalized != qrKey else { continue }
            guard seen.insert(normalized).inserted else { continue }
            return trimmed
        }
        return nil
    }

    /**
     Trimmed, non-empty `paymentRecipient` extraction value. Returns `nil`
     when the extraction is missing or blank so the view can render just
     the country on the sender line.
     */
    private static func paymentRecipient(from result: AnalysisResult) -> String? {
        guard let value = result.extractions["paymentRecipient"]?.value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func normalize(_ iban: String) -> String {
        iban.filter { !$0.isWhitespace }.uppercased()
    }
}
