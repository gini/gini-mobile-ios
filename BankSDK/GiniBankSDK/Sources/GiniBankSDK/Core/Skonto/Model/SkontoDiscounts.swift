//
//  SkontoDiscounts.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import GiniBankAPILibrary

public struct SkontoDiscounts {

    let initialExtractionResult: ExtractionResult
    let discounts: [SkontoDiscountDetails]
    let totalAmountToPay: Price
}

extension SkontoDiscounts {

    enum SkontoDiscountParsingException: Error {
        case skontoDiscountsMissing
    }

    public init(extractions: ExtractionResult) throws {

        self.initialExtractionResult = extractions

        guard let extractedSkontoDiscounts = initialExtractionResult.skontoDiscounts else {
            throw SkontoDiscountParsingException.skontoDiscountsMissing
        }

        discounts = try extractedSkontoDiscounts.map { try SkontoDiscountDetails(extractions: $0) }

        if let amountToPayExtraction = initialExtractionResult.extractions.first(where: { $0.name == "amountToPay" }) {
            totalAmountToPay = Price(extractionString: amountToPayExtraction.value) ??
            Price(value: 0, currencyCode: "EUR")
        } else {
            totalAmountToPay = Price(value: 0, currencyCode: "EUR")
        }
    }
}
