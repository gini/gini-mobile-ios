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
        switch self {
        case .image:
            return GiniImages.transactionDocsImageIcon.image
        case .document:
            return GiniImages.transactionDocsFileIcon.image
        }
    }
}
