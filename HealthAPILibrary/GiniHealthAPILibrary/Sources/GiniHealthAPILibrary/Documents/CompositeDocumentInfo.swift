//
//  CompositeDocumentInfo.swift
//  GiniPayApiLib
//
//  Created by Enrique del Pozo Gómez on 3/20/19.
//

import Foundation

/// Information used to create a composite document
public struct CompositeDocumentInfo {
    
    /// Array containing all the partial documents used to create a composite document.
    public let partialDocuments: [PartialDocumentInfo]
    
    public init(partialDocuments: [PartialDocumentInfo]) {
        self.partialDocuments = partialDocuments
    }
}

// MARK: - Decodable

extension CompositeDocumentInfo: Encodable {
    
}
