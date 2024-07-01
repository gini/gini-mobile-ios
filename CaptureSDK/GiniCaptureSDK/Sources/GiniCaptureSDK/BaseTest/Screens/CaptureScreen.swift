//
//  CaptureScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest

public class CaptureScreen {
    let app: XCUIApplication
    let captureButton: XCUIElement
    let flashButton: XCUIElement
    let filesUploadButton: XCUIElement
    let cameraTitleText: XCUIElement
    let cancelButton: XCUIElement
    let helpButton: XCUIElement
    let scanTextTitle: XCUIElement
    
    public init(app: XCUIApplication) {
        self.app = app
        captureButton = app.buttons[CaptureScreenAccessibilityIdentifier.captureButton.rawValue]
        flashButton = app.buttons[CaptureScreenAccessibilityIdentifier.flashButton.rawValue]
        filesUploadButton = app.buttons[CaptureScreenAccessibilityIdentifier.filesUploadButton.rawValue]
        cameraTitleText = app.buttons[CaptureScreenAccessibilityIdentifier.cameraTitleText.rawValue]
        cancelButton = app.buttons["Cancel"]
        //cancelButton = app.buttons[CaptureScreenAccessibilityIdentifier.cancelButton.rawValue]
        helpButton = app.buttons[CaptureScreenAccessibilityIdentifier.helpButton.rawValue]
        scanTextTitle = app.buttons[CaptureScreenAccessibilityIdentifier.scanTextTitle.rawValue]
    }
    
    public func assertFlashButton(){
        XCTAssertFalse(flashButton.exists, "Does not exists")
    }
    public func tapCancelButton(){
        cancelButton.tap()
    }
    
    public func tapHelpButton(){
        helpButton.tap()
    }
}
