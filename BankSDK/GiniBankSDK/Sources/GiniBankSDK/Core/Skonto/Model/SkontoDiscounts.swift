//
//  SkontoDiscounts.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import GiniBankAPILibrary

public struct SkontoDiscounts {

    private let extractionResult: ExtractionResult
    var discounts: [SkontoDiscountDetails]
    var totalAmountToPay: Price
}

extension SkontoDiscounts {

    enum SkontoDiscountParsingException: Error {
        case skontoDiscountsMissing

    }

    public init(extractions: ExtractionResult) throws {

        self.extractionResult = extractions

        guard let extractedSkontoDiscounts = extractionResult.skontoDiscounts else {
            throw SkontoDiscountParsingException.skontoDiscountsMissing
        }

        discounts = try extractedSkontoDiscounts.map { try SkontoDiscountDetails(extractions: $0) }

        if let amountToPayExtraction = extractionResult.extractions.first(where: { $0.name == "amountToPay" }) {
            totalAmountToPay = Price(extractionString: amountToPayExtraction.value) ??
            Price(value: 0, currencyCode: "EUR")
        } else {
            totalAmountToPay = Price(value: 0, currencyCode: "EUR")
        }
    }
}
