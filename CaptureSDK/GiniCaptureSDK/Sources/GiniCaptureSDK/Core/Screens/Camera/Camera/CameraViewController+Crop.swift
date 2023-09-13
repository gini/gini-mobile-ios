//
//  Camera2ViewController + Crop.swift
//  
//
//  Created by David Vizaknai on 17.04.2023.
//

import UIKit

// MARK: - Image Cropping

extension CameraViewController {
    // swiftlint:disable line_length
    func crop(image: UIImage) -> UIImage {
        let standardImageAspectRatio: CGFloat = 0.75 // Standard aspect ratio of a 3/4 image
        let screenAspectRatio = self.cameraPreviewViewController.view.frame.height / self.cameraPreviewViewController.view.frame.width
        var scale: CGFloat

        if image.size.width > image.size.height {
            // Landscape orientation

            // Calculate the scale based on the part of the image which is fully shown on the screen
            if screenAspectRatio > standardImageAspectRatio {
                // In this case the preview shows the full height of the camera preview
                scale = image.size.height / self.cameraPreviewViewController.view.frame.height
            } else {
                // In this case the preview shows the full width of the camera preview
                scale = image.size.width / self.cameraPreviewViewController.view.frame.width
            }
        } else {
            // Portrait image

            // Calculate the scale based on the part of the image which is fully shown on the screen
            if UIDevice.current.isIpad {
                if screenAspectRatio < standardImageAspectRatio {
                    // In this case the preview shows the full height of the camera preview
                    scale = image.size.height / self.cameraPreviewViewController.view.frame.height
                } else {
                    // In this case the preview shows the full width of the camera preview
                    scale = image.size.width / self.cameraPreviewViewController.view.frame.width
                }
            } else {
                scale = image.size.height / self.cameraPreviewViewController.view.frame.height
            }
        }

        // Calculate the rectangle for the displayed image on the full size captured image
        let widthDisplacement = (image.size.width - (self.cameraPreviewViewController.view.frame.width) * scale) / 2
        let heightDisplacement = (image.size.height - (self.cameraPreviewViewController.view.frame.height) * scale) / 2

        // The frame of the A4 rect
        let a4FrameRect = self.cameraPreviewViewController.cameraFrameView.frame.scaled(for: scale)

        // The origin of the cropping rect compared to the whole image
        let cropRectX = widthDisplacement + a4FrameRect.origin.x
        let cropRectY = heightDisplacement + a4FrameRect.origin.y

        // The A4 rect position and size on the whole image
        let cropRect = CGRect(x: cropRectX, y: cropRectY, width: a4FrameRect.width, height: a4FrameRect.height)

        // Scaling up the rectangle 15% on each side
        let scaledSize = CGSize(width: cropRect.width * 1.30, height: cropRect.height * 1.30)

        let scaledOriginX = cropRectX - cropRect.width * 0.15
        let scaledOriginY = cropRectY - cropRect.height * 0.15

        var scaledRect = CGRect(x: scaledOriginX, y: scaledOriginY, width: scaledSize.width, height: scaledSize.height)

        if scaledRect.origin.x >= 0 && scaledRect.origin.y >= 0 {
            // The area to be cropped is inside of the area of the image
            return cut(image: image, to: scaledRect)
        } else {
            // The area to be cropped is outside of the area of the image

            // If the area is bigger than the image, reset the origin and subtract the extra width/height that is not present
            if scaledOriginX < 0 {
                scaledRect.size.width += scaledRect.origin.x
                scaledRect.origin.x = 0
            }

            if scaledOriginY < 0 {
                scaledRect.size.height += scaledRect.origin.y
                scaledRect.origin.y = 0
            }

            return cut(image: image, to: scaledRect)
        }
    }
    // swiftlint:enable line_length

    func cut(image: UIImage, to rect: CGRect) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        guard let croppedImage = cgImage.cropping(to: rect) else { return image }
        let finalImage = UIImage(cgImage: croppedImage, scale: 1, orientation: .up)

        return finalImage
    }
}
