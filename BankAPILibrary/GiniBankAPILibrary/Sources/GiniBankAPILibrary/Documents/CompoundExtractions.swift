//
//  CompoundExtractions.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

/**
 Models the `compoundExtractions` nested object returned by `/documents/{id}/extractions`.

 The `fraudSignals` key that lives alongside `lineItems`, `skontoDiscounts`, and
 `crossBorderPayment` under the same JSON object is deliberately not a member of this
 struct. It is decoded one level up on `ExtractionsContainer` and surfaced as
 `ExtractionResult.fraudSignalsRaw` behind the `GiniCaptureInternal` SPI, so fraud
 signals never leak onto integrator-visible surfaces (`AnalysisResult`) and never
 participate in `sendFeedback` payloads.
 */
struct CompoundExtractions: Decodable {
    var lineItems: [[Extraction]]?
    var skontoDiscounts: [[Extraction]]?
    var crossBorderPayment: [[Extraction]]?

    enum CodingKeys: String, CodingKey {
        case lineItems
        case skontoDiscounts
        case crossBorderPayment
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let lineItemsArray = try container.decodeIfPresent([[String: Extraction]].self, 
                                                              forKey: .lineItems) {
            lineItems = Self.mapExtractions(input: lineItemsArray)
        } else {
            lineItems = nil
        }
        
        if let skontoDiscountArray = try container.decodeIfPresent([[String: Extraction]].self,
                                                                   forKey: .skontoDiscounts) {
            skontoDiscounts = Self.mapExtractions(input: skontoDiscountArray)
        } else {
            skontoDiscounts = nil
        }
        
        if let crossBorderPaymentArray = try container.decodeIfPresent([[String: Extraction]].self,
                                                                       forKey: .crossBorderPayment) {
            crossBorderPayment = Self.mapExtractions(input: crossBorderPaymentArray)
        } else {
            crossBorderPayment = nil
        }
    }

    /**
     Flattens a decoded `[[String: Extraction]]` wire shape — one array element
     per group, each a dictionary keyed by extraction name — into `[[Extraction]]`
     with each `Extraction.name` assigned from its dictionary key. Shared by this
     struct's `init(from:)` and by `ExtractionsContainer`'s nested-container
     decode of `fraudSignals`.
     */
    internal static func mapExtractions(input: [[String: Extraction]]) -> [[Extraction]] {
        return input.map { dictionary in
            dictionary.map { key, extraction in
                let modifiedExtraction = extraction
                modifiedExtraction.name = key
                return modifiedExtraction
            }
        }
    }
}
