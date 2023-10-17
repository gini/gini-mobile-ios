//
//  IBANRecogniser.swift
//
//  Copyright © 2023 Gini GmbH. All rights reserved.
//

import Foundation

func extractIBANS(string: String) -> [String] {
    var results = [String]()
    var prefferedIBANs = [String]()
    let lenght = string.count
    let allIBANs = IBANKnowledge().universalIBANRegex.matches(in: string,
                                                              options: [],
                                                              range: NSRange(location: 0, length: lenght))
    let iBANsInBlocks = IBANKnowledge().ibanInBlocksRegex.matches(in: string,
                                                                  options: [],
                                                                  range: NSRange(location: 0, length: lenght))
    let matches = allIBANs + iBANsInBlocks

    for match in matches {
        if let range = Range(match.range, in: string) {
            let iban = String(string[range]).filter { !$0.isWhitespace }
            if IBANValidator().isValid(iban: iban) {
                let germanIBANs = IBANKnowledge().germanIBANRegex.matches(in: iban,
                                                                          options: [],
                                                                          range: NSRange(location: 0, length: iban.count))
                if !germanIBANs.isEmpty && !prefferedIBANs.contains(iban) {
                    prefferedIBANs.append(iban)
                } else {
                    if !results.contains(iban){
                        results.append(iban)
                    }
                }
            }
        }
    }
    return prefferedIBANs.isEmpty ? results : prefferedIBANs
}
