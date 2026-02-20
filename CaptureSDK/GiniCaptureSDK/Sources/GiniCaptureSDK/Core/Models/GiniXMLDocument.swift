//
//  GiniXMLDocument.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import GiniBankAPILibrary
import UIKit
import MobileCoreServices

/**
 A Gini Capture document made from a XML file.
 */
final public class GiniXMLDocument: NSObject, GiniCaptureDocument {
    static let acceptedXMLTypes: [String] = [kUTTypeXML as String]

    public var type: GiniCaptureDocumentType = .xml
    public var id: String
    public let data: Data
    public var previewImage: UIImage?
    public var isReviewable: Bool = false
    public var isImported: Bool = true
    public var uploadMetadata: Document.UploadMetadata?
    public let xmlFileName: String?

    /**
     Initializes a `GiniXMLDocument` with XML data, an optional file name, and optional upload metadata.

     - Parameters:
       - data: The raw contents of the XML document.
       - fileName: The name of the XML file, if available.
       - uploadMetadata: Optional metadata to be included when uploading the document.
     */
    init(data: Data, fileName: String?, uploadMetadata: Document.UploadMetadata? = nil) {
        self.data = data
        self.xmlFileName = fileName
        self.id = UUID().uuidString
        self.uploadMetadata = uploadMetadata
        super.init()
    }
}

// MARK: NSItemProviderReading

extension GiniXMLDocument: NSItemProviderReading {

    static public var readableTypeIdentifiersForItemProvider: [String] {
        return acceptedXMLTypes
    }

    static public func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        return self.init(data: data, fileName: nil)
    }
}
