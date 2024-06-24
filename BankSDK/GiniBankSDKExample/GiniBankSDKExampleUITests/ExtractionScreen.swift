//
//  ExtractionScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest

class ExtractionScreen {
    let app: XCUIApplication
    let feedbackButton: XCUIElement
    
    init(app: XCUIApplication) {
        self.app = app
        feedbackButton = app.buttons["Send feedback and close"]
    }
        
    func tapFeedbackButton() {
        feedbackButton.tap()
    }
}

    
    


