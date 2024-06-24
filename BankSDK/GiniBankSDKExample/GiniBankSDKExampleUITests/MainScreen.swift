//
//  MainScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest

class MainScreen{
    let app: XCUIApplication
    let photoPaymentButton: XCUIElement
    let skipButton: XCUIElement
    let cancelButton: XCUIElement
    
    init(app: XCUIApplication) {
        self.app = app
        photoPaymentButton = app.buttons["Photopayment"]
        skipButton = app.buttons["Skip"]
        cancelButton = app.buttons["Cancel"]
    }
    
    struct VerifyMessage {
        struct MainScreen {
            static let title = "Welcome to Gini"
            static let subheading = "Example of Photo Payment integration in the banking app" }
        struct ScanSection {
            static let prompt = "Scan invoice or QR code"}
    }
    
    func initiateApp() {
        assertMainScreenTitle()
        if photoPaymentButton.waitForExistence(timeout: 10) {
            photoPaymentButton.tap()
        }
        if app.staticTexts[VerifyMessage.ScanSection.prompt].exists{
            print("User is on Camera Screen")
        }
        else{
            skipButton.tap()
        }
    }
    
    func tapCancelButton() {
        cancelButton.tap()
        assertMainScreenSubHeading()
    }
    
    func assertMainScreenTitle(){
        XCTAssertEqual(app.staticTexts[VerifyMessage.MainScreen.title].label, "Welcome to Gini", "Text mismatch in the label")
    }
    
    func assertMainScreenSubHeading(){
        XCTAssertEqual(app.staticTexts[VerifyMessage.MainScreen.subheading].label, "Example of Photo Payment integration in the banking app", "Text mismatch in the label")

    }
}
