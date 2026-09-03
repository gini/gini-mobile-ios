//
//  PartialDocument.swift
//  GiniHealthAPI
//
//  Created by Enrique del Pozo Gómez on 3/20/19.
//

import Foundation

/// Partial document info used to create a composite document
public struct PartialDocumentInfo: Codable {
    /// Partial document url
    public var document: URL?
    /// Partial document rotation delta [0-360º].
    public var rotationDelta: Int
    
    /// The partial document’s unique identifier.
    public var id: String? {
        guard let id = document?.absoluteString.split(separator: "/").last else { return nil }
        return String(id)
    }

    enum CodingKeys: String, CodingKey {
        case document
        case rotationDelta
    }
    
    public init(document: URL?, rotationDelta: Int = 0) {
        self.document = document
        self.rotationDelta = rotationDelta
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        document = try container.decodeIfPresent(URL.self, forKey: .document)
        rotationDelta = try container.decodeIfPresent(Int.self, forKey: .rotationDelta) ?? 0
    }
}
