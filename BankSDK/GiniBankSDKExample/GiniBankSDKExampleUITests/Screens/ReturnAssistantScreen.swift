//
//  ReturnAssistantScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest

public class ReturnAssistantScreen {
    
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
    
    
    public init(app: XCUIApplication, locale: String) {
        self.app = app
        switch locale {
        case "en":
            helpButton = app.buttons["Help"]
            getStartedButton = app.staticTexts["Get started"]
            digitalInvoiceTitleText = app.staticTexts["Digital invoice"]
            cancelButtonNavigation = app.navigationBars.buttons["Cancel"]
            editButton = app.buttons["Edit"]
            proceedButton = app.buttons["Proceed"]
            saveButton = app.buttons["Save"]
            
        case "de":
            helpButton = app.buttons["Hilfe"]
            getStartedButton = app.staticTexts["Los geht’s"]
            digitalInvoiceTitleText = app.staticTexts["Digitale Rechnung"]
            cancelButtonNavigation = app.navigationBars.buttons["Abbrechen"]
            editButton = app.buttons["Bearbeiten"]
            proceedButton = app.buttons["Weiter"]
            saveButton = app.buttons["Speichern"]
        default:
            fatalError("Locale \(locale) is not supported")
        }
        nameTextField = app.textFields.element(boundBy: 2)
        priceTextField = app.textFields.element(boundBy: 3)
        quantityTextField = app.textFields.element(boundBy: 4)
        minusButton = app.buttons["quantity minus icon"]
        plusButton = app.buttons["quantity plus icon"]
    }
}
