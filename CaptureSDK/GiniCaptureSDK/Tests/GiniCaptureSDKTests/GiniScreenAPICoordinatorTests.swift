//
//  GiniScreenAPICoordinatorTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 3/8/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniCaptureSDK
final class GiniScreenAPICoordinatorTests: XCTestCase {
    
    var coordinator: GiniScreenAPICoordinator!
    let giniConfiguration = GiniConfiguration()
    let delegateMock = GiniCaptureDelegateMock()
    
    override func setUp() {
        super.setUp()
        giniConfiguration.openWithEnabled = true
        giniConfiguration.multipageEnabled = true
        coordinator = GiniScreenAPICoordinator(withDelegate: delegateMock, giniConfiguration: giniConfiguration)
    }
    
    func testNavControllerCountAfterStartWithoutDocuments() {
        let rootViewController = coordinator.start(withDocuments: nil)
        _ = rootViewController.view
        let screenNavigator = rootViewController.children.first as? UINavigationController
        XCTAssertEqual(screenNavigator?.viewControllers.count, 2,
                       "there should be two view controllers in the nav stack, Review and Camera screens")
    }
    
    func testNavControllerTypesAfterStartWithoutDocuments() {
        let rootViewController = coordinator.start(withDocuments: nil)
        _ = rootViewController.view
        let screenNavigator = rootViewController.children.first as? UINavigationController
        XCTAssertNotNil(screenNavigator?.viewControllers.first as? ReviewViewController,
                        "first view controller is not a ReviewViewController")
    }
    
    func testNavControllerCountAfterStartWithImages() {
        let capturedImages = [GiniCaptureTestsHelper.loadImageDocument(named: "invoice"),
                              GiniCaptureTestsHelper.loadImageDocument(named: "invoice2")]

        let rootViewController = coordinator.start(withDocuments: capturedImages)
        _ = rootViewController.view
        let screenNavigator = rootViewController.children.first as? UINavigationController
        XCTAssertEqual(screenNavigator?.viewControllers.count, 1,
                       "there should be 2 view controllers in the nav stack")
    }
    
    func testNavControllerTypesAfterStartWithImages() {
        let document1 = GiniCaptureTestsHelper.loadImageDocument(named: "invoice")
        document1.isImported = false
        let document2 = GiniCaptureTestsHelper.loadImageDocument(named: "invoice2")
        document2.isImported = false
        let capturedImages = [document1, document2]

        let rootViewController = coordinator.start(withDocuments: capturedImages)
        _ = rootViewController.view
        let screenNavigator = rootViewController.children.first as? UINavigationController
        
        XCTAssertNotNil(screenNavigator?.viewControllers.last as? ReviewViewController,
                        "first view controller is not a ReviewViewController")
        XCTAssertEqual(screenNavigator?.viewControllers.count, 1,
                       "there should be only one view controller in the nav stack")
        
    }
    
    func testNavControllerCountAfterStartWithAPDF() {
        let capturedPDFs = [GiniCaptureTestsHelper.loadPDFDocument(named: "testPDF")]

        let rootViewController = coordinator.start(withDocuments: capturedPDFs)
        _ = rootViewController.view
        let screenNavigator = rootViewController.children.first as? UINavigationController
        XCTAssertEqual(screenNavigator?.viewControllers.count, 1,
                       "there should be only one view controller in the nav stack")
    }
    
    func testNavControllerTypesAfterStartWithPDF() {
        let capturedPDFs = [GiniCaptureTestsHelper.loadPDFDocument(named: "testPDF")]

        let rootViewController = coordinator.start(withDocuments: capturedPDFs)
        _ = rootViewController.view
        let screenNavigator = rootViewController.children.first as? UINavigationController
        
        XCTAssertNotNil(screenNavigator?.viewControllers.first as? AnalysisViewController,
                        "first view controller is not a AnalysisViewController")
    }
    
    func testNavControllerTypesAfterStartWithImageAndMultipageDisabled() {
        giniConfiguration.multipageEnabled = false
        let document = GiniCaptureTestsHelper.loadImageDocument(named: "invoice")
        document.isImported = false
        let capturedImages = [document]

        let rootViewController = coordinator.start(withDocuments: capturedImages)
        _ = rootViewController.view
        let screenNavigator = rootViewController.children.first as? UINavigationController
        XCTAssertNotNil(screenNavigator?.viewControllers.last as? ReviewViewController,
                        "first view controller is not a ReviewViewController")
    }

    func testDocumentCollectionAfterRemoveImageInMultipage() {
        let capturedImageDocument = GiniCaptureTestsHelper.loadImagePage(named: "invoice")
        coordinator.addToDocuments(new: [capturedImageDocument])
        
        coordinator.review(coordinator.reviewViewController,
                                    didDelete: coordinator.reviewViewController.pages[0])
        XCTAssertTrue(coordinator.pages.isEmpty,
                      "vision documents collection should be empty after delete " +
            "the image in the multipage review view controller")
    }
    
    func testErrorTypeNoResponse() {
        giniConfiguration.multipageEnabled = false
        let capturedImages = [GiniCaptureTestsHelper.loadImageDocument(named: "invoice")]

        let rootViewController = coordinator.start(withDocuments: capturedImages)
        _ = rootViewController.view
        let errorType = ErrorType(error: .noResponse)
        coordinator.displayError(errorType: errorType, animated: false)
        let screenNavigator = rootViewController.children.first as? UINavigationController
        let errorScreen = screenNavigator?.viewControllers.last as? ErrorScreenViewController
        errorScreen?.setupView()
        XCTAssertNotNil(
            errorScreen,
            "first view controller is not a ErrorScreenViewController")
        XCTAssertTrue(errorScreen?.errorHeader.text == ErrorType.unexpected.title(), "Error title should match no response error type")
        XCTAssertTrue(errorScreen?.errorContent.text == ErrorType.unexpected.content(), "Error content should match no response error type")
        
    }
    
    func testErrorTooManyRequests() {
        giniConfiguration.multipageEnabled = false
        let capturedImages = [GiniCaptureTestsHelper.loadImageDocument(named: "invoice")]

        let rootViewController = coordinator.start(withDocuments: capturedImages)
        _ = rootViewController.view
        let response = HTTPURLResponse(url: URL(string: "example")!, statusCode: 429, httpVersion: "", headerFields: [:])
        let errorType = ErrorType(error: .tooManyRequests(response: response, data: Data()))
        coordinator.displayError(errorType: errorType, animated: false)
        let screenNavigator = rootViewController.children.first as? UINavigationController
        let errorScreen = screenNavigator?.viewControllers.last as? ErrorScreenViewController
        errorScreen?.setupView()
        XCTAssertNotNil(
            errorScreen,
            "first view controller is not a ErrorScreenViewController")
        XCTAssertTrue(errorScreen?.errorHeader.text == ErrorType.request.title(), "Error title should match no response error type")
        XCTAssertTrue(errorScreen?.errorContent.text == ErrorType.request.content(), "Error content should match no response error type")
    }
    
    func testUnauthorizedError() {
        giniConfiguration.multipageEnabled = false
        let capturedImages = [GiniCaptureTestsHelper.loadImageDocument(named: "invoice")]

        let rootViewController = coordinator.start(withDocuments: capturedImages)
        _ = rootViewController.view
        let response = HTTPURLResponse(url: URL(string: "example")!, statusCode: 401, httpVersion: "", headerFields: [:])
        let errorType = ErrorType(error: .unauthorized(response: response, data: Data()))
        coordinator.displayError(errorType: errorType, animated: false)
        let screenNavigator = rootViewController.children.first as? UINavigationController
        let errorScreen = screenNavigator?.viewControllers.last as? ErrorScreenViewController
        errorScreen?.setupView()
        XCTAssertNotNil(
            errorScreen,
            "first view controller is not a ErrorScreenViewController")
        XCTAssertTrue(errorScreen?.errorHeader.text == ErrorType.authentication.title(), "Error title should match unauthorized error type")
        XCTAssertTrue(errorScreen?.errorContent.text == ErrorType.authentication.content(), "Error content should match unauthorized error type")
    }

    func testErrorServerError() {
        giniConfiguration.multipageEnabled = false
        let capturedImages = [GiniCaptureTestsHelper.loadImageDocument(named: "invoice")]

        let rootViewController = coordinator.start(withDocuments: capturedImages)
        _ = rootViewController.view
        let errorType = ErrorType(error: .server(errorCode: 502))
        coordinator.displayError(errorType: errorType, animated: false)
        let screenNavigator = rootViewController.children.first as? UINavigationController
        let errorScreen = screenNavigator?.viewControllers.last as? ErrorScreenViewController
        errorScreen?.setupView()
        XCTAssertNotNil(
            errorScreen,
            "first view controller is not a ErrorScreenViewController")
        XCTAssertTrue(errorScreen?.errorHeader.text == ErrorType.server.title(), "Error title should match server error type")
        XCTAssertTrue(errorScreen?.errorContent.text == ErrorType.server.content(), "Error content should match server error type")
        
    }

    func testMaintenanceError() {
        giniConfiguration.multipageEnabled = false
        let capturedImages = [GiniCaptureTestsHelper.loadImageDocument(named: "invoice")]

        let rootViewController = coordinator.start(withDocuments: capturedImages)
        _ = rootViewController.view
        let errorType = ErrorType(error: .maintenance(errorCode: 503))
        coordinator.displayError(errorType: errorType, animated: false)
        let screenNavigator = rootViewController.children.first as? UINavigationController
        let errorScreen = screenNavigator?.viewControllers.last as? ErrorScreenViewController
        errorScreen?.setupView()
        XCTAssertNotNil(
            errorScreen,
            "first view controller is not a ErrorScreenViewController")
        XCTAssertTrue(errorScreen?.errorHeader.text == ErrorType.maintenance.title(), "Error title should match server error type")
        XCTAssertTrue(errorScreen?.errorContent.text == ErrorType.maintenance.content(), "Error content should match server error type")

    }

    func testOutageError() {
        giniConfiguration.multipageEnabled = false
        let capturedImages = [GiniCaptureTestsHelper.loadImageDocument(named: "invoice")]

        let rootViewController = coordinator.start(withDocuments: capturedImages)
        _ = rootViewController.view
        let errorType = ErrorType(error: .outage(errorCode: 500))
        coordinator.displayError(errorType: errorType, animated: false)
        let screenNavigator = rootViewController.children.first as? UINavigationController
        let errorScreen = screenNavigator?.viewControllers.last as? ErrorScreenViewController
        errorScreen?.setupView()
        XCTAssertNotNil(
            errorScreen,
            "first view controller is not a ErrorScreenViewController")
        XCTAssertTrue(errorScreen?.errorHeader.text == ErrorType.outage.title(), "Error title should match server error type")
        XCTAssertTrue(errorScreen?.errorContent.text == ErrorType.outage.content(), "Error content should match server error type")

    }
}
