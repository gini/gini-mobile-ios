//
//  ReturnAssistantScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest

class ReturnAssistantScreen {
    
    let app: XCUIApplication
    let getStartedButton: XCUIElement
    let digitalInvoiceTitleText: XCUIElement
    let cancelButtonNavigation: XCUIElement
    let helpButton: XCUIElement
    let editButton: XCUIElement
    let nameTextField: XCUIElement
    let priceTextField: XCUIElement
    let quantityTextField: XCUIElement
    let plusButton: XCUIElement
    let minusButton: XCUIElement
    let proceedButton: XCUIElement
    let saveButton: XCUIElement
    var doneKeyboard: XCUIElement
    
    
    init(app: XCUIApplication, locale: String) {
        self.app = app
        switch locale {
        case "en":
            helpButton = app.buttons["Help"]
            getStartedButton = app.staticTexts["Get started"]
            digitalInvoiceTitleText = app.staticTexts["Digital invoice"]
            cancelButtonNavigation = app.navigationBars.buttons["Cancel"]
            editButton = app.buttons["Edit"]
            proceedButton = app.buttons["Confirm and proceed"]
            saveButton = app.buttons["Save"]
            minusButton = app.buttons["Decrease quantity"]
            plusButton = app.buttons["Increase quantity"]
            doneKeyboard = app.buttons["Done"]
            
        case "de":
            helpButton = app.buttons["Hilfe"]
            getStartedButton = app.buttons["Los geht’s"]
            digitalInvoiceTitleText = app.staticTexts["Digitale Rechnung"]
            cancelButtonNavigation = app.navigationBars.buttons["Abbrechen"]
            editButton = app.buttons["Bearbeiten"]
            proceedButton = app.buttons["Bestätigen und weiter"]
            saveButton = app.buttons["Speichern"]
            minusButton = app.buttons["Anzahl verringern"]
            plusButton = app.buttons["Anzahl erhöhen"]
            doneKeyboard = app.buttons["Fertig"]
        default:
            fatalError("Locale \(locale) is not supported")
        }
        nameTextField = app.textFields.element(boundBy: 2)
        priceTextField = app.textFields.element(boundBy: 3)
        quantityTextField = app.textFields.element(boundBy: 4)
        
    }
}
