//
//  Document.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

/**
 A data model representing a Document entity.
 */
public struct Document {
    
    /**
     An optional array containing the path of every composite document.
     */
    public let compositeDocuments: [CompositeDocument]?
    /**
     The document's creation date.
     */
    public let creationDate: Date
    /**
     The document's unique identifier.
     */
    public let id: String
    /**
     The document's file name.
     */
    public let name: String
    /**
     The document's origin.
     */
    public let origin: Origin
    /**
     The number of pages.
     */
    public let pageCount: Int
    /**
     The document's pages.
     */
    public let pages: [Page]?
    /**
     Links to related resources, such as extractions, document, processed, layout, or pages.
     */
    public let links: Links
    /**
     An optional array containing the path of every partial document info.
     */
    public let partialDocuments: [PartialDocumentInfo]?
    /**
     The processing state of the document.
     */
    public let progress: Progress
    /**
     The document's source classification.
     */
    public let sourceClassification: SourceClassification
    
    fileprivate enum Keys: String, CodingKey {
        case compositeDocuments
        case creationDate
        case id
        case links = "_links"
        case name
        case origin
        case pageCount
        case pages
        case partialDocuments
        case progress
        case sourceClassification
    }
    
    init(compositeDocuments: [CompositeDocument]?,
         creationDate: Date,
         id: String,
         name: String,
         origin: Origin,
         pageCount: Int,
         pages: [Page]?,
         links: Links,
         partialDocuments: [PartialDocumentInfo]?,
         progress: Progress,
         sourceClassification: SourceClassification) {
        self.compositeDocuments = compositeDocuments
        self.creationDate = creationDate
        self.id = id
        self.name = name
        self.origin = origin
        self.pageCount = pageCount
        self.pages = pages
        self.links = links
        self.partialDocuments = partialDocuments
        self.progress = progress
        self.sourceClassification = sourceClassification
    }
    
    /**
     Initializes a `Document` when receiving a customized JSON structure from a proxy backend.
     - Parameters:
       - creationDate: The document's creation date.
       - id: The document's unique identifier.
       - name: The document's file name.
       - links: Links to related resources, such as extractions, document, processed, layout, or pages.
       - sourceClassification: The document's source classification. Use `scanned` or `composite`.
     - Note: Screen API with custom networking only.
     */
    public init(creationDate: Date,
                id: String,
                name: String,
                links: Links,
                sourceClassification: SourceClassification) {
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
                  sourceClassification: sourceClassification)
    }
}

// MARK: - Inner types

extension Document {
    /**
     The possible states of a document. The availability of extractions, layout, and preview images
     depends on the document's progress.
     */
    public enum Progress: String, Decodable {
        /**
         Indicates that the document is fully processed. Preview images, extractions, and the layout are available.
         */
        case completed = "COMPLETED"
        
        /**
         Indicates that the document is not yet fully processed. Extractions, layout, and preview images are unavailable.
         */
        case pending = "PENDING"
        
        /**
         Indicates that processing completed with an error. Extractions, layout, and preview images are likely unavailable.
         */
        case error = "ERROR"
    }
    
    /**
     The origin of an uploaded document.
     */
    public enum Origin: String, Decodable {
        /**
         Indicates that the document was uploaded by the user.
         */
        case upload = "UPLOAD"
        
        /**
         Indicates that the document origin is unknown.
         */
        case unknown = "UNKNOWN"
    }
    
    /**
     The possible source classifications of a document.
     */
    public enum SourceClassification: String, Decodable {
        /**
         A composite document created from one or more partial documents.
         */
        case composite = "COMPOSITE"
        /**
         A native document, usually a PDF.
         */
        case native = "NATIVE"
        /**
         A scanned document, typically the result of a photographed or scanned page.
         */
        case scanned = "SCANNED"
        /**
         A scanned document with OCR information overlaid.
         */
        case sandwich = "SANDWICH"
        /**
         A plain text document.
         */
        case text = "TEXT"
    }
    
    /**
     The document types, used as a hint during analysis.
     */
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
    
    /**
     Links to related resources, such as extractions, document, processed, or layout.
     */
    public struct Links {
        public let extractions: URL
        public let layout: URL
        public let processed: URL
        public let document: URL
        public let pages: URL?
        
        /**
         Initializes a `Links` structure when receiving a customized JSON structure from a proxy backend.
         All link properties are set to the provided document URL.
         - Parameters:
           - giniAPIDocumentURL: The document URL received from the Gini API, matching the `Location` header value.
         - Note: Screen API with custom networking only.
         */
        public init(giniAPIDocumentURL: URL) {
            self.extractions = giniAPIDocumentURL
            self.layout = giniAPIDocumentURL
            self.processed = giniAPIDocumentURL
            self.document = giniAPIDocumentURL
            self.pages = nil
        }
    }
    
    /**
     The document's layout, consisting of an array of pages.
     */
    public struct Layout {
        /**
         The pages that make up the layout.
         */
        public let pages: [Page]
    }
    
    /**
     A single page of a document, identified by its page number and available image URLs.
     */
    public struct Page {
        /**
         The page number.
         */
        public let number: Int
        /**
         The available image URLs for this page, paired with their sizes.
         */
        public let images: [(size: Size, url: URL)]

        //swiftlint:disable nesting
        enum CodingKeys: String, CodingKey {
            case number = "pageNumber"
            case images
        }
        
        /**
         The available sizes for a page image.
         */
        public enum Size: String, Decodable {
            /**
             A 750×900 image.
             */
            case small = "750x900"
            
            /**
             A 1280×1810 image.
             */
            case big = "1280x1810"

            case large
            case medium
        }
    }
    
    /**
     The V2 document type, used when creating documents in multipage mode.
     */
    public enum TypeV2 {
        /**
         A partial document containing PDF, image, or QR code data.
         */
        case partial(Data)
        /**
         A composite document assembled from one or more partial documents.
         */
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
     Metadata containing custom information about the upload, expressed as HTTP headers with a specific format.
     */
    public struct Metadata {
        var headers: [String: String] = [:]
        var giniBankSDKVersion: String?
        static let headerKeyPrefix = "X-Document-Metadata-"
        static let branchIdHeaderKey = "BranchId"
        static let uploadHeaderKey = "Upload"
        static let productTagHeaderKey = "product-tag"

        /**
         Initializes document metadata with an optional branch ID, upload metadata, SDK version, and additional headers.
         - Parameters:
           - branchId: The branch ID, such as the BLZ of a bank in Germany.
           - uploadMetadata: Optional upload metadata to include.
           - bankSDKVersion: The GiniBank SDK version string to embed in the upload metadata.
           - additionalHeaders: Additional custom headers. For example: `["customerId": "123456"]`.
         */
        public init(branchId: String? = nil,
            uploadMetadata: UploadMetadata? = nil,
            bankSDKVersion: String? = nil,
            additionalHeaders: [String: String]? = nil) {
            if let branchId = branchId {
                headers[Document.Metadata.headerKeyPrefix + Document.Metadata.branchIdHeaderKey] = branchId
            }
            self.giniBankSDKVersion = bankSDKVersion
            var comment = uploadMetadata?.userComment
            if let bankSDKVersion {
                comment = UploadMetadata.userComment(comment, addingIfNotPresent: bankSDKVersion, forKey: "GiniBankVer")
            }
            headers[Document.Metadata.headerKeyPrefix + Document.Metadata.uploadHeaderKey] = comment

            if let additionalHeaders = additionalHeaders {
                additionalHeaders.forEach { headers["\(Document.Metadata.headerKeyPrefix)\($0)"] = $1 }
            }
        }

        /**
         Appends the GiniBank SDK version to the upload metadata headers.
         - Parameters:
           - giniBankSDKVersion: The GiniBank SDK version string to record.
         */
        public mutating func addGiniBankSDKVersion(_ giniBankSDKVersion: String) {
            self.giniBankSDKVersion = giniBankSDKVersion
            let key = Document.Metadata.headerKeyPrefix + Document.Metadata.uploadHeaderKey
            let existingValue = headers[key]

            headers[Document.Metadata.headerKeyPrefix + Document.Metadata.uploadHeaderKey] = UploadMetadata.userComment(existingValue, addingIfNotPresent: giniBankSDKVersion, forKey: "GiniBankVer")
        }

        /**
         Adds upload metadata to the document metadata headers.
         - Parameters:
           - uploadMetadata: The upload metadata to attach.
         */
        public mutating func addUploadMetadata(_ uploadMetadata: UploadMetadata) {
            var comment = uploadMetadata.userComment
            if let giniBankSDKVersion {
                comment = UploadMetadata.userComment(comment, addingIfNotPresent: giniBankSDKVersion, forKey: "GiniBankVer")
            }
            headers[Document.Metadata.headerKeyPrefix + Document.Metadata.uploadHeaderKey] = comment
        }

        /**
         Indicates whether upload metadata is present in the headers.
         - Returns: `true` if the upload metadata header key exists; otherwise, `false`.
         */
        public func hasUploadMetadata() -> Bool {
            headers.keys.contains(Document.Metadata.headerKeyPrefix + Document.Metadata.uploadHeaderKey)
        }

        /**
         Sets the product tag header, which tells the Gini backend which extraction pipeline
         to route the document through.
         Header name: `X-Document-Metadata-product-tag`.
         Allowed values: `sepaExtractions`, `cxExtractions`, `autoDetectExtractions`.
         - Parameters:
           - rawValue: The raw string value for the product tag.
         */
        public mutating func addProductTag(_ rawValue: String) {
            headers[Document.Metadata.headerKeyPrefix + Document.Metadata.productTagHeaderKey] = rawValue
        }
    }
}

// MARK: - Decodable

extension Document: Decodable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let compositeDocuments = try container.decodeIfPresent([CompositeDocument].self, forKey: .compositeDocuments)
        let creationDate = try container.decode(Date.self, forKey: .creationDate)
        let id = try container.decode(String.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let origin = try container.decode(Origin.self, forKey: .origin)
        let pageCount = try container.decode(Int.self, forKey: .pageCount)
        let pages = try container.decodeIfPresent([Page].self, forKey: .pages)
        let links = try container.decode(Links.self, forKey: .links)
        let partialDocuments = try container.decodeIfPresent([PartialDocumentInfo].self, forKey: .partialDocuments)
        let progress = try container.decode(Progress.self, forKey: .progress)
        let sourceClassification = try container.decode(SourceClassification.self,
                                                        forKey: .sourceClassification)
        
        self.init(compositeDocuments: compositeDocuments,
                  creationDate: creationDate,
                  id: id,
                  name: name,
                  origin: origin,
                  pageCount: pageCount,
                  pages: pages,
                  links: links,
                  partialDocuments: partialDocuments,
                  progress: progress,
                  sourceClassification: sourceClassification)
    }
}

extension Document.Links: Decodable {
    
}

extension Document.Layout: Decodable {
    
}
