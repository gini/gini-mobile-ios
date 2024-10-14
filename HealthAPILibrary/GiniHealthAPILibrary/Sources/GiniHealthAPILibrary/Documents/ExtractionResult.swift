//
//  ExtractionResult.swift
//  GiniHealthAPI
//
//  Created by Maciej Trybilo on 13.02.20.
//

import Foundation

/**
* Data model for a document extraction result.
*/
@objcMembers final public class ExtractionResult: NSObject {

    /// The specific extractions.
    public let extractions: [Extraction]
    
    /// The payment compound extractions.
    public var payment:  [[Extraction]]?
    
    /// The line item compound extractions.
    public var lineItems: [[Extraction]]?

    public init(extractions: [Extraction], payment:  [[Extraction]]?,  lineItems: [[Extraction]]?) {
        self.extractions = extractions
        self.payment = payment
        self.lineItems = lineItems
        super.init()
    }
    
    convenience init(extractionsContainer: ExtractionsContainer) {
        
        self.init(extractions: extractionsContainer.extractions,
                  payment: extractionsContainer.compoundExtractions?["payment"],
                  lineItems: extractionsContainer.compoundExtractions?["lineItems"])
    }
}
