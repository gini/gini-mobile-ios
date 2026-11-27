//
//  ChosenIBANExtractions.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import GiniBankAPILibrary

/**
 Writes the IBAN the user chose on the IBAN selection sheet into the
 `iban` extraction (creating the entry when the backend returned the
 warning from the `ibans` bucket without a top-level `iban`) and removes
 the `bic` entry. The backend's `bic` was derived from the backend IBAN
 (the QR code IBAN); the printed IBAN the user picked may belong to a
 different account, so dropping `bic` is safer than sending one that no
 longer matches. Banks derive BIC from IBAN themselves.

 Pure value transform, no instance state — mirrors `FraudSignalFeedbackScrubber`.
 Returns the input unchanged when there is nothing to change: no choice,
 or the chosen IBAN equals the existing one (whitespace- and case-insensitive).
 */
enum ChosenIBANExtractions {

    static let ibanKey = "iban"
    static let bicKey = "bic"

    static func apply(_ extractions: [String: Extraction],
                      chosenIBAN: String?) -> [String: Extraction] {
        guard let chosenIBAN,
              !chosenIBAN.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return extractions
        }
        if let current = extractions[ibanKey],
           normalize(current.value) == normalize(chosenIBAN) {
            return extractions
        }
        let chosen = Extraction(box: nil,
                                candidates: extractions[ibanKey]?.candidates,
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
