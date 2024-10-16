//
//  OnboardingScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest

class OnboardingScreen {

    let app: XCUIApplication
    let nextButton: XCUIElement
    let skipButton: XCUIElement
    let getStartedButton: XCUIElement
    let nextButtonCustom: XCUIElement
    
    init(app: XCUIApplication, locale: String) {
        self.app = app
        
        switch locale {
        case "en":
            nextButton = app.staticTexts["Next"]
            skipButton = app.navigationBars.buttons["Skip"]
            getStartedButton = app.buttons["Get Started"]
        case "de":
            nextButton = app.staticTexts["Weiter"]
            skipButton = app.buttons["Überspringen"]
            getStartedButton = app.buttons["Los geht’s"]
        default:
            fatalError("Locale \(locale) is not supported")
        }
        
        nextButtonCustom = app.buttons[">"]
    }
    
    func skipOnboardingScreens() {
        if skipButton.exists {
            skipButton.tap()
        }
    }
}
