//
//  TransactionDocType.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

enum TransactionDocType {
    case image
    case document

    var icon: UIImage? {
        if self == .document {
            return GiniImages.transactionDocsFileIcon.image
        }
        return nil
    }
}
