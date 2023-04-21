//
//  Collection.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 10/30/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation

extension Collection {
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

extension Collection where Iterator.Element == CFString {

    var strings: [ String ] {
        return self.map { $0 as String }
    }
}

public extension Collection where Iterator.Element == GiniCaptureDocument {
    var containsDifferentTypes: Bool {
        if let firstElement = first {
            let otherTypes = filter { $0.type != firstElement.type }
            return otherTypes.isNotEmpty
        }

        return true
    }

    var type: GiniCaptureDocumentType? {
        return containsDifferentTypes ? nil : first?.type
    }
}

public extension Array where Iterator.Element == GiniCapturePage {
    mutating func remove(_ document: GiniCaptureDocument) {
        if let documentIndex = (self.firstIndex { $0.document.id == document.id }) {
            remove(at: documentIndex)
        }
    }

    func index(of document: GiniCaptureDocument) -> Int? {
        if let documentIndex = (self.firstIndex { $0.document.id == document.id }) {
            return documentIndex
        }
        return nil
    }

    var type: GiniCaptureDocumentType? {
        return map {$0.document}.type
    }
}
