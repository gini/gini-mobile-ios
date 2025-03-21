//
//  SkontoDocumentPagesViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

struct DocumentPageSize {
    let width: Double
    let height: Double
}

struct CornerBoundingBoxes {
    var topLeft: ExtractionBoundingBox
    var topRight: ExtractionBoundingBox
    var bottomLeft: ExtractionBoundingBox
    var bottomRight: ExtractionBoundingBox
}

final class SkontoDocumentPagesViewModel: DocumentPagesViewModelProtocol {
    private let originalImages: [UIImage]
    private let originalSizes: [DocumentPageSize]
    private var extractionBoundingBoxes: [ExtractionBoundingBox]
    private var amountToPay: Price
    private var skontoAmountToPay: Price
    private var expiryDate: Date

    // Information to be displayed in the screen after highlighting Skonto details
    private(set) var processedImages = [UIImage]()
    static var screenTitle = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.document.pages.screen.title",
                                                                              comment: "Skonto discount details")
    static var errorButtonTitle = NSLocalizedStringPreferredGiniBankFormat(
        "ginibank.skonto.document.pages.error.tryAgain.buttonTitle",
        comment: "Try again")
    var bottomInfoItems: [String] {
        return [expiryDateString, withDiscountPriceString, withoutDiscountPriceString]
    }
    var rightBarButtonAction: (() -> Void)?

    private let highlightPadding: CGFloat = 10.0

    // Initializer for the class
    init(originalImages: [UIImage],
         originalSizes: [DocumentPageSize],
         extractionBoundingBoxes: [ExtractionBoundingBox],
         amountToPay: Price,
         skontoAmountToPay: Price,
         expiryDate: Date) {
        self.originalImages = originalImages
        self.originalSizes = originalSizes
        self.extractionBoundingBoxes = extractionBoundingBoxes
        self.amountToPay = amountToPay
        self.skontoAmountToPay = skontoAmountToPay
        self.expiryDate = expiryDate
    }

    func updateExpiryDate(date: Date) {
        expiryDate = date
    }

    func updateAmountToPay(price: Price) {
        amountToPay = price
    }

    func updateSkontoAmountToPay(price: Price) {
        skontoAmountToPay = price
    }

    /// Highlights Skonto-related details on an image by drawing a rectangle
    /// around specified bounding boxes.
    ///
    /// This method takes an image, its original size, and a list of bounding boxes
    /// corresponding to Skoto details areas that need to be highlighted. It then calculates an
    /// encompassing rectangle that covers all the bounding boxes, adds padding,
    /// and draws the rectangle on the image with a semi-transparent highlight color.
    ///
    /// - Parameters:
    ///   - image: The image on which to draw the highlight.
    ///   - size: The original size of the document page used to calculate scaling factors.
    ///   - boundingBoxes: An array of `ExtractionBoundingBox` representing areas to be highlighted.
    ///
    /// - Returns: A new `UIImage` with the highlighted area, or the original image if an error occurs.
    func highlightSkontoDetails(on image: UIImage,
                                with size: DocumentPageSize,
                                boundingBoxes: [ExtractionBoundingBox]) -> UIImage {
        let imageHeight = image.size.height
        let imageWidth = image.size.width

        // Scale factors (calculated once)
        let scaleHeight = imageHeight / CGFloat(size.height)
        let scaleWidth = imageWidth / CGFloat(size.width)

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
            if scaledX < minX {
                minX = scaledX
            }

            if scaledY < minY {
                minY = scaledY
            }

            if scaledX + scaledWidth > maxX {
                maxX = scaledX + scaledWidth
            }

            if scaledY + scaledHeight > maxY {
                maxY = scaledY + scaledHeight
            }
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
    func imagesForDisplay() -> [UIImage] {
        guard processedImages.isEmpty else {
            return processedImages
        }
        var processedImages: [UIImage] = []
        for (index, image) in originalImages.enumerated() {
            guard index < originalSizes.count else {
                print("Error: Index \(index) is out of bounds for originalSizes array.")
                // The loop safely skips any invalid indices, preventing errors.
                continue
            }
            let originalSize = originalSizes[index]
            let boundingBoxesForPage = extractionBoundingBoxes.filter { $0.page == index + 1 }
            let newImage = highlightSkontoDetails(on: image,
                                                  with: originalSize,
                                                  boundingBoxes: boundingBoxesForPage)
            processedImages.append(newImage)
        }
        self.processedImages = processedImages
        return processedImages
    }

    var withoutDiscountPriceString: String {
        let localizableText = "ginibank.skonto.withoutdiscount.price.title"
        let withoutDiscountPriceLabel = NSLocalizedStringPreferredGiniBankFormat(localizableText,
                                                            comment: "Without discount")
        return String.concatenateWithSeparator(withoutDiscountPriceLabel,
                                               amountToPay.localizedStringWithCurrencyCode ?? "")
    }

    var withDiscountPriceString: String {
        let localizableText = "ginibank.skonto.withdiscount.price.title"
        let withDiscountPriceLabel = NSLocalizedStringPreferredGiniBankFormat(localizableText,
                                                            comment: "With discount")
        return String.concatenateWithSeparator(withDiscountPriceLabel,
                                               skontoAmountToPay.localizedStringWithCurrencyCode ?? "")
    }

    var expiryDateString: String {
        let localizableText = "ginibank.skonto.withdiscount.expirydate.title"
        let expiryDateLabel = NSLocalizedStringPreferredGiniBankFormat(localizableText,
                                                            comment: "Expiry date")
        return String.concatenateWithSeparator(expiryDateLabel,
                                               expiryDate.currentShortString)
    }
}
