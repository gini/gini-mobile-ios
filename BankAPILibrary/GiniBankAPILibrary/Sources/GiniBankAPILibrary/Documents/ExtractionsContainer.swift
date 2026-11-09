//
//  ExtractionsContainer.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

struct ExtractionsContainer {
    let extractions: [Extraction]
    let compoundExtractions: CompoundExtractions?
    let fraudSignals: [[Extraction]]?
    let candidates: [String: [Extraction.Candidate]]

    enum CodingKeys: String, CodingKey {
        case extractions
        case compoundExtractions
        case candidates
    }

    private enum FraudSignalsKey: String, CodingKey {
        case fraudSignals
    }
}

// MARK: - Decodable

extension ExtractionsContainer: Decodable {

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let decodedExtractions = try container.decode([String: Extraction].self,
                                                      forKey: .extractions)
        compoundExtractions = try container.decodeIfPresent(CompoundExtractions.self,
                                                            forKey: .compoundExtractions)

        if let compoundContainer = try? container.nestedContainer(keyedBy: FraudSignalsKey.self,
                                                                  forKey: .compoundExtractions),
           let rawFraudSignals = try compoundContainer.decodeIfPresent([[String: Extraction]].self,
                                                                       forKey: .fraudSignals) {
            fraudSignals = CompoundExtractions.mapExtractions(input: rawFraudSignals)
        } else {
            fraudSignals = nil
        }

        self.candidates = try container.decodeIfPresent([String: [Extraction.Candidate]].self,
                                                       forKey: .candidates) ?? [:]


        extractions = decodedExtractions.map { (key, value) in
            let extraction = value
            extraction.name = key
            return extraction
        }
    }
}
