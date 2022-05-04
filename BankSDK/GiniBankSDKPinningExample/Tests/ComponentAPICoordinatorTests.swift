//
//  ComponentAPICoordinatorTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 11/13/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankSDKPinningExample
@testable import GiniCaptureSDK
@testable import GiniBankSDK

final class ComponentAPICoordinatorTests: XCTestCase {
    
    var componentAPICoordinator: ComponentAPICoordinator?

    var documentService = DocumentServiceMock()
    
    func testInitialization() {
        componentAPICoordinator = ComponentAPICoordinator(pages: [],
                                                          configuration: GiniBankConfiguration(),
                                                          documentService: documentService)
        componentAPICoordinator?.start()
        
        XCTAssertNotNil(componentAPICoordinator?.rootViewController, "the root view controller should never be nil")
        XCTAssertTrue(componentAPICoordinator?.childCoordinators.count == 0,
                      "there should not be child coordinators on initialization")
    }
    
    func testInitializationWhenNoDocument() {
        componentAPICoordinator = ComponentAPICoordinator(pages: [],
                                                          configuration: GiniBankConfiguration(),
                                                          documentService: documentService)
        componentAPICoordinator?.start()
        
        XCTAssertNil(componentAPICoordinator?.analysisScreen,
                     "analysis screen should be nil when no document is imported")
        XCTAssertNil(componentAPICoordinator?.reviewScreen,
                     "review screen should be nil when no document is imported")
        XCTAssertNotNil(componentAPICoordinator?.cameraScreen,
                        "camera screen should not be nil when no document is imported")

    }
    
    func testInitializationWhenImageImported() {
        let image = UIImage(named: "tabBarIconHelp")
        let builder = GiniCaptureDocumentBuilder(documentSource: .external)
        let document = builder.build(with: image!.pngData()!)!
        
        componentAPICoordinator = ComponentAPICoordinator(pages: [GiniCapturePage(document: document)],
                                                          configuration: GiniBankConfiguration(),
                                                          documentService: documentService)
        componentAPICoordinator?.start()
        
        XCTAssertNil(componentAPICoordinator?.analysisScreen,
                     "analysis screen should be nil when no document is imported")
        XCTAssertNotNil(componentAPICoordinator?.reviewScreen,
                        "review screen should not be nil when a image is imported")
        XCTAssertNil(componentAPICoordinator?.cameraScreen,
                     "camera screen should be nil when a image is imported")
        
        XCTAssertEqual(componentAPICoordinator?.reviewScreen?.navigationItem.leftBarButtonItem?.title,
                      "Close")
        
    }
    
    func testInitializationWhenPDFImported() {
        let pdfDocument = loadPDFDocument(withName: "testPDF")
        
        componentAPICoordinator = ComponentAPICoordinator(pages: [GiniCapturePage(document: pdfDocument)],
                                                          configuration: GiniBankConfiguration(),
                                                          documentService: documentService)
        componentAPICoordinator?.start()
        
        XCTAssertNotNil(componentAPICoordinator?.analysisScreen,
                        "analysis screen should not be nil when a pdf is imported")
        XCTAssertNil(componentAPICoordinator?.reviewScreen,
                     "review screen should be nil when a pdf is imported")
        XCTAssertNil(componentAPICoordinator?.cameraScreen,
                     "camera screen should be nil when a pdfpdf is imported")
        
        XCTAssertEqual(componentAPICoordinator?.analysisScreen?.navigationItem.leftBarButtonItem?.title,
                       "Close")
    }
    
    fileprivate func loadPDFDocument(withName name: String) -> GiniPDFDocument {
        let path = Bundle.main.url(forResource: name, withExtension: "pdf")
        let data = try? Data(contentsOf: path!)
        let builder = GiniCaptureDocumentBuilder(documentSource: .external)
        return (builder.build(with: data!) as? GiniPDFDocument)!
    }
    
}
