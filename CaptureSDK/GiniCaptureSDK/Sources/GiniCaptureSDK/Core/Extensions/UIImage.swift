//
//  UIImage.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 12/8/17.
//

import UIKit

extension UIImage {
    convenience init?(qrData data: Data) {
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")

        if let outputImage = filter?.outputImage {
            // Convert to CGImage because UIImage(ciImage:) was not working on the iOS 13.1 beta
            let ciContext = CIContext(options: nil)
            defer {
                ciContext.clearCaches()
            }
            guard let cgOutputImage = ciContext.createCGImage(outputImage, from: outputImage.extent) else {
                return nil
            }
            self.init(cgImage: cgOutputImage)
        } else {
            return nil
        }
    }
    
    func rotated90Degrees() -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        let rotatedOrientation = nextImageOrientationClockwise(self.imageOrientation)
        return UIImage(cgImage: cgImage, scale: 1.0, orientation: rotatedOrientation)
    }
    
    fileprivate func nextImageOrientationClockwise(_ orientation: UIImage.Orientation) -> UIImage.Orientation {
        var nextOrientation: UIImage.Orientation!
        switch orientation {
        case .up, .upMirrored:
            nextOrientation = .right
        case .down, .downMirrored:
            nextOrientation = .left
        case .left, .leftMirrored:
            nextOrientation = .up
        case .right, .rightMirrored:
            nextOrientation = .down
        @unknown default:
            preconditionFailure("All orientation must be handled")
        }
        return nextOrientation
    }
    
    static func downsample(from data: Data, to pointSize: CGSize, scale: CGFloat) -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions =
            [kCGImageSourceCreateThumbnailFromImageAlways: true,
             kCGImageSourceShouldCacheImmediately: true,
             kCGImageSourceCreateThumbnailWithTransform: true,
             kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
        
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions),
        let downsampledImage =
            CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            fatalError("Couldn't load image.")
        }
        return UIImage(cgImage: downsampledImage)
    }
    
}
