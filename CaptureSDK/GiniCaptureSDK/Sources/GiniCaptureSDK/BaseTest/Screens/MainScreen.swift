//
//  MainScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest

public class MainScreen {
    let app: XCUIApplication
    let photoPaymentButton: XCUIElement
    let cameraIconButton: XCUIElement
    let configurationButton: XCUIElement
    
    public init(app: XCUIApplication) {
        self.app = app
        photoPaymentButton = app.buttons[MainScreenAccessibilityIdentifier.photoPaymentButton.rawValue]
        cameraIconButton = app.buttons[MainScreenAccessibilityIdentifier.photoPaymentButton.rawValue]
        configurationButton = app.buttons[MainScreenAccessibilityIdentifier.metaInformationLabel.rawValue]
    }
    
    struct VerifyMessage {
        struct MainScreen {
            static let title = "Welcome to Gini"
            static let subheading = "Example of Photo Payment integration in the banking app" }
        
    }
    
    public func assertLabelText(identifier: String, expectedText: String, errorMessage: String) {
        let label = app.staticTexts[identifier]
        XCTAssert(label.exists, "Label with identifier \(identifier) does not exist.")
        XCTAssertEqual(label.label, expectedText, errorMessage)
    }
    
    public func assertMainScreenTitle() {
        assertLabelText(identifier: MainScreenAccessibilityIdentifier.welcomeTextTitle.rawValue,
                        expectedText: VerifyMessage.MainScreen.title,
                        errorMessage: "Text mismatch in the main screen title")
    }
    
    public func assertMainScreenSubHeading() {
        assertLabelText(identifier: MainScreenAccessibilityIdentifier.descriptionTextTitle.rawValue,
                        expectedText: "Example of Photo Payment integration in the banking app",
                        errorMessage: "Text mismatch in the main screen subheading")
    }
    
    public func tapPhotoPaymentButton() {
        let captureScreen = CaptureScreen(app: app)
        if photoPaymentButton.waitForExistence(timeout: 10) {
            photoPaymentButton.tap()
            captureScreen.tapCancelButton()
        }
    }
    
    public func tapCameraIconButton() {
        let captureScreen = CaptureScreen(app: app)
        cameraIconButton.tap()
        captureScreen.tapCancelButton()
    }
    
    public func tapConfigurationButton() {
        configurationButton.tap()
    }
}
