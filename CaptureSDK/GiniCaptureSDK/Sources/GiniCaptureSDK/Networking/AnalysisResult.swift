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
    public let extractions: [String: Extraction]

    /**
     *  Line item compound extractions obtained in the analysis.
     */
    public let lineItems: [[Extraction]]?
    
    /**
     *  The analyzed Gini Bank API document.
     *
     *  It returns `nil` when extractions were retrieved without using the Gini Bank API.
     *  For example when the extractions came from an EPS QR code.
     */
    public let document: Document?
    
    public init(extractions: [String: Extraction], lineItems: [[Extraction]]? = nil, images: [UIImage], document: Document? = nil) {
        self.images = images
        self.extractions = extractions
        self.lineItems = lineItems
        self.document = document
    }
}
