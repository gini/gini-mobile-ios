//
//  ExtractionResult.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
/**
 * Data model for a document extraction result.
 */
@objcMembers
final public class ExtractionResult: NSObject {

    /// The specific extractions.
    public let extractions: [Extraction]

    /// The line item compound extractions.
    public var lineItems: [[Extraction]]?

    // Return reasons from which users can pick one when deselecting line items.
    public var returnReasons: [ReturnReason]?

    // The Skonto information extractions.
    public var skontoDiscounts: [[Extraction]]?
    
    
    // The cross-border payment compound extractions.
    public var crossBorderPayment: [[Extraction]]?


    /// The extraction candidates.
    public let candidates: [String: [Extraction.Candidate]]

    public init(extractions: [Extraction],
                lineItems: [[Extraction]]? = nil,
                returnReasons: [ReturnReason]? = nil,
                skontoDiscounts: [[Extraction]]? = nil,
                crossBorderPayment: [[Extraction]]? = nil,
                candidates: [String: [Extraction.Candidate]]) {
        self.extractions = extractions
        self.lineItems = lineItems
        self.returnReasons = returnReasons
        self.skontoDiscounts = skontoDiscounts
        self.crossBorderPayment = crossBorderPayment 
        self.candidates = candidates

        super.init()
    }

    convenience init(extractionsContainer: ExtractionsContainer) {

        self.init(extractions: extractionsContainer.extractions,
                  lineItems: extractionsContainer.compoundExtractions?.lineItems,
                  returnReasons: extractionsContainer.returnReasons,
                  skontoDiscounts: extractionsContainer.compoundExtractions?.skontoDiscounts,
                  crossBorderPayment: extractionsContainer.compoundExtractions?.crossBorderPayment,
                  candidates: extractionsContainer.candidates)
    }
}
