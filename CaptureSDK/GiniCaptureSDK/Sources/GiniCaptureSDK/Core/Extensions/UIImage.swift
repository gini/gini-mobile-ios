//
//  UIImage.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 12/8/17.
//

import UIKit
import AVFoundation

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

    func tintedImageWithColor(_ color: UIColor) -> UIImage? {
        let image = withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.set()
        image.draw(in: CGRect(origin: .zero, size: size))

        guard let imageColored = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        return imageColored
    }

    /// Extension to fix orientation of an UIImage without EXIF
    func fixOrientation() -> UIImage {

        guard let cgImage = cgImage else { return self }

        // If the image is already in '.up' orientation, just return
        if imageOrientation == .up { return self }

        // Create a transform to apply on the image to redraw it in '.up' orientation
        var transform = CGAffineTransform.identity

        switch imageOrientation {

        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))

        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2))

        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi / 2))

        case .up, .upMirrored:
            break
        @unknown default:
            break
        }

        // For mirrored orientations, mirror the transform as well
        switch imageOrientation {

        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)

        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)

        case .up, .down, .left, .right:
            break
        @unknown default:
            break
        }

        // Create a context where the image will be drawn
        if let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height),
                               bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0,
                               space: cgImage.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {

            ctx.concatenate(transform)

            // Draw the image in the rect defined above
            switch imageOrientation {

            case .left, .leftMirrored, .right, .rightMirrored:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))

            default:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            }

            // Return the redrawn image in '.up' orientation
            if let finalImage = ctx.makeImage() {
                return (UIImage(cgImage: finalImage))
            }
        }

        // If something failed -- return original
        return self
    }
}

extension UIImage.Orientation {
    init(_ cgOrientation: AVCaptureVideoOrientation) {
        switch cgOrientation {
        case .portrait:
            self = .up
        case .landscapeRight:
            self = .right
        case .landscapeLeft:
            self = .left
        case .portraitUpsideDown:
            self = .down
        @unknown default:
            fatalError("Unknown AVCaptureVideoOrientation case encountered")
        }
    }
}
