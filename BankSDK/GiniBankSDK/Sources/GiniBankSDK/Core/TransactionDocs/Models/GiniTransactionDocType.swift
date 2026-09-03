//
//  GiniTransactionDocType.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

/// Represents the type of a document that is attached to a transaction.

public enum GiniTransactionDocType {
    /// Represents an image-based transaction document (e.g., PNG, JPEG).
    case image

    /// Represents a document-based transaction file (e.g., PDF).
    case document

    /// Returns an icon representing the document type.
    ///
    /// - Returns: A `UIImage` corresponding to the document type.
    ///            If the type is `.document`, it returns `GiniImages.transactionDocsFileIcon.image`.
    ///            If the type is `.image`, it returns `GiniImages.transactionDocsImageIcon.image`.
    internal var icon: UIImage? {
        switch self {
        case .document:
            return GiniImages.transactionDocsFileIcon.image
        case .image:
            return GiniImages.transactionDocsImageIcon.image
        }
    }
}
