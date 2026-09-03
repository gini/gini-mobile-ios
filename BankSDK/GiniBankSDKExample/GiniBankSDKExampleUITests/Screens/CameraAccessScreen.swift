//
//  CameraAccessScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest

class CameraAccessScreen {
    
    let app: XCUIApplication
    let cameraTitleText: XCUIElement
    let cancelButtonNavigation: XCUIElement
    let helpButton: XCUIElement
    let giveAccessButton: XCUIElement
    
   init(app: XCUIApplication, locale: String) {
        self.app = app
        
        switch locale {
        case "en":
            cameraTitleText = app.staticTexts["Scan"]
            cancelButtonNavigation = app.navigationBars.buttons["Cancel"]
            helpButton = app.buttons["Help"]
            giveAccessButton = app.buttons["Give access"]
        case "de":
            cameraTitleText = app.staticTexts["Aufnahme"]
            cancelButtonNavigation = app.navigationBars.buttons["Abbrechen"]
            helpButton = app.buttons["Hilfe"]
            giveAccessButton = app.buttons["Zugriff erlauben"]
        default:
            fatalError("Locale \(locale) is not supported")
        }
    }
}
