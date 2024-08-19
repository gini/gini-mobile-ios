//
//  SkontoScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest

public class SkontoScreen {
    
    let app: XCUIApplication
    let skontoTitleText: XCUIElement
    let backButtonNavigation: XCUIElement
    let helpButton: XCUIElement
    let proceedButton: XCUIElement
    let skontoSwitch: XCUIElement
    let finalAmountField: XCUIElement
    let fullAmountField: XCUIElement
    let expiryDateField: XCUIElement
    let eurStaticText: XCUIElement
    let gotItButton: XCUIElement
    let iconImage: XCUIElement
    
    
    public init(app: XCUIApplication, locale: String) {
        self.app = app
        
        switch locale {
        case "en":
            helpButton = app.buttons["Help"]
            proceedButton = app.buttons["Proceed"]
            skontoTitleText = app.buttons["Discount"]
            backButtonNavigation = app.buttons["Back Back"]
            gotItButton = app.buttons["Got it"]
            
        case "de":
            helpButton = app.buttons["Hilfe"]
            proceedButton = app.buttons["Zahlung fortsetzen"]
            skontoTitleText = app.buttons["Skonto"]
            backButtonNavigation = app.buttons["Zurück Zurück"]
            gotItButton = app.buttons["Verstanden"]

        default:
            fatalError("Locale \(locale) is not supported")
        }
        skontoSwitch = app.switches.firstMatch
        finalAmountField = app.textFields.element(boundBy: 2)
        fullAmountField = app.textFields.element(boundBy: 3)
        expiryDateField = app.textFields.element(boundBy: 4)
        eurStaticText = app.staticTexts["EUR"]
        iconImage = app.images["info_message_icon"]

    }
}
