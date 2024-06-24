//
//  HelpScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest

class HelpScreen {
    let app: XCUIApplication
    let helpButton: XCUIElement
    let helpItemTips: XCUIElement

    
    init(app: XCUIApplication) {
        self.app = app
        helpButton = app.buttons["Help"]
        helpItemTips = app.staticTexts["Tips for best results from photos"]
        
    }
    
    struct VerifyMessage {
        struct HelpScreenMenuItem {
            static let title = "Good lightning"
        }
    }
    
    func tapHelpButtonAndTipsItem() {
        helpButton.tap()
        XCTAssertTrue(helpItemTips.exists, "The label exist")
        let labelValue = helpItemTips.label
        XCTAssertEqual(labelValue, "Tips for best results from photos", "The label's text is incorrect")
        helpItemTips.tap()
        XCTAssertEqual(VerifyMessage.HelpScreenMenuItem.title, "Good lightning", "The label's text is incorrect")
     }
}
    
