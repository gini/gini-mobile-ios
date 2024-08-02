//
//  CaptureScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest
import GiniCaptureSDK

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
        captureButton = app.buttons[CaptureScreenAccessibilityIdentifiers.captureButton.rawValue]
        flashButton = app.buttons[CaptureScreenAccessibilityIdentifiers.flashButton.rawValue]
        filesUploadButton = app.buttons[CaptureScreenAccessibilityIdentifiers.filesUploadButton.rawValue]
        cameraTitleText = app.buttons[CaptureScreenAccessibilityIdentifiers.cameraTitleText.rawValue]
        cancelButton = app.buttons["Cancel"]
        //cancelButton = app.buttons[CaptureScreenAccessibilityIdentifiers.cancelButton.rawValue]
        helpButton = app.buttons[CaptureScreenAccessibilityIdentifiers.helpButton.rawValue]
        scanTextTitle = app.buttons[CaptureScreenAccessibilityIdentifiers.scanTextTitle.rawValue]
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
