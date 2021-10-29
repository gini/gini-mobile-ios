//
//  GiniCaptureDocumentValidatorTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 4/13/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniCaptureSDK
final class GiniCaptureDocumentValidatorTests: XCTestCase {
    
    let giniConfiguration = GiniConfiguration()
    
    func testExcedeedMaxFileSize() {
        let higherThan10MBData = generateFakeData(megaBytes: 12)
        
        let pdfDocument = GiniPDFDocument(data: higherThan10MBData)
        
        XCTAssertThrowsError(try GiniCaptureDocumentValidator.validate(pdfDocument,
                                                                      withConfig: giniConfiguration),
                             "Files with a size lower than 10MB should be valid") { error in
                                XCTAssert(error as? DocumentValidationError == .exceededMaxFileSize,
                                          "should indicate that max file size has been exceeded")
        }
    }
    
    func testNotExcedeedMaxFileSize() {
        let lowerThanOrEqualTo10MBData = generateFakeData(megaBytes: 10)
        
        let pdfDocument = GiniPDFDocument(data: lowerThanOrEqualTo10MBData)
        
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
        let pdfDocument = GiniPDFDocument(data: Data(count: 0))

        XCTAssertThrowsError(try GiniCaptureDocumentValidator.validate(pdfDocument,
                                                                      withConfig: giniConfiguration),
                             "Empty files should not be valid") { error in
                                XCTAssert(error as? DocumentValidationError == .fileFormatNotValid,
                                          "should indicate that the file format is invalid")
        }
    }
    
    fileprivate func generateFakeData(megaBytes lengthInMB: Int) -> Data {
        let length = lengthInMB * 1000000
        return Data(count: length)
    }
    
}
