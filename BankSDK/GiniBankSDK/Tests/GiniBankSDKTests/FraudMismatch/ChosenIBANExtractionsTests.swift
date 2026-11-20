//
//  ChosenIBANExtractionsTests.swift
//  GiniBankSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import Testing
import GiniBankAPILibrary
@testable import GiniBankSDK

@Suite("ChosenIBANExtractions")
struct ChosenIBANExtractionsTests {

    private static let backendIBAN = "DE89 3704 0044 0532 0130 00"
    private static let printedIBAN = "DE02 1203 0000 0000 2020 51"
    private static let backendBIC = "COBADEFFXXX"

    @Test("nil chosenIBAN returns extractions unchanged")
    func nilChosen_returnsInput() {
        let input = Self.baseExtractions()
        let output = ChosenIBANExtractions.apply(input, chosenIBAN: nil)

        #expect(output[ChosenIBANExtractions.ibanKey]?.value == Self.backendIBAN)
        #expect(output[ChosenIBANExtractions.bicKey]?.value == Self.backendBIC)
    }

    @Test("blank chosenIBAN returns extractions unchanged")
    func blankChosen_returnsInput() {
        let input = Self.baseExtractions()
        let output = ChosenIBANExtractions.apply(input, chosenIBAN: "   \n")

        #expect(output[ChosenIBANExtractions.ibanKey]?.value == Self.backendIBAN)
        #expect(output[ChosenIBANExtractions.bicKey]?.value == Self.backendBIC)
    }

    @Test("chosen IBAN matching backend (ignoring whitespace + case) preserves BIC")
    func sameChosenNormalized_preservesBIC() {
        let input = Self.baseExtractions()
        let output = ChosenIBANExtractions.apply(input, chosenIBAN: "de8937040044053201 3000")

        #expect(output[ChosenIBANExtractions.ibanKey]?.value == Self.backendIBAN)
        #expect(output[ChosenIBANExtractions.bicKey]?.value == Self.backendBIC)
    }

    @Test("different chosen IBAN replaces iban and removes bic")
    func differentChosen_replacesIBAN_removesBIC() {
        let input = Self.baseExtractions()
        let output = ChosenIBANExtractions.apply(input, chosenIBAN: Self.printedIBAN)

        let chosen = output[ChosenIBANExtractions.ibanKey]
        #expect(chosen?.value == Self.printedIBAN)
        #expect(chosen?.name == ChosenIBANExtractions.ibanKey)
        #expect(chosen?.entity == ChosenIBANExtractions.ibanKey)
        #expect(chosen?.box == nil)
        #expect(chosen?.candidates == "ibans")
        #expect(output[ChosenIBANExtractions.bicKey] == nil)
    }

    @Test("missing iban extraction returns input unchanged")
    func missingIbanEntry_returnsInput() {
        let input = [ChosenIBANExtractions.bicKey: Self.makeExtraction(name: ChosenIBANExtractions.bicKey,
                                                                        value: Self.backendBIC,
                                                                        candidates: nil)]
        let output = ChosenIBANExtractions.apply(input, chosenIBAN: Self.printedIBAN)

        #expect(output[ChosenIBANExtractions.ibanKey] == nil)
        #expect(output[ChosenIBANExtractions.bicKey]?.value == Self.backendBIC)
    }

    // MARK: - Fixtures

    private static func baseExtractions() -> [String: Extraction] {
        [ChosenIBANExtractions.ibanKey: makeExtraction(name: ChosenIBANExtractions.ibanKey,
                                                       value: backendIBAN,
                                                       candidates: "ibans"),
         ChosenIBANExtractions.bicKey: makeExtraction(name: ChosenIBANExtractions.bicKey,
                                                      value: backendBIC,
                                                      candidates: nil)]
    }

    private static func makeExtraction(name: String,
                                       value: String,
                                       candidates: String?) -> Extraction {
        Extraction(box: nil,
                   candidates: candidates,
                   entity: name,
                   value: value,
                   name: name)
    }
}
