//
//  GiniImageDocument.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 9/4/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

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
    public var rotationDelta: Int { // Should be normalized to be in [0, 360)
        return self.metaInformationManager.imageRotationDeltaDegrees()
    }
    
    fileprivate let metaInformationManager: ImageMetaInformationManager
    
    /**
     Initializes a GiniImageDocument.
     
     - Parameter data: PDF data
     - Parameter deviceOrientation: Device orientation when a picture was taken from the camera.
                                    In other cases it should be `nil`
     
     */
    
    init(data: Data,
         imageSource: DocumentSource,
         imageImportMethod: DocumentImportMethod? = nil,
         deviceOrientation: UIInterfaceOrientation? = nil) {
        self.previewImage = UIImage(data: data)
        self.isReviewable = true
        self.id = UUID().uuidString
        self.isImported = imageSource != DocumentSource.camera
        self.metaInformationManager = ImageMetaInformationManager(imageData: data,
                                                                  deviceOrientation: deviceOrientation,
                                                                  imageSource: imageSource,
                                                                  imageImportMethod: imageImportMethod)

        if let dataWithMetadata = metaInformationManager.imageByAddingMetadata() {
            self.data = dataWithMetadata
        } else {
            self.data = data
        }

        super.init()
        if let image = UIImage(data: data) {
            #if targetEnvironment(simulator)
            let rotatedImage = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .right)
            let croppedImage = cropImage(image: rotatedImage)!
            let finalImage = UIImage(cgImage: croppedImage.cgImage!, scale: croppedImage.scale, orientation: .up)
            self.data = finalImage.jpegData(compressionQuality: 1)!
            return
            #endif

            self.data = cropImage(image: image)!.jpegData(compressionQuality: 1)!
        }
        
    }
    
    func rotatePreviewImage90Degrees() {
        guard let rotatedImage = self.previewImage?.rotated90Degrees() else { return }
        metaInformationManager.rotate(degrees: 90, imageOrientation: rotatedImage.imageOrientation)
        
        if let data = metaInformationManager.imageByAddingMetadata() {
            self.previewImage = UIImage(data: data)
        } else {
            self.previewImage = rotatedImage
        }
    }

    private func cropImage(image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return image }
        var updatedRect: CGRect

        if image.size.width < image.size.height {
            if UIDevice.current.isIpad {
                updatedRect = CGRect(x: 350, y: 350, width: 2400, height: 3300)
            } else {
                updatedRect = CGRect(x: 20, y: 500, width: 2800, height: 2000)
            }
        } else {
            if UIDevice.current.isIpad {
                if image.imageOrientation == .up {
                    updatedRect = CGRect(x: 700, y: 50, width: 2100, height: 2900)
                } else if image.imageOrientation == .down {
                    updatedRect = CGRect(x: 1200, y: 50, width: 2100, height: 2900)
                } else {
                    // This should not happen since it is in landscape mode.
                    updatedRect = CGRect(x: 0, y: 0, width: 4032, height: 3024)
                }
            } else {
                updatedRect = CGRect(x: 500, y: 20, width: 2000, height: 2800)
            }
        }

        guard let croppedCGImage = cgImage.cropping(to: updatedRect) else { return image }
        let newImagew = UIImage(cgImage: croppedCGImage, scale: 1, orientation: image.imageOrientation)
        return newImagew
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
