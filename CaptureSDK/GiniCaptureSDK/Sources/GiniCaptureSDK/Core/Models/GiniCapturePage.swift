//
//  GiniCapturePage.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 4/12/18.
//

import Foundation

/**
 Page processed by the _Gini Capture SDK_ when using Multipage analysis.
 It holds a document, an error (if any) and if it has been uploaded
 */
public struct GiniCapturePage: Diffable {
    public var document: GiniCaptureDocument
    public var error: Error?
    public var isUploaded = false
    
    public var primaryKey: String {
        return document.id
    }
    
    public init(document: GiniCaptureDocument, error: Error? = nil, isUploaded: Bool = false) {
        self.document = document
        self.error = error
        self.isUploaded = isUploaded
    }
    
    public func isUpdated(to element: GiniCapturePage) -> Bool {
        return error?.localizedDescription == element.error?.localizedDescription &&
            isUploaded == element.isUploaded
    }
}
