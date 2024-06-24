//
//  ConfigurationScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest

class ConfigurationScreen {
    
    let app: XCUIApplication
    let configurationButton: XCUIElement
    let flashToggleConfig: XCUIElement
    let closeButton: XCUIElement
    let flashButton: XCUIElement
    
    init(app: XCUIApplication) {
        self.app = app
        configurationButton = app.buttons["Gini Bank SDK: (3.7.2) / Gini Capture SDK: (3.7.1) / Client id: gini-android-test"]
        flashToggleConfig = app.switches["Display flash button, Display flash button in camera screen"]
        closeButton = app.buttons["Close"]
        flashButton = app.buttons["Flash Off"]
    }
    
    func tapFlashToggleConfiguration(){
        configurationButton.tap()
        flashToggleConfig.tap()
        closeButton.tap()
      }
    
}
