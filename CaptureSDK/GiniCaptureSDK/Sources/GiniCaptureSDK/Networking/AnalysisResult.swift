//
//  AnalysisResult.swift
//  GiniCapture
//
//  Created by Gini GmbH on 4/2/19.
//

import UIKit
import GiniBankAPILibrary

@objcMembers public class AnalysisResult: NSObject {
    /// Images processed in the analysis
    public let images: [UIImage]
    /*
     *  Specific extractions obtained in the analysis.
     *  Besides the list of extractions that can be found here
     *  (http://developer.gini.net/gini-api/html/document_extractions.html#available-specific-extractions),
     *  it can also return the epsPaymentQRCodeUrl extraction, obtained from a EPS QR code.
     */
    public let extractions: [String: Extraction]

    /*
     *  Line item compound extractions obtained in the analysis.
     */
    public let lineItems: [[Extraction]]?
    
    public init(extractions: [String: Extraction], lineItems: [[Extraction]]? = nil, images: [UIImage]) {
        self.images = images
        self.extractions = extractions
        self.lineItems = lineItems
    }
}
