//
//  GiniBankSDKExampleUITests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.

import XCTest

final class GiniBankSDKExampleUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    private enum VerifyMessage {
        static let mainScreenIsDisplayed: String = "Welcome to Gini"
        static let scanInvoiceAndQRcode: String = "Scan invoice or QR code"
    }
    
    func testCaptureDocument() {
        let photoPaymentButton = app.buttons["Photopayment"]
        let captureButton = app.buttons["CaptureButton"]
        
        //Assertion with XCTAssertEqual
        XCTAssertEqual(app.staticTexts[VerifyMessage.mainScreenIsDisplayed].label, "Welcome to Gini", "Text mismatch in the label")
        
        if photoPaymentButton.waitForExistence(timeout: 10) {
            app.buttons["Photopayment"].tap()
        }
        
        //Asertions with XCTAssertTrue
        XCTAssertTrue(app.staticTexts[VerifyMessage.scanInvoiceAndQRcode].exists, "Text does not exist")

        captureButton.tap()
        
        /* In iOS simulator, the extraction of the capture image is performed automatically that's why app.buttons["Process"].tap() is not needed */
    }
}
