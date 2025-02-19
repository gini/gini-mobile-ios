//
//  ImageAsset.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

enum ImageAsset: String {
    case transactionDocsFileIcon = "transactionDocs_attached_document_file_icon"
    case transactionDocsImageIcon = "transactionDocs_attached_image_icon"

    var image: UIImage {
        return UIImage(named: rawValue).require(hint: "Image with name \(rawValue) missing")
    }

}
