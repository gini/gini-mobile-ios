//
//  PartialDocumentInfo.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 5/3/18.
//

import GiniCapture
import GiniPayApiLib

struct PartialDocument {
    var info: GiniPayApiLib.PartialDocumentInfo
    var document: Document?
    var order: Int
}

// MARK: - Comparable

extension PartialDocument: Comparable {
    static func == (lhs: PartialDocument, rhs: PartialDocument) -> Bool {
        return lhs.info.document == rhs.info.document
    }
    
    static func < (lhs: PartialDocument, rhs: PartialDocument) -> Bool {
        return lhs.order < rhs.order
    }
}
