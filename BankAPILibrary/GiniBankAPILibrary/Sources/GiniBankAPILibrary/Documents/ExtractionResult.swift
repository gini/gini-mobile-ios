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

    /**
     The specific extractions.
     */
    public let extractions: [Extraction]

    /**
     The line item compound extractions.
     */
    public var lineItems: [[Extraction]]?

    /**
     The Skonto information extractions.
     */
    public var skontoDiscounts: [[Extraction]]?

    /**
     The cross-border payment compound extractions.
     */
    public var crossBorderPayment: [[Extraction]]?

    /**
     The raw `fraudSignals` compound extraction groups, kept for the SDK's own
     fraud-warning pipeline.

     Note: Intended for internal use in Gini SDKs only. Must never be surfaced
     to integrators via `AnalysisResult` and must never be sent back as feedback.

     `@nonobjc` so the property disappears from the Objective-C runtime (no
     `valueForKey:`, KVO, or `class_copyPropertyList` access). Writable only
     from within GiniBankAPILibrary; downstream SDK consumers read, they do
     not reassign.
     */
    @nonobjc
    public internal(set) var fraudSignalsRaw: [[Extraction]]?

    /**
     The extraction candidates.
     */
    public let candidates: [String: [Extraction.Candidate]]

    public init(extractions: [Extraction],
                lineItems: [[Extraction]]? = nil,
                skontoDiscounts: [[Extraction]]? = nil,
                crossBorderPayment: [[Extraction]]? = nil,
                candidates: [String: [Extraction.Candidate]]) {
        self.extractions = extractions
        self.lineItems = lineItems
        self.skontoDiscounts = skontoDiscounts
        self.crossBorderPayment = crossBorderPayment
        self.candidates = candidates

        super.init()
    }

    convenience init(extractionsContainer: ExtractionsContainer) {

        self.init(extractions: extractionsContainer.extractions,
                  lineItems: extractionsContainer.compoundExtractions?.lineItems,
                  skontoDiscounts: extractionsContainer.compoundExtractions?.skontoDiscounts,
                  crossBorderPayment: extractionsContainer.compoundExtractions?.crossBorderPayment,
                  candidates: extractionsContainer.candidates)
        self.fraudSignalsRaw = extractionsContainer.fraudSignalsRaw
    }
}
