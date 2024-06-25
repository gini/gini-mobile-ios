//
//  File.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import GiniHealthAPILibrary

//MARK: - Mapping Extraction
extension Extraction {
    convenience init(healthExtraction: GiniHealthAPILibrary.Extraction) {
        self.init(box: nil,
                  candidates: healthExtraction.candidates,
                  entity: healthExtraction.entity,
                  value: healthExtraction.value,
                  name: healthExtraction.name)
    }
    
    func toHealthExtraction() -> GiniHealthAPILibrary.Extraction {
        return GiniHealthAPILibrary.Extraction(box: nil,
                                               candidates: candidates,
                                               entity: entity,
                                               value: value,
                                               name: name)
    }
}

extension ExtractionResult {
    convenience init(healthExtractionResult: GiniHealthAPILibrary.ExtractionResult) {
        let extractions = healthExtractionResult.extractions.map { Extraction(healthExtraction: $0) }
        
        self.init(extractions: extractions,
                  payment: [extractions],
                  lineItems: [extractions])
    }
    
    func toHealthExtractionResult() -> GiniHealthAPILibrary.ExtractionResult {
        let healthExtractions = extractions.map { $0.toHealthExtraction() }
        return GiniHealthAPILibrary.ExtractionResult(extractions: healthExtractions,
                                                     payment: [healthExtractions],
                                                     lineItems: [healthExtractions])
    }
}
