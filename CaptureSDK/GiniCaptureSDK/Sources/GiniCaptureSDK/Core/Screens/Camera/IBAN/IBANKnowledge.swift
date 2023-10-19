//
//  IBANKnowledge.swift
//  
//
//  Copyright © 2023 Gini GmbH. All rights reserved.
//

import Foundation

final class IBANKnowledge {
    let countryIbanDictionary: [String: Int] =
         [
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

    private var countryCodes: [String] {
        return countryIbanDictionary.keys.map { "\($0.prefix(2))" }
    }

    var countryCodesRegex: NSRegularExpression {
        return NSRegularExpression("(?:\(countryCodes.joined(separator: "|")))")
    }

    var universalIBANRegex: NSRegularExpression {
        let pattern = countryCodesRegex.pattern
        return NSRegularExpression("\\b(\(pattern)) ?(\\d?\\d)?([-\\p{Alnum}]{11,50}\\p{Alnum}|[\\p{Alnum}]{11,30})\\b")
    }

    var ibanInBlocksRegex: NSRegularExpression {
        let pattern = countryCodesRegex.pattern
        return NSRegularExpression("\\b(\(pattern)) ?\\d{2}(\\s{0,3}[a-zA-Z0-9]{4}){3,8}(\\s{0,3}[a-zA-Z0-9]{1,4})\\b")
    }

    var germanIBANRegex: NSRegularExpression {
        return NSRegularExpression("^DE\\d{\(countryIbanDictionary["DE"]! - 2)}$")
    }
}
