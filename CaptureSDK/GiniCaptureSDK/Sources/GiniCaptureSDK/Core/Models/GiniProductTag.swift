//
//  GiniProductTag.swift
//  GiniCaptureSDK
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

/**
 Defines the product type for document extraction routing.

 This configuration determines which extraction pipeline processes
 uploaded documents on the Gini backend.
 */
public enum GiniProductTag: Equatable {
    /** SEPA payment extractions (default). Routes documents through the
     standard SEPA payment processing pipeline.
     */
    case sepaExtractions

    /** Cross-border payment extractions. Routes documents through the
     CX Payments processing pipeline.
     */
    case cxExtractions

    /** Auto-detect extractions. Reserved for future use — the backend
     will auto-detect the correct pipeline.
     */
    case autoDetectExtractions

    /**
     Custom product tag for future or custom extraction pipelines.
     - Parameter value: The custom string identifier for the pipeline.
     */
    case otherProductTag(String)

    /**
     The string value used for metadata and API communication.
     - Returns: The raw string representation of the product tag.
     */
    public var rawValue: String {
        switch self {
        case .sepaExtractions:
            return "sepaExtractions"
        case .cxExtractions:
            return "cxExtractions"
        case .autoDetectExtractions:
            return "autoDetectExtractions"
        case .otherProductTag(let value):
            return value
        }
    }
}
