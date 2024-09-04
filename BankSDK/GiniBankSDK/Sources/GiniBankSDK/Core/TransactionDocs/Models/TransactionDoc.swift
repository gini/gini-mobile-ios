//
//  TransactionDoc.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

public struct TransactionDoc {
    public let fileName: String
    public let type: TransactionDocType
    
    public init(fileName: String, type: TransactionDocType) {
        self.fileName = fileName
        self.type = type
    }
}
