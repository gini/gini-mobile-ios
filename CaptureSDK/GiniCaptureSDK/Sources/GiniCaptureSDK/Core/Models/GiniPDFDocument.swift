//
//  GiniPDFDocument.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 8/31/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import GiniBankAPILibrary
import UIKit
import MobileCoreServices

final public class GiniPDFDocument: NSObject, GiniCaptureDocument {

    static let acceptedPDFTypes: [String] = [kUTTypePDF as String]

    public var type: GiniCaptureDocumentType = .pdf
    public var id: String
    public let data: Data
    public var previewImage: UIImage?
    public var isReviewable: Bool
    public var isImported: Bool
    public var uploadMetadata: Document.UploadMetadata?

    private(set) var numberPages: Int = 0
    private(set) var pdfTitle: String?

    /**
     Initializes a GiniPDFDocument with a preview image (from the first page)

     - Parameter data: PDF data
     - Parameter fileName: PDF file name

     */

    init(data: Data, fileName: String?, uploadMetadata: Document.UploadMetadata? = nil) {
        self.data = data
        self.isReviewable = false
        self.id = UUID().uuidString
        self.isImported = true
        self.uploadMetadata = uploadMetadata
        super.init()

        if let dataProvider = CGDataProvider(data: data as CFData), let pdfDocument = CGPDFDocument(dataProvider) {
            self.numberPages = pdfDocument.numberOfPages
            self.previewImage = renderFirstPage(fromPdf: pdfDocument)

            if let fileName = fileName {
                self.pdfTitle = fileName
            } else {
                self.pdfTitle = getKey("Title", from: pdfDocument)
            }

        }
    }

    fileprivate func getKey(_ key: String, from document: CGPDFDocument) -> String? {
        if let dict = document.info {
            var cfValue: CGPDFStringRef?
            if (CGPDFDictionaryGetString(dict, key, &cfValue)), let value = CGPDFStringCopyTextString(cfValue!) {
                return value as String
            }
        }

        return nil
    }

    fileprivate func renderFirstPage(fromPdf pdf: CGPDFDocument) -> UIImage? {
        var pdfImage: UIImage?
        let pdfDoc = pdf

        if let pdfPage: CGPDFPage = pdfDoc.page(at: 1) {
            let pageRect: CGRect = normalizedRect(forBoxRect: pdfPage.getBoxRect(.cropBox),
                                                 withRotationAngle: pdfPage.rotationAngle)

            // Create context
            UIGraphicsBeginImageContextWithOptions(CGSize(width: pageRect.width,
                                                          height: pageRect.height), false, 0.0)
            let context: CGContext = UIGraphicsGetCurrentContext()!

            // Fill context color
            context.setFillColor(UIColor.white.cgColor)
            context.fill(pageRect)

            // Align PDF's cropBox to the context
            context.translateBy(x: 0, y: pageRect.size.height)
            context.scaleBy(x: 1, y: -1)
            context.concatenate(pdfPage.getDrawingTransform(.cropBox,
                                                            rect: pageRect,
                                                            rotate: 0,
                                                            preserveAspectRatio: true))

            // Draw PDF into context
            context.drawPDFPage(pdfPage)

            pdfImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }

        return pdfImage
    }

    fileprivate func normalizedRect(forBoxRect rect: CGRect,
                                    withRotationAngle rotationAngle: Int32) -> CGRect {
        var rect = rect

        // In case that the image was rotated 90 or 270, final rect should be rotated to portrait
        if rotationAngle == 90 || rotationAngle == 270 {
            let tempWidth = rect.size.width
            rect.size.width = rect.size.height
            rect.size.height = tempWidth
        }

        return rect
    }
}

// MARK: NSItemProviderReading

extension GiniPDFDocument: NSItemProviderReading {

    static public var readableTypeIdentifiersForItemProvider: [String] {
        return [kUTTypePDF as String]
    }

    static public func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        return self.init(data: data, fileName: nil)
    }

}
