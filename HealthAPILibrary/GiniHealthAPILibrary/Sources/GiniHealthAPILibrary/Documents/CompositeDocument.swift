//
//  CompositeDocument.swift
//  GiniHealthAPILib
//
//  Created by Enrique del Pozo Gómez on 3/20/19.
//

import Foundation

/// Composite document information
public struct CompositeDocument {
    
    /// Composite document URL. Similar to this: https://api.gini.net/documents/12345678-9123-11e2-bfd6-000000000000
    public let document: URL
    
    /// The composite document’s unique identifier.
    public var id: String? {
        guard let id = document.absoluteString.split(separator: "/").last else { return nil }
        return String(id)
    }
}

// MARK: - Decodable

extension CompositeDocument: Decodable {
    
}
