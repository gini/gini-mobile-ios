//
//  ExtractionsContainer.swift
//  GiniHealthSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

public struct ExtractionsContainer {
    let extractions: [Extraction]
    let compoundExtractions: [String : [[Extraction]]]?
    let candidates: [Extraction.Candidate]

    enum CodingKeys: String, CodingKey {
        case extractions
        case compoundExtractions
        case candidates
    }
}

// MARK: - Decodable

extension ExtractionsContainer: Decodable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let decodedExtractions = try container.decode([String : Extraction].self,
                                               forKey: .extractions)
        let decodedCompoundExtractions = try container.decodeIfPresent([String : [[String : Extraction]]].self,
                                                                forKey: .compoundExtractions)
        let decodedCandidates = try container.decodeIfPresent([String : [Extraction.Candidate]].self,
                                                       forKey: .candidates) ?? [:]

        extractions = decodedExtractions.map(ExtractionsContainer.mapExtraction)

        compoundExtractions = decodedCompoundExtractions?.mapValues(ExtractionsContainer.mapCompoundExtractions)

        candidates = decodedCandidates.flatMap { $0.value }
    }
}

private extension ExtractionsContainer {
    private static func mapExtraction(key: String, value: Extraction) -> Extraction {
        let extraction = value
        extraction.name = key
        return extraction
    }

    private static func mapCompoundExtractions(extractionDictionaries: [[String : Extraction]]) -> [[Extraction]] {
        return extractionDictionaries.map { extractionsDictionary in
            extractionsDictionary.map(mapExtraction)
        }
    }
}
