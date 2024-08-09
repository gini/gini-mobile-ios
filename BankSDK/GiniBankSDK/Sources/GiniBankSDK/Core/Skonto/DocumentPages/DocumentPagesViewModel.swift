//
//  DocumentPagesViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

// Structure to represent the size of each document page
struct DocumentPageSize {
    /// Page width
    let sizeX: Double
    /// Page height
    let sizeY: Double
}

struct CornerBoundingBoxes {
    var topLeft: ExtractionBoundingBox
    var topRight: ExtractionBoundingBox
    var bottomLeft: ExtractionBoundingBox
    var bottomRight: ExtractionBoundingBox
}

class DocumentPagesViewModel {
    let images: [UIImage]
    let originalSizes: [DocumentPageSize]
    var extractionBoundingBoxes: [ExtractionBoundingBox]

    private let highlightPadding: CGFloat = 10.0

    // Initializer for the class
    init(images: [UIImage],
         originalSizes: [DocumentPageSize],
         extractionBoundingBoxes: [ExtractionBoundingBox]) {
        self.images = images
        self.originalSizes = originalSizes
        self.extractionBoundingBoxes = extractionBoundingBoxes
    }

    // Drawing the rectangles
    func drawBoundingBoxes(on image: UIImage,
                           with size: DocumentPageSize,
                           boundingBoxes: [ExtractionBoundingBox]) -> UIImage {
        let imageHeight = image.size.height
        let imageWidth = image.size.width

        // Scale factors (calculated once)
        let scaleHeight = imageHeight / CGFloat(size.sizeY)
        let scaleWidth = imageWidth / CGFloat(size.sizeX)

        // Initialize the minimum and maximum coordinates
        var minX: CGFloat = CGFloat.greatestFiniteMagnitude
        var minY: CGFloat = CGFloat.greatestFiniteMagnitude
        var maxX: CGFloat = .zero
        var maxY: CGFloat = .zero

        // Calculate the encompassing bounding box in a single pass
        for box in boundingBoxes {
            let scaledX = CGFloat(box.left) * scaleWidth
            let scaledY = CGFloat(box.top) * scaleHeight
            let scaledWidth = CGFloat(box.width) * scaleWidth
            let scaledHeight = CGFloat(box.height) * scaleHeight

            // Directly assign min/max without redundant min/max calls
            if scaledX < minX { minX = scaledX }
            if scaledY < minY { minY = scaledY }
            if scaledX + scaledWidth > maxX { maxX = scaledX + scaledWidth }
            if scaledY + scaledHeight > maxY { maxY = scaledY + scaledHeight }
        }

        // Add padding to the calculated bounds
        minX = max(minX - highlightPadding, 0) // Ensure minX doesn't go below 0
        minY = max(minY - highlightPadding, 0) // Ensure minY doesn't go below 0
        maxX = min(maxX + highlightPadding, imageWidth) // Ensure maxX doesn't exceed image width
        maxY = min(maxY + highlightPadding, imageHeight) // Ensure maxY doesn't exceed image height

        // Create the encompassing rectangle with padding
        let encompassingRect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)

        // Begin image context and draw the image and highlight
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0)
        image.draw(at: .zero)

        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return image
        }

        let highlightColor: UIColor = .GiniBank.warning3.withAlphaComponent(0.4)
        // Set the highlight color and fill the rectangle
        context.setFillColor(highlightColor.cgColor)
        context.fill(encompassingRect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? image
    }

    /**
     Processes each image and draws the corresponding bounding area.

     - Returns: An array of processed UIImages with the bounding areas drawn.
     */
    func processImages() -> [UIImage] {
        var processedImages: [UIImage] = []
        for (index, image) in images.enumerated() {
            let originalSize = originalSizes[index]
            let boundingBoxesForPage = extractionBoundingBoxes.filter { $0.page == index + 1 }
            let newImage = drawBoundingBoxes(on: image, with: originalSize, boundingBoxes: boundingBoxesForPage)
            processedImages.append(newImage)
        }
        return processedImages
    }
}
