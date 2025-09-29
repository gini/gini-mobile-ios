//
//  GiniCaptureDocumentValidatorTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 4/13/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
import PDFKit
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
