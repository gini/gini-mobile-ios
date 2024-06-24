//
//  CaptureScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest

class CaptureScreen {
    let app: XCUIApplication
    let captureButton: XCUIElement
    let processButton: XCUIElement
    
    init(app: XCUIApplication) {
        self.app = app
        captureButton = app.buttons["Take picture"]
        processButton = app.buttons["Process"]
        
    }
    
    func tapCaptureButton(){
        captureButton.tap()
        if processButton.waitForExistence(timeout: 10) {
            processButton.tap()
        }
    }
}
