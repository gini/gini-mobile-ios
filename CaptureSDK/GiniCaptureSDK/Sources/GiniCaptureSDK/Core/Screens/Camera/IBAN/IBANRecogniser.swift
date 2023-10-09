//
//  IBANRecogniser.swift
//
//  Copyright © 2023 Gini GmbH. All rights reserved.
//

import Foundation

enum IBANPattern: String, CaseIterable {
    case germany        = "DE[0-9]{2}[0-9]{18}"
    case denmark        = "DK[0-9]{2}[0-9]{14}"
    case poland         = "PL[0-9]{2}[0-9]{24}"
    case czechia        = "CZ[0-9]{2}[0-9]{20}"
    case austria        = "AT[0-9]{2}[0-9]{16}"
    case switzerland    = "CH[0-9]{2}[0-9]{5}[0-9a-zA-Z]{12}"
    case france         = "FR[0-9]{2}[0-9]{10}[0-9a-zA-Z]{11}[0-9]{2}"
    case luxembourg     = "LU[0-9]{2}[0-9]{3}[0-9a-zA-Z]{13}"
    case belgium        = "BE[0-9]{2}[0-9]{12}"
    case netherlands    = "NL[0-9]{2}[A-Z]{4}[0-9]{10}"
    case unitedKingdom  = "GB[0-9]{2}[A-Z]{4}[0-9]{14}"
    case italy          = "IT[0-9]{2}[A-Z]{1}[0-9]{10}[0-9a-zA-Z]{12}"
    case spain          = "ES[0-9]{2}[0-9]{20}"
}

func extractIBANS(string: String) -> [String] {

    let noWhitespace = string.filter { !$0.isWhitespace }

    var results = [String]()

    for pattern in IBANPattern.allCases {

        let transformed = substitutingForAllowedCharacters(string: noWhitespace, pattern: pattern)

        let strings: [String] = transformed.eagerRanges(of: pattern.rawValue,
                                                        options: .regularExpression).map { String(transformed[$0]) }

        results += strings.filter { string in

            if !IBANValidator().isValid(iban: string) {
                print("👹 invalid checksum: \(string)")
                return false
            }
            return true
        }
    }

    return results
}

private func substitutingForAllowedCharacters(string: String, pattern: IBANPattern) -> String {

    var conversionTable: [Character : Character] = ["(": "0"]
    if pattern == .germany {
        conversionTable["p"] = "D"
    }

    var result = ""

    for character in string {
        result.append(conversionTable[character] ?? character)
    }

    return result
}

extension String {

    func eagerRanges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex, let range = self[startIndex...].range(of: string, options: options) {
            result.append(range)
            startIndex = index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
