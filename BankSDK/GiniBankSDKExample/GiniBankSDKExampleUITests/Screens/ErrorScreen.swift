//
//  ErrorScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest
import Foundation

class ErrorScreen {
    
    let app: XCUIApplication
    let cancelButton: XCUIElement
    let enterManuallyButton: XCUIElement
    let backToCameraButton: XCUIElement
    let errorTitle: XCUIElement
    let okButton: XCUIElement
    
    init(app: XCUIApplication, locale: String) {
        self.app = app
        
        switch locale {
        case "en":
            cancelButton = app.buttons["Cancel"]
            enterManuallyButton = app.buttons["Enter manually"]
            backToCameraButton = app.buttons["Back to camera"]
            errorTitle = app.staticTexts["Error"]
            okButton = app.buttons["OK"]
        case "de":
            cancelButton = app.buttons["Abbrechen"]
            enterManuallyButton = app.buttons["Manuell ausfüllen"]
            backToCameraButton = app.buttons["Neues Foto"]
            errorTitle = app.staticTexts["Error"]
            okButton = app.buttons["OK"]
        default:
            fatalError("Locale \(locale) is not supported")
        }
    }
}

