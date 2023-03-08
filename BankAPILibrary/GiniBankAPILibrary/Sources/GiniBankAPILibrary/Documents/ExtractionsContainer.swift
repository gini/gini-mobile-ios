//
//  ExtractionsContainer.swift
//  GiniBankAPI
//
//  Created by Enrique del Pozo Gómez on 3/20/19.
//

import Foundation

struct ExtractionsContainer {
    let extractions: [Extraction]
    let compoundExtractions: [String : [[Extraction]]]?
    let candidates: [String: [Extraction.Candidate]]
    let returnReasons: [ReturnReason]?
    
    enum CodingKeys: String, CodingKey {
        case extractions
        case compoundExtractions
        case candidates
        case returnReasons
    }
}

// MARK: - Decodable

extension ExtractionsContainer: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let decodedExtractions = try container.decode([String : Extraction].self,
                                               forKey: .extractions)
        let decodedCompoundExtractions = try container.decodeIfPresent([String : [[String : Extraction]]].self,
                                                                forKey: .compoundExtractions)
        
        self.candidates = try container.decodeIfPresent([String: [Extraction.Candidate]].self,
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
        
        returnReasons = try container.decodeIfPresent([ReturnReason].self, forKey: .returnReasons)
    }
}
