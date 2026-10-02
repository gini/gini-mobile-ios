//
//  GiniCaptureDocumentValidatorTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 4/13/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
import PDFKit
import Testing
import UIKit
@testable import GiniCaptureSDK
final class GiniCaptureDocumentValidatorTests: XCTestCase {

    let giniConfiguration = GiniConfiguration()

    func testExcedeedMaxFileSize() {
        let higherThan10MBData = generateFakeData(megaBytes: 12)

        let pdfDocument = GiniPDFDocument(data: higherThan10MBData, fileName: nil)

        XCTAssertThrowsError(try GiniCaptureDocumentValidator.validate(pdfDocument,
                                                                      withConfig: giniConfiguration),
                             "Files with a size lower than 10MB should be valid") { error in
                                XCTAssert(error as? DocumentValidationError == .exceededMaxFileSize,
                                          "should indicate that max file size has been exceeded")
        }
    }

    func testNotExcedeedMaxFileSize() {
        let lowerThanOrEqualTo10MBData = generateFakeData(megaBytes: 10)

        let pdfDocument = GiniPDFDocument(data: lowerThanOrEqualTo10MBData, fileName: nil)

        XCTAssertThrowsError(try GiniCaptureDocumentValidator.validate(pdfDocument,
                                                                      withConfig: giniConfiguration),
                             "Files with a size greater than 10MB should not be valid") { error in
                                XCTAssert(error as? DocumentValidationError != .exceededMaxFileSize,
                                          "should indicate that max file size has been exceeded")
        }
    }

    func testImageValidation() {
        let image = GiniCaptureTestsHelper.loadImage(named: "invoice")
        let imageDocument = GiniImageDocument(data: image.jpegData(compressionQuality: 0.2)!, imageSource: .camera)

        XCTAssertNoThrow(try GiniCaptureDocumentValidator.validate(imageDocument,
                                                                  withConfig: giniConfiguration),
                         "Valid images should validate without throwing an exception")
    }

    func testEmptyFileValidation() {
        let pdfDocument = GiniPDFDocument(data: Data(count: 0), fileName: nil)

        XCTAssertThrowsError(try GiniCaptureDocumentValidator.validate(pdfDocument,
                                                                      withConfig: giniConfiguration),
                             "Empty files should not be valid") { error in
                                XCTAssert(error as? DocumentValidationError == .fileFormatNotValid,
                                          "should indicate that the file format is invalid")
        }
    }

    func testProtectedPdfFileSize() {
        let pdfData = generateSamplePDF()
        guard let documentDirectory = try? FileManager.default.url(for: .documentDirectory,
                                                                   in: .userDomainMask,
                                                                   appropriateFor: nil,
                                                                   create:false
        ) else {
            XCTFail("Could not access document directory")
            return
        }

        let encryptedFileURL = documentDirectory.appendingPathComponent("encrypted_pdf_file")
        if let pdfDocument = PDFDocument(data: pdfData) {
            // write with password protection
            pdfDocument.write(
                to: encryptedFileURL,
                withOptions: [
                    PDFDocumentWriteOption.userPasswordOption : "pwd",
                    PDFDocumentWriteOption.ownerPasswordOption : "pwd"
                ])
            // get encrypted pdf
            guard let encryptedPDFDoc = PDFDocument(url: encryptedFileURL) else {
                return
            }

            XCTAssert(encryptedPDFDoc.isEncrypted == true)
            XCTAssert(encryptedPDFDoc.isLocked == true)

            if let data = try? Data(contentsOf: encryptedFileURL) {
                let pdfDocument = GiniPDFDocument(data: data, fileName: nil)
                XCTAssertThrowsError(
                    try GiniCaptureDocumentValidator.validate(
                        pdfDocument,
                        withConfig: giniConfiguration
                    ),
                    "Password protected files should not be valid") { error in
                        XCTAssert(
                            error as? DocumentValidationError == .pdfPasswordProtected,
                            "should indicate that the file  is protected")
                    }
            }
        }
    }

    fileprivate func generateFakeData(megaBytes lengthInMB: Int) -> Data {
        let length = lengthInMB * 1000000
        return Data(count: length)
    }

    fileprivate func generateSamplePDF() -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "Test Builder",
            kCGPDFContextAuthor: "Gini"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let data = renderer.pdfData { (context) in
        context.beginPage()
        let attributes = [
          NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 72)
        ]
        let text = "I'm a PDF!"
        text.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
        }

        return data
    }

}

// MARK: - Swift Testing coverage for format & page-count guards

@Suite("GiniCaptureDocumentValidator format & page-count guards")
struct GiniCaptureDocumentValidatorSwiftTests {

    private let giniConfiguration = GiniConfiguration()

    /// Renders an in-memory PDF with the requested number of blank pages.
    private func renderPDF(pageCount: Int) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 8.5 * 72.0, height: 11 * 72.0)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        return renderer.pdfData { context in
            for _ in 0..<pageCount {
                context.beginPage()
            }
        }
    }

    /// Builds a minimal WebP-signature payload. The SDK's `Data.mimeType` sniffer maps the
    /// first byte `0x52` (`R`, RIFF magic) to `image/webp`, whose UTI conforms to
    /// `kUTTypeImage` — so `isImage` returns true and the validator advances past the first
    /// guard. `isJPEG`/`isPNG`/`isGIF`/`isTIFF` all return false, which trips the second
    /// (format-specific) guard.
    private func makeWebPSignatureData() -> Data {
        var bytes: [UInt8] = []

        /// RIFF container header — file size field left as a placeholder (0), which is fine
        /// for the mimeType/UTI sniff we exercise here.
        bytes.append(contentsOf: [0x52, 0x49, 0x46, 0x46]) // "RIFF"
        bytes.append(contentsOf: [0x00, 0x00, 0x00, 0x00]) // placeholder size
        bytes.append(contentsOf: [0x57, 0x45, 0x42, 0x50]) // "WEBP"
        bytes.append(contentsOf: [0x56, 0x50, 0x38, 0x20]) // "VP8 " chunk id
        bytes.append(contentsOf: [0x00, 0x00, 0x00, 0x00]) // placeholder chunk size

        return Data(bytes)
    }

    @Test("PDF with 11 pages throws .pdfPageLengthExceeded")
    func testPdfExceedingMaxPagesFails() throws {
        let pdfData = renderPDF(pageCount: 11)
        let document = GiniPDFDocument(data: pdfData, fileName: nil)

        #expect(throws: DocumentValidationError.pdfPageLengthExceeded) {
            try GiniCaptureDocumentValidator.validate(document,
                                                     withConfig: giniConfiguration)
        }
    }

    @Test("PDF wrapper around JPEG bytes throws .fileFormatNotValid")
    func testNonPdfDataInPdfWrapperFails() throws {
        let image = GiniCaptureTestsHelper.loadImage(named: "invoice")
        let jpegData = try #require(image.jpegData(compressionQuality: 0.2))
        let document = GiniPDFDocument(data: jpegData, fileName: nil)

        #expect(throws: DocumentValidationError.fileFormatNotValid) {
            try GiniCaptureDocumentValidator.validate(document,
                                                     withConfig: giniConfiguration)
        }
    }

    @Test("Image wrapper around WebP-signature bytes throws .imageFormatNotValid")
    func testUnsupportedImageFormatFails() throws {
        let webpData = makeWebPSignatureData()
        let document = GiniImageDocument(data: webpData, imageSource: .external)

        /// Sanity check: the payload must satisfy the generic image guard first,
        /// so the validator reaches the second (format-specific) branch.
        #expect(webpData.isImage)
        #expect(!webpData.isJPEG)
        #expect(!webpData.isPNG)
        #expect(!webpData.isGIF)
        #expect(!webpData.isTIFF)

        #expect(throws: DocumentValidationError.imageFormatNotValid) {
            try GiniCaptureDocumentValidator.validate(document,
                                                     withConfig: giniConfiguration)
        }
    }
}
