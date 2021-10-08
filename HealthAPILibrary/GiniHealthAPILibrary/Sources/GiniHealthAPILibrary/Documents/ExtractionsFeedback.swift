//
//  ExtractionsFeedback.swift
//  GiniHealthAPILib
//
//  Created by Enrique del Pozo Gómez on 3/22/19.
//

import Foundation

struct ExtractionsFeedback {
    let feedback: [Extraction]
}

// MARK: - Encodable

extension ExtractionsFeedback: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case feedback
    }
    
    private struct FeedbackKey: CodingKey {
        var stringValue: String
        var intValue: Int?
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        init?(intValue: Int) {
            self.intValue = intValue
            stringValue = "\(intValue)"
        }
        static func key(named name: String) -> CodingKeys? {
            return CodingKeys(stringValue: name)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var feedbackContainer = container.nestedContainer(keyedBy: FeedbackKey.self, forKey: .feedback)
        
        try feedback.forEach { extraction in
            guard let name = extraction.name,
                let key = FeedbackKey(stringValue: name),
                let valueKey = FeedbackKey(stringValue: "value") else {
                throw GiniError.parseError(message: "Failed to encode feedback")
            }
            
            var extractionContainer = feedbackContainer.nestedContainer(keyedBy: FeedbackKey.self, forKey: key)

            try extractionContainer.encode(extraction.value, forKey: valueKey)
        }
    }
}
