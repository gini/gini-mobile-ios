//
//  GiniImageDocument.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 9/4/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import GiniBankAPILibrary
import UIKit
import MobileCoreServices

final public class GiniImageDocument: NSObject, GiniCaptureDocument {

    static let acceptedImageTypes: [String] = [kUTTypeJPEG as String,
                                               kUTTypePNG as String,
                                               kUTTypeGIF as String,
                                               kUTTypeTIFF as String]

    public var type: GiniCaptureDocumentType = .image
    public var id: String
    public var data: Data
    public var previewImage: UIImage?
    public var isReviewable: Bool
    public var isImported: Bool
    public var uploadMetadata: Document.UploadMetadata?
    public var rotationDelta: Int { // Should be normalized to be in [0, 360)
        return self.metaInformationManager.imageRotationDeltaDegrees()
    }

    // A flag to determine if the document is opened from another app or from the SDK
    public var isFromOtherApp: Bool
    fileprivate let metaInformationManager: ImageMetaInformationManager

    /**
     Initializes a GiniImageDocument.

     - Parameter data: PDF data
     - Parameter deviceOrientation: Device orientation when a picture was taken from the camera.
                                    In other cases it should be `nil`

     */

    init(data: Data,
         processedImageData: Data? = nil,
         imageSource: DocumentSource,
         imageImportMethod: DocumentImportMethod? = nil,
         deviceOrientation: UIInterfaceOrientation? = nil,
         uploadMetadata: Document.UploadMetadata? = nil) {
        self.previewImage = UIImage(data: processedImageData ?? data)
        self.isReviewable = true
        self.id = UUID().uuidString
        self.uploadMetadata = uploadMetadata
        switch imageSource {
        case .appName(name: _):
            isFromOtherApp = true
        default:
            isFromOtherApp = false
        }

        self.isImported = imageSource != DocumentSource.camera
        self.metaInformationManager = ImageMetaInformationManager(imageData: data,
                                                                  deviceOrientation: deviceOrientation,
                                                                  imageSource: imageSource,
                                                                  imageImportMethod: imageImportMethod)

        // The processed image data is assumed to be always in the correct orientation
        if processedImageData != nil {
            self.metaInformationManager.update(imageOrientation: .up)
        }

        if let dataWithMetadata = metaInformationManager.imageByAddingMetadata(to: processedImageData) {
            self.data = dataWithMetadata
        } else {
            self.data = data
        }
    }
}

// MARK: NSItemProviderReading

extension GiniImageDocument: NSItemProviderReading {

    static public var readableTypeIdentifiersForItemProvider: [String] {
        return acceptedImageTypes
    }

    static public func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        return self.init(data: data, imageSource: .external, imageImportMethod: .picker)
    }

}
