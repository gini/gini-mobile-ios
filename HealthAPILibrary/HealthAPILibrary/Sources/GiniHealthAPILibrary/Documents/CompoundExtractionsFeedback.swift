//
//  CompoundExtractionsFeedback.swift
//  GiniPayApiLib
//
//  Created by Alpár Szotyori on 27/08/20.
//

import Foundation

struct CompoundExtractionsFeedback {
    let extractions: [Extraction]
    let compoundExtractions: [String: [[Extraction]]]
}

// MARK: - Encodable

extension CompoundExtractionsFeedback: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case extractions
        case compoundExtractions
    }
    
    private struct NameKey: CodingKey {
        var stringValue: String
        var intValue: Int?
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        init?(intValue: Int) {
            self.intValue = intValue
            self.stringValue = "\(intValue)"
        }
    }
    
    enum ExtractionKeys: String, CodingKey {
        case value
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        var extractionsContainer = container.nestedContainer(keyedBy: NameKey.self, forKey: .extractions)
        
        try extractions.forEach { extraction in
            guard let name = extraction.name,
                let nameKey = NameKey(stringValue: name) else {
                throw GiniError.parseError(message: "Failed to encode extraction")
            }
            
            var extractionContainer = extractionsContainer.nestedContainer(keyedBy: ExtractionKeys.self, forKey: nameKey)
            
            try extractionContainer.encode(extraction.value, forKey: .value)
        }
        
        var compoundExtractionsContainer = container.nestedContainer(keyedBy: NameKey.self, forKey: .compoundExtractions)
        
        try compoundExtractions.forEach { (name, compoundExtractions) in
            guard let nameKey = NameKey(stringValue: name) else {
                throw GiniError.parseError(message: "Failed to encode compound extractions")
            }
            
            var compoundExtractionsContainer = compoundExtractionsContainer.nestedUnkeyedContainer(forKey: nameKey)
            
            try compoundExtractions.forEach { compoundExtraction in
                var compoundExtractionContainer = compoundExtractionsContainer.nestedContainer(keyedBy: NameKey.self)
                
                try compoundExtraction.forEach { extraction in
                    guard let name = extraction.name,
                        let nameKey = NameKey(stringValue: name) else {
                        throw GiniError.parseError(message: "Failed to encode compound extraction")
                    }
                    
                    var extractionContainer = compoundExtractionContainer.nestedContainer(keyedBy: ExtractionKeys.self, forKey: nameKey)
                    
                    try extractionContainer.encode(extraction.value, forKey: .value)
                }
            }
            
        }
    }
}
