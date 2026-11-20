//
//  ChosenIBANExtractions.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import GiniBankAPILibrary

/**
 Rewrites the `iban` extraction with the IBAN the user chose on the
 IBAN selection sheet and removes the `bic` entry when the chosen IBAN
 differs from the backend's. The backend's `bic` was derived from the
 backend IBAN (the QR code IBAN); the printed IBAN the user picked may
 belong to a different account, so dropping `bic` is safer than sending
 one that no longer matches. Banks derive BIC from IBAN themselves.

 Pure value transform, no instance state — mirrors `FraudSignalFeedbackScrubber`.
 Returns the input unchanged when there is nothing to change: no choice,
 the chosen IBAN equals the backend's (whitespace- and case-insensitive),
 or no `iban` entry exists to replace.
 */
internal enum ChosenIBANExtractions {

    internal static let ibanKey = "iban"
    internal static let bicKey = "bic"

    internal static func apply(_ extractions: [String: Extraction],
                               chosenIBAN: String?) -> [String: Extraction] {
        guard let chosenIBAN,
              !chosenIBAN.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let current = extractions[ibanKey] else {
            return extractions
        }
        if normalize(current.value) == normalize(chosenIBAN) {
            return extractions
        }
        let chosen = Extraction(box: nil,
                                candidates: current.candidates,
                                entity: ibanKey,
                                value: chosenIBAN,
                                name: ibanKey)
        var result = extractions
        result[ibanKey] = chosen
        result.removeValue(forKey: bicKey)
        return result
    }

    /** Strips whitespace and uppercases so "de89 3704..." and "DE89 3704..." compare equal. */
    private static func normalize(_ iban: String) -> String {
        iban.components(separatedBy: .whitespacesAndNewlines).joined().uppercased()
    }
}
