//
//  TransactionDocType.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

public enum TransactionDocType {
    case image
    case document

    public var icon: UIImage? {
        if self == .document {
            return GiniImages.transactionDocsFileIcon.image
        }
        return nil
    }
}
