//
//  FraudWarningIBANResolver.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import GiniBankAPILibrary
import GiniCaptureSDK

/**
 Resolves the QR + printed IBAN pair the fraud warning screen should display,
 or returns `nil` when the warning should be suppressed.

 Pure value transform, no instance state. The caller
 (`GiniBankNetworkingScreenApiCoordinator+FraudWarning.swift`) is responsible
 for the integrator-facing gate (`GiniBankConfiguration.fraudWarningEnabled`);
 the backend-pushed `ClientConfiguration.fraudSignalsEnabled` gate and the
 `FraudSignalMapper` call live in here so one function decides the entire
 "should we present + with which values" question.

 Suppression rules (any one returns `nil`):
 - `fraudSignalsEnabled == false` — backend has the feature off for this client.
 - `FraudSignalMapper.map(...)` returns no `.qrPrintedIbanMismatch` — nothing to
   warn about on the single-case layout this screen renders.
 - The printed-IBAN filter yields empty — the QR signal cannot be explained
   without a second IBAN to contrast against.
 */
internal enum FraudWarningIBANResolver {

    /**
     - Parameter result: The `AnalysisResult` whose `candidates` and `extractions`
       source the printed-IBAN candidate list.
     - Parameter extractionResult: The raw `ExtractionResult` from the same
       analysis, used by `FraudSignalMapper` to parse typed fraud signals.
     - Parameter fraudSignalsEnabled: Backend client-configuration flag. When
       `false`, returns `nil` immediately.
     - Returns: `(qrIBAN, printedIBAN)` when all suppression rules pass, else `nil`.
     */
    static func resolve(result: AnalysisResult,
                        extractionResult: ExtractionResult,
                        fraudSignalsEnabled: Bool) -> (qrIBAN: String, printedIBAN: String)? {
        guard fraudSignalsEnabled else { return nil }

        let signals = FraudSignalMapper.map(extractionResult: extractionResult,
                                            fraudSignalsEnabled: true)
        guard let qrSignal = signals.first(where: { $0.code == .qrPrintedIbanMismatch }) else {
            return nil
        }
        guard let printedIBAN = Self.firstPrintedIBAN(from: result, excluding: qrSignal.iban) else {
            return nil
        }
        return (qrIBAN: qrSignal.iban, printedIBAN: printedIBAN)
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

    private static func normalize(_ iban: String) -> String {
        iban.filter { !$0.isWhitespace }.uppercased()
    }
}
