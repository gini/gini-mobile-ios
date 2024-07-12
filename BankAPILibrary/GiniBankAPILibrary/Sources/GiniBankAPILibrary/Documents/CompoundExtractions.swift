//
//  CompoundExtractions.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

struct CompoundExtractions: Decodable {
    var lineItems: [[Extraction]]?
    var skontoDiscounts: [[Extraction]]?

    enum CodingKeys: String, CodingKey {
        case lineItems
        case skontoDiscounts
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let lineItemsArray = try container.decodeIfPresent([[String: Extraction]].self, 
                                                              forKey: .lineItems) {
            lineItems = mapExtractions(input: lineItemsArray)
        } else {
            lineItems = nil
        }
        
        if let skontoDiscountArray = try container.decodeIfPresent([[String: Extraction]].self,
                                                                   forKey: .skontoDiscounts) {
            skontoDiscounts = mapExtractions(input: skontoDiscountArray)
        } else {
            skontoDiscounts = nil
        }
    }

    private func mapExtractions(input: [[String: Extraction]]) -> [[Extraction]] {
        return input.map { dictionary in
            dictionary.map { key, extraction in
                let modifiedExtraction = extraction
                modifiedExtraction.name = key
                return modifiedExtraction
            }
        }
    }
}
