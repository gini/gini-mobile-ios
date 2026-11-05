//
//  FraudSignalMapper.swift
//  GiniBank
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
@_spi(GiniCaptureInternal) import GiniBankAPILibrary

/**
 Reads `ExtractionResult.fraudSignalsRaw` and projects it to typed `FraudSignal`s.

 Pure value transform:
 - Returns `[]` when the `fraudSignalsEnabled` client-configuration flag is off.
 - Elements with an unknown `signalCode`, or a missing/empty `severity` or `iban`,
   are skipped so a new backend signal never breaks the flow.
 - `.ibanCountryMismatch` additionally requires `creditorCountry`.
 - Results are deduplicated by `code` — the first element for a given code wins.

 Never throws.
 */
internal enum FraudSignalMapper {

    /**
     Maps the raw fraud-signal groups on `extractionResult.fraudSignalsRaw` to
     typed `FraudSignal` values.

     - Parameter extractionResult: Source of `fraudSignalsRaw`. `nil` raw yields `[]`.
     - Parameter fraudSignalsEnabled: Client-configuration gate. When `false`, the
       mapper returns `[]` even if raw signals are present — matches the backend's
       per-client rollout semantics.
     - Returns: Zero or more typed signals, deduplicated by `code`.
     */
    static func map(extractionResult: ExtractionResult,
                    fraudSignalsEnabled: Bool) -> [FraudSignal] {
        guard fraudSignalsEnabled else { return [] }
        guard let rawGroups = extractionResult.fraudSignalsRaw else { return [] }

        var seenCodes = Set<FraudSignalCode>()
        var result: [FraudSignal] = []

        for group in rawGroups {
            guard let signal = fraudSignal(from: group) else { continue }
            guard !seenCodes.contains(signal.code) else { continue }
            seenCodes.insert(signal.code)
            result.append(signal)
        }

        return result
    }

    private static func fraudSignal(from group: [Extraction]) -> FraudSignal? {
        let byName = Dictionary(uniqueKeysWithValues: group.compactMap { extraction -> (String, Extraction)? in
            guard let name = extraction.name else { return nil }
            return (name, extraction)
        })

        guard let code = FraudSignalCode.from(apiValue: value(for: "signalCode", in: byName)),
              let severity = FraudSignalSeverity.from(apiValue: value(for: "severity", in: byName)),
              let iban = value(for: "iban", in: byName) else {
            return nil
        }

        let creditorCountry = value(for: "creditorCountry", in: byName)
        if code == .ibanCountryMismatch, creditorCountry == nil {
            return nil
        }

        return FraudSignal(code: code,
                           severity: severity,
                           iban: iban,
                           creditorCountry: creditorCountry)
    }

    private static func value(for name: String, in byName: [String: Extraction]) -> String? {
        let trimmed = byName[name]?.value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let trimmed, !trimmed.isEmpty else { return nil }
        return trimmed
    }
}
