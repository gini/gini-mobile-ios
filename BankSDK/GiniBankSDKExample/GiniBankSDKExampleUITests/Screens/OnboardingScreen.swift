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
    
    init(app: XCUIApplication, locale: String) {
        self.app = app
        
        switch locale {
        case "en":
            nextButton = app.staticTexts["Next"]
            skipButton = app.navigationBars.buttons["Skip"]
            getStartedButton = app.buttons["Get Started"]
        case "de":
            nextButton = app.staticTexts["Weiter"]
            skipButton = app.navigationBars.buttons["Überspringen"]
            getStartedButton = app.buttons["Los geht’s"]
        default:
            fatalError("Locale \(locale) is not supported")
        }
    }
    
    func skipOnboardingScreens() {
        /// waitForExistence instead of bare `exists`: right after launch/permission
        /// alerts the app is still settling, and a single-snapshot `exists` query can
        /// stall ("Timed out while evaluating UI query") or return a premature false
        /// that silently skips the tap.
        if skipButton.waitForExistence(timeout: 5) {
            skipButton.tap()
        }
    }
}
