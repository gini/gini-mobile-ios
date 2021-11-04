//
//  GiniPDFDocumentTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 9/14/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniCaptureSDK
final class GiniPDFDocumentTests: XCTestCase {
  
    lazy var pdfNonRotated = GiniCaptureTestsHelper.loadPDFDocument(named: "testPDF")
    
    func testNumberPages() {
        let pdf2Pages = GiniCaptureTestsHelper.loadPDFDocument(named: "testPDF2Pages")
        
        let numberOfPagesPDF1 = pdfNonRotated.numberPages
        let numberOfPagesPDF2 = pdf2Pages.numberPages
        
        XCTAssert(numberOfPagesPDF1 == 1, "Number of pages should be 1 since the pdf only has one page")
        XCTAssert(numberOfPagesPDF2 == 2, "Number of pages should be 2 since the pdf only has two pages")

    }
    
    func testPDFNonRotated() {
        let imageSize = pdfNonRotated.previewImage!.size
        
        XCTAssert(imageSize.height > imageSize.width,
                  "Height must be greater than width since image has not rotationAngle " +
                  "and the pdf is in portrait orientation by default")
    }
    
    func testPDFRotated90() {
        let pdfDocument = GiniCaptureTestsHelper.loadPDFDocument(named: "testPDF-rotated90")
        
        let imageSize = pdfDocument.previewImage!.size
        
        XCTAssert(imageSize.height < imageSize.width,
                  "Height must be less than width since image has a rotationAngle of 90 " +
                  "degrees and the pdf is in portrait orientation by default")
    }
    
    func testPDFRotated180() {
        let pdfDocument = GiniCaptureTestsHelper.loadPDFDocument(named: "testPDF-rotated180")
        
        let imageSize = pdfDocument.previewImage!.size
        
        XCTAssert(imageSize.height > imageSize.width,
                  "Height must be greater than width since image has a rotationAngle of 180 " +
                  "degrees and the pdf is in portrait orientation by default")
    }
    
    func testPDFRotated270() {
        let pdfDocument = GiniCaptureTestsHelper.loadPDFDocument(named: "testPDF-rotated270")
        
        let imageSize = pdfDocument.previewImage!.size
        
        XCTAssert(imageSize.height < imageSize.width,
                  "Height must be less than width since image has a rotationAngle of 270 degrees " +
                  "and the pdf is in portrait orientation by default")
    }
    
}
