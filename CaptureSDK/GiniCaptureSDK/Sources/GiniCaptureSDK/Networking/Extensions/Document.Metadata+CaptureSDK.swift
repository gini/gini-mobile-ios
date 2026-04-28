//
//  Document.Metadata+CaptureSDK.swift
//  GiniCaptureSDK
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import GiniBankAPILibrary


extension Document.Metadata {
    /**
     Builds a `Document.Metadata` by merging base metadata and document upload metadata,
     then applying the active product tag.
     - Parameters:
       - base: The base metadata to start from, or `nil` to create a fresh instance.
       - document: The capture document whose `uploadMetadata` is merged in, if present.
       - productTagValue: The raw product tag string to apply.
     - Returns: A fully populated `Document.Metadata` with the product tag set.
     */
    static func build(merging base: Document.Metadata?,
                      for document: GiniCaptureDocument,
                      productTagValue: String) -> Document.Metadata {
        guard let uploadMetadata = document.uploadMetadata else {
            var meta = base ?? Document.Metadata()
            meta.addProductTag(productTagValue)
            return meta
        }
        guard var meta = base else {
            var newMeta = Document.Metadata(uploadMetadata: uploadMetadata)
            newMeta.addProductTag(productTagValue)
            return newMeta
        }
        meta.addUploadMetadata(uploadMetadata)
        meta.addProductTag(productTagValue)
        return meta
    }
}
