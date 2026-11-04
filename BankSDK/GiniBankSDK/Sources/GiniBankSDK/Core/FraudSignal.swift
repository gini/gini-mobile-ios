//
//  FraudSignal.swift
//  GiniBank
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

/**
 One fraud signal read from the `fraudSignals` compound extraction.

 The typed, SDK-internal representation of a single group returned by the backend
 under `compoundExtractions.fraudSignals`. `creditorCountry` is always set for
 `.ibanCountryMismatch` and optional for the other codes.
 */
internal struct FraudSignal: Equatable {
    let code: FraudSignalCode
    let severity: FraudSignalSeverity
    let iban: String
    let creditorCountry: String?

    init(code: FraudSignalCode,
         severity: FraudSignalSeverity,
         iban: String,
         creditorCountry: String?) {
        self.code = code
        self.severity = severity
        self.iban = iban
        self.creditorCountry = creditorCountry
    }
}
