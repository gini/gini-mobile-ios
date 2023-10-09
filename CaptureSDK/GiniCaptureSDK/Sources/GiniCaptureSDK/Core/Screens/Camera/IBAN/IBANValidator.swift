//
//  IBANValidator.swift
//  GiniCaptureSDK
//
//  Copyright © 2023 Gini GmbH. All rights reserved.
//

import Foundation

final class IBANValidator {

    private var validationSet: CharacterSet {
        return CharacterSet(charactersIn: "01234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ").inverted
    }
    private let countryIbanDictionary: [String: Int] = IBANKnowledge().countryIbanDictionary

    func isValid(iban: String) -> Bool {
        let iban = iban.replacingOccurrences(of: " ", with: "")
        let ibanLength = iban.count
        guard let minValues = countryIbanDictionary.values.min(), ibanLength >= minValues else {
            return false
        }

        if iban.rangeOfCharacter(from: validationSet) != nil {
            return false
        }

        let countryCode = String(iban[..<iban.index(iban.startIndex, offsetBy: 2)])
        let countryDescriptor = countryIbanDictionary[countryCode]
        var countryIsValid = false
        if let countryDescriptor = countryDescriptor {
            countryIsValid = true
            guard countryDescriptor == ibanLength else {
                return false
            }
        }

        let normalizedIban = "\(String(iban[iban.index(iban.startIndex, offsetBy: 4)...]))" +
        "\(String(iban[..<iban.index(iban.startIndex, offsetBy: 4)]))"

        let result = validateMod97(iban: normalizedIban)
        if !countryIsValid && result == true {
            return false
        }

        return result
    }

    func checkSum(iban: String) -> UInt32 {
        var checkSum = UInt32(0)
        var letterNumberMapping: [Character: Int] {
            var dict = [Character: Int]()
            "ABCDEFGHIJKLMNOPQRSTUVWXYZ".forEach { dict[$0] = Int($0.unicodeScalarCodePoint() - 55) }
            return dict
        }

        for char in iban {
            let value = UInt32(letterNumberMapping[char] ?? Int(String(char)) ?? 0)
            if value < 10 {
                checkSum = (10 * checkSum) + value
            } else {
                checkSum = (100 * checkSum) + value
            }
            if checkSum >= UInt32(UINT32_MAX) / 100 {
                checkSum = checkSum % 97
            }
        }
        return checkSum % 97
    }

    func validateMod97(iban: String) -> Bool {
        return checkSum(iban: iban) == 1
    }
}

extension Character {
    func unicodeScalarCodePoint() -> UInt32 {
        let scalars = String(self).unicodeScalars
        return scalars[scalars.startIndex].value
    }
}
