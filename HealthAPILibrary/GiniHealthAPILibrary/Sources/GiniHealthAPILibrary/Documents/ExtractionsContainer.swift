//
//  ExtractionsContainer.swift
//  GiniHealthAPI
//
//  Created by Enrique del Pozo Gómez on 3/20/19.
//

import Foundation

public struct ExtractionsContainer: Decodable {
    let extractions: [Extraction]
    let compoundExtractions: [String : [[Extraction]]]?
    let candidates: [Extraction.Candidate]
    
    enum CodingKeys: String, CodingKey {
        case extractions
        case compoundExtractions
        case candidates
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let decodedExtractions = try container.decode([String : Extraction].self,
                                               forKey: .extractions)
        let decodedCompoundExtractions = try container.decodeIfPresent([String : [[String : Extraction]]].self,
                                                                forKey: .compoundExtractions)
        let decodedCandidates = try container.decodeIfPresent([String : [Extraction.Candidate]].self,
                                                       forKey: .candidates) ?? [:]

        extractions = decodedExtractions.map { (key, value) in
            let extraction = value
            extraction.name = key
            return extraction
        }

        compoundExtractions = decodedCompoundExtractions?.mapValues { (extractionDictionaries) in

            extractionDictionaries.map { extractionsDictionary -> [Extraction] in

                return extractionsDictionary.map { (key, value) -> Extraction in

                    let extraction = value
                    extraction.name = key
                    return extraction
                }
            }
        }

        candidates = decodedCandidates.flatMap { $0.value }
    }
}
