//
//  AttachmentType.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

public enum AttachmentType {
    case image
    case document

    var icon: UIImage? {
        switch self {
        case .image:
            return GiniImages.attachmentImageIcon.image
        case .document:
            return GiniImages.attachmentDocumentIcon.image
        }
    }
}
