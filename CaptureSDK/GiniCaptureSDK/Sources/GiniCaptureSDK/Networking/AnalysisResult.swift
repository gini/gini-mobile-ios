//
//  AnalysisResult.swift
//  GiniCapture
//
//  Created by Gini GmbH on 4/2/19.
//

import UIKit
import GiniBankAPILibrary

@objcMembers public class AnalysisResult: NSObject {
    /**
     * Images processed in the analysis.
     */
    public let images: [UIImage]
    
    /**
     *  Specific extractions obtained in the analysis.
     *
     *  Besides the list of extractions that can be found
     *  [here](https://pay-api.gini.net/documentation/#specific-extractions),
     *  it can also return the epsPaymentQRCodeUrl extraction, obtained from a EPS QR code.
     */
    public var extractions: [String: Extraction]
    
    /**
     *  Line item compound extractions obtained in the analysis.
     */
    public let lineItems: [[Extraction]]?

    /**
     *  Skonto extractions obtained in the analysis.
     */
    public let skontoDiscounts: [[Extraction]]?
    
    /**
     *   Cross-border payment compound extractions obtained in the analysis.
     */
    public let crossBorderPayment: [[Extraction]]?

    /**
     *  The analyzed Gini Bank API document.
     *
     *  It returns `nil` when extractions were retrieved without using the Gini Bank API.
     *  For example when the extractions came from an EPS QR code.
     */
    public let document: Document?
    
    /*
     *  Extraction candidates dictionary. To get the candidates for an extraction look for the
     *  `Extraction.candidates` name in the dictionary. For example the IBAN extraction's `candidates` field
     *  contains `"ibans"` and if you search for that in this dictionary, then you'll get all the IBAN candidates.
     */
    public let candidates: [String: [Extraction.Candidate]]
    
    public init(extractions: [String: Extraction],
                lineItems: [[Extraction]]? = nil,
                skontoDiscounts: [[Extraction]]? = nil,
                crossBorderPayment: [[Extraction]]? = nil,
                images: [UIImage],
                document: Document? = nil,
                candidates: [String: [Extraction.Candidate]]) {
        self.images = images
        self.extractions = extractions
        self.lineItems = lineItems
        self.skontoDiscounts = skontoDiscounts
        self.crossBorderPayment = crossBorderPayment
        self.document = document
        self.candidates = candidates
    }
}
