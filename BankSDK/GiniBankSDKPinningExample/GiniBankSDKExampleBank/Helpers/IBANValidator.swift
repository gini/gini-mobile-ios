//
//  IBANValidator.swift
//  Bank
//
//  Created by Nadya Karaban on 04.05.21.
//

import Foundation
/**
  Helper class for IBAN validation.
 
 */
final class IBANValidator {
    private var countryIbanDictionary: [String: Int] {
        return [
            "AL": 28, "AD": 24, "AT": 20, "AZ": 28, "BH": 22, "BE": 16,
            "BA": 20, "BR": 29, "BG": 22, "CR": 21, "HR": 21, "CY": 28,
            "CZ": 24, "DK": 18, "DO": 28, "EE": 20, "FO": 18, "FI": 18,
            "FR": 27, "GE": 22, "DE": 22, "GI": 23, "GB": 22, "GR": 27,
            "GL": 18, "GT": 28, "HU": 28, "IS": 26, "IE": 22, "IL": 23,
            "IT": 27, "KZ": 20, "KW": 30, "LV": 21, "LB": 28, "LT": 20,
            "LU": 20, "MK": 19, "MT": 31, "MR": 27, "MU": 30, "MD": 24,
            "MC": 27, "ME": 22, "NL": 18, "NO": 15, "PK": 24, "PS": 29,
            "PL": 28, "PT": 25, "RO": 24, "SM": 27, "SA": 24, "RS": 22,
            "SK": 24, "SI": 19, "ES": 24, "SE": 24, "TN": 24, "TR": 26,
            "AE": 23, "VG": 24, "CH": 21
        ]
    }
    
    private var validationSet: CharacterSet {
        return CharacterSet(charactersIn: "01234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ").inverted
    }
    
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
