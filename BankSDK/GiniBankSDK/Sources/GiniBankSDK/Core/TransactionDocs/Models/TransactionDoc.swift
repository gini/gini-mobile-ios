//
//  TransactionDoc.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

public struct TransactionDoc {
    public let documentId: String
    public let fileName: String
    public let type: TransactionDocType

    // Public initializer
    public init(documentId: String, fileName: String, type: TransactionDocType) {
        self.documentId = documentId
        self.fileName = fileName
        self.type = type
    }
}
