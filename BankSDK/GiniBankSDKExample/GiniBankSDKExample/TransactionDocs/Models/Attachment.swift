//
//  Attachment.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//


import UIKit

struct Attachment: Codable {
    let documentId: String
    let filename: String
    let type: AttachmentType
}

enum AttachmentType: String, Codable {
    case image
    case document

    var icon: UIImage? {
        if self == .document {
            return ImageAsset.transactionDocsFileIcon.image
        }
        return nil
    }
}
