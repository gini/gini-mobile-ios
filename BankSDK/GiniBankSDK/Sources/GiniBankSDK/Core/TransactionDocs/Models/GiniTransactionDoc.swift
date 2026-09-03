//
//  GiniTransactionDoc.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

/// Represents a document that is attached to a transaction

public struct GiniTransactionDoc {
    /// The unique identifier for the document.
    public let documentId: String
    /// The name of the document file.
    public let fileName: String

    /// The type of the document (image or file).
    /// This property is internal and not exposed to the client app.
    internal let type: GiniTransactionDocType

    /// Initializes a `GiniTransactionDoc` instance.
    ///
    /// - Parameters:
    ///   - documentId: The unique identifier for the document.
    ///   - originalFileName: The original name of the file.
    ///
    /// The type of document (image or file) is determined automatically based on the file extension.
    public init(documentId: String, originalFileName: String) {
        self.documentId = documentId
        self.fileName = originalFileName
        self.type = GiniTransactionDoc.determineType(originalFileName)
    }

    /// Determines the document type based on the file extension.
    ///
    /// - Parameter fileName: The name of the file.
    /// - Returns: `.document` if the file has a `.pdf` extension, otherwise `.image`.
    private static func determineType(_ fileName: String) -> GiniTransactionDocType {
        return fileName.lowercased().hasSuffix(".pdf") ? .document : .image
    }

    /// Indicates whether the document is a file (e.g., a PDF).
    ///
    /// - Returns: `true` if the document type is `.document`, otherwise `false`.
    public var isFile: Bool {
        return type == .document
    }
}
