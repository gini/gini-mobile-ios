//
//  IBANChecksum.swift
//  gini-ios-ocr
//
//  Created by Maciej Trybilo on 13.11.19.
//  Copyright © 2019 Gini GmbH. All rights reserved.
//

import Foundation

private let letterToNumber = ["A" : 10, "B" : 11, "C" : 12, "D" : 13,
                              "E" : 14, "F" : 15, "G" : 16, "H" : 17,
                              "I" : 18, "J" : 19, "K" : 20, "L" : 21,
                              "M" : 22, "N" : 23, "O" : 24, "P" : 25,
                              "Q" : 26, "R" : 27, "S" : 28, "T" : 29,
                              "U" : 30, "V" : 31, "W" : 32, "X" : 33,
                              "Y" : 34, "Z" : 35
]

func isValidIBANChecksum(iban: String) -> Bool {

    let checksum = iban[iban.index(iban.startIndex, offsetBy: 2)..<iban.index(iban.startIndex, offsetBy: 4)]

    return IBANChecksum(iban: iban) == checksum
}

func IBANChecksum(iban: String) -> String {

    let countryCode = iban.prefix(2)
    let suffix = iban[iban.index(iban.startIndex, offsetBy: 4)..<iban.endIndex] // skip the country code and checksum

    let reordered = String(suffix + countryCode + "00")

    var transformed = reordered

    for map in letterToNumber {
        transformed = transformed.uppercased().replacingOccurrences(of: map.key, with: String(map.value))
    }

    //    https://www.ibantest.com/en/how-is-the-iban-check-digit-calculated
    let calculatedChecksum = (98 - modulo(n: transformed, a: 97))

    if calculatedChecksum < 10 {
        return "0\(calculatedChecksum)"
    } else {
        return "\(calculatedChecksum)"
    }
}

// https://bytes.com/topic/software-development/insights/793965-how-find-modulus-very-large-number
private func modulo(n: String, a: Int) -> Int {

    let prefixStride = 10

    var number = n

    while number.count > prefixStride {

        let prefix = number.prefix(prefixStride)
        let remainder = Int(prefix)! % a

        number.replaceSubrange(..<number.index(number.startIndex, offsetBy: prefixStride), with: String(remainder))
    }

    return Int(number)! % a
}


