//
//  Document.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import GiniHealthAPILibrary

/// Data model that represents a Document entity
public struct Document {
    
    /// (Optional) Array containing the path of every composite document
    public let compositeDocuments: [CompositeDocument]?
    /// The document's creation date.
    public let creationDate: Date
    /// The document's unique identifier.
    public let id: String
    /// The document's file name.
    public let name: String
    /// The document's origin.
    public let origin: Origin
    /// The number of pages.
    public let pageCount: Int
    /// The document's pages.
    public let pages: [Page]?
    /// Links to related resources, such as extractions, document, processed, layout or pages.
    public let links: Links
    /// (Optional) Array containing the path of every partial document info
    public let partialDocuments: [PartialDocumentInfo]?
    /// The processing state of the document.
    public let progress: Progress
    /// The document's source classification.
    public let sourceClassification: SourceClassification
    /// The document's expiration date.
    public let expirationDate: Date?
}

extension Document {
    /**
     It's the easiest way to initialize a `Document` if you are receiving a customized JSON structure from your proxy backend.
     
     - parameter creationDate: The document's creation date.
     - parameter id: The document's unique identifier.
     - parameter name: The document's file name.
     - parameter links: Links to related resources, such as extractions, document, processed, layout or pages.
     - parameter sourceClassification: The document's source classification. We recommend to use `scanned` or `composite`.
     - parameter expirationDate: The document's expiration date.

     - note: Custom networking only.
     */
    public init(creationDate: Date,
                id: String,
                name: String,
                links: Links,
                sourceClassification: SourceClassification,
                expirationDate: Date?) {
        self.init(compositeDocuments: [],
                  creationDate: creationDate,
                  id: id,
                  name: name,
                  origin: .upload,
                  pageCount: 1,
                  pages: [],
                  links: links,
                  partialDocuments: [],
                  progress: .completed,
                  sourceClassification: sourceClassification,
                  expirationDate: expirationDate)
    }
}

extension Document {
    /**
     * The possible states of documents. The availability of a document's extractions, layout and preview images are
     * depending on the document's progress.
     */
    public enum Progress: String, Decodable {
        /// Indicates that the document is fully processed. Preview images, extractions and the layout are available.
        case completed = "COMPLETED"
        
        /// Indicates that the document is not fully processed yet.
        /// There are no extractions, layout or preview images available.
        case pending = "PENDING"
        
        /// The document is processed, but there was an error during processing, so it is very likely that neither the
        /// extractions, layout or preview images are available
        case error = "ERROR"
    }
    
    /// The origin of an uploaded document.
    public enum Origin: String, Decodable {
        /// When a document comes from an upload
        case upload = "UPLOAD"
        
        /// Unknown origin
        case unknown = "UNKNOWN"
    }
    
    /// The possible source classifications of a document.
    public enum SourceClassification: String, Decodable {
        /// A composite document created by one or several partial documents
        case composite = "COMPOSITE"
        /// A "native" document, usually a PDF document.
        case native = "NATIVE"
        /// A scanned document, usually the result of a photographed or scanned document.
        case scanned = "SCANNED"
        /// A scanned document with the ocr information on top.
        case sandwich = "SANDWICH"
        /// A text document.
        case text = "TEXT"
    }
    
    /// A document's page, consisting of an array of number and its page number
    public struct Page {
        /// Page number
        public let number: Int
        /// Page image urls array, along with their sizes
        public let images: [(size: Size, url: URL)]
        
        //swiftlint:disable nesting
        enum CodingKeys: String, CodingKey {
            case number = "pageNumber"
            case images
        }
        
        /// Page size
        public enum Size: String, Decodable {
            /// 750x900
            case small = "750x900"
            
            /// 1280x1810
            case big = "1280x1810"
        }
        
    }
    
    /// Links to related resources, such as extractions, document, processed or layout.
    public struct Links {
        /**
         An initializer for a `Links` structure if you are receiving a customized JSON structure from your proxy backend.
         For this particular case all links will be pointed to the document's link.
         
         - parameter giniAPIDocumentURL: The document's link received from the Gini  API. This must be the same URL that you received in the `Location` header from the Gini API. For example "https://pay-api.gini.net/documents/626626a0-749f-11e2-bfd6-000000000000".
         
         - note: Custom networking only.
         */
        public init(giniAPIDocumentURL: URL) {
            self.extractions = giniAPIDocumentURL
            self.layout = giniAPIDocumentURL
            self.processed = giniAPIDocumentURL
            self.document = giniAPIDocumentURL
            self.pages = nil
        }
        
        public let extractions: URL
        public let layout: URL
        public let processed: URL
        public let document: URL
        public let pages: URL?
    }
    
    /// The document's layout, formed by an array of pages
    public struct Layout {
        /// Layout pages
        public let pages: [Page]
    }
    
    /// The document types, used as a hint during the analysis.
    public enum DocType: String, Codable {
        case bankStatement = "BankStatement"
        case contract = "Contract"
        case invoice = "Invoice"
        case receipt = "Receipt"
        case reminder = "Reminder"
        case remittanceSlip = "RemittanceSlip"
        case travelExpenseReport = "TravelExpenseReport"
        case other = "Other"
    }
    
    /// The V2 document's type. Used when creating documents in multipage mode.
    public enum TypeV2 {
        /// Partial document, consisting of pdf/image/qrCode data
        case partial(Data)
        /// Composite document, made of partial documents
        case composite(CompositeDocumentInfo)
        
        var name: String {
            switch self {
            case .partial:
                return "partial"
            case .composite:
                return "composite"
            }
        }
    }
    
    /**
     * The metadata contains any custom information regarding the upload (used later for reporting),
     * creating HTTP headers with an specific format.
     */
    public struct Metadata {
        internal let healthMeta: GiniHealthAPILibrary.Document.Metadata
        
        /**
         * The document metadata initializer with the branch ID (i.e: the BLZ of a Bank in Germany) and additional
         * headers.
         *
         * - Parameter branchId:            The branch id (i.e: the BLZ of a Bank in Germany)
         * - Parameter additionalHeaders:   Additional headers for the metadata. i.e: ["customerId":"123456"]
         */
        public init(branchId: String? = nil, additionalHeaders: [String: String]? = nil) {
            healthMeta = GiniHealthAPILibrary.Document.Metadata(branchId: branchId, additionalHeaders: additionalHeaders)
        }
    }
}

extension Document: Equatable {
    public static func == (lhs: Document, rhs: Document) -> Bool {
        lhs.id == rhs.id
    }
}
