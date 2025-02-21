//
//  IBANRecogniser.swift
//
//  Copyright © 2023 Gini GmbH. All rights reserved.
//

import Foundation

private func extractIBANMatches(from string: String) -> [NSTextCheckingResult] {
    let stringRange = NSRange(location: 0, length: string.count)
    let allIBANs = IBANKnowledge().universalIBANRegex.matches(in: string, options: [], range: stringRange)
    let iBANsInBlocks = IBANKnowledge().ibanInBlocksRegex.matches(in: string, options: [], range: stringRange)
    return allIBANs + iBANsInBlocks
}

func extractIBANS(string: String) -> [String] {
    var results = [String]()
    var prefferedIBANs = [String]()
    var matches = extractIBANMatches(from: string)

    // try to fix invalid strings
    if matches.isEmpty, string.count > 2 {
        var number = String(string.dropFirst(2))

        number = number.replacingOccurrences(of: "s", with: "5")
        number = number.replacingOccurrences(of: "S", with: "5")
        number = number.replacingOccurrences(of: "I", with: "1")
        number = number.replacingOccurrences(of: "i", with: "1")
        number = number.replacingOccurrences(of: "l", with: "1")
        number = number.replacingOccurrences(of: "T", with: "1")
        number = number.replacingOccurrences(of: "o", with: "0")
        number = number.replacingOccurrences(of: "O", with: "0")
        number = number.replacingOccurrences(of: "Q", with: "0")
        number = number.trimmingCharacters(in: .whitespaces)
        number = number.replacingOccurrences(of: ",", with: "")
        number = number.replacingOccurrences(of: ".", with: "")
        matches = extractIBANMatches(from: String(string.prefix(2)) + number)
    }

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
