//
//  IBANRecogniser.swift
//
//  Copyright © 2023 Gini GmbH. All rights reserved.
//

import Foundation
import GiniUtilites

func extractIBANS(string: String) -> [String] {
    var results = [String]()
    var prefferedIBANs = [String]()
    let stringRange = NSRange(location: 0, length: string.count)
    let allIBANs = IBANKnowledge().universalIBANRegex.matches(in: string, options: [], range: stringRange)
    let iBANsInBlocks = IBANKnowledge().ibanInBlocksRegex.matches(in: string, options: [], range: stringRange)
    let matches = allIBANs + iBANsInBlocks

    for match in matches {
        if let range = Range(match.range, in: string) {
            let iban = String(string[range]).filter { !$0.isWhitespace }

            if IBANValidator().isValid(iban: iban) {
                let ibanRange = NSRange(location: 0, length: iban.count)
                let germanIBANs = IBANKnowledge().germanIBANRegex.matches(in: iban, options: [], range: ibanRange)

                if !germanIBANs.isEmpty && !prefferedIBANs.contains(iban) {
                    prefferedIBANs.append(iban)
                } else {
                    if !results.contains(iban) {
                        results.append(iban)
                    }
                }
            }
        }
    }

    return prefferedIBANs.isEmpty ? results : prefferedIBANs
}
