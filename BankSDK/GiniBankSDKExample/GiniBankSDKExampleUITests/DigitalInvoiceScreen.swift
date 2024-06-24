//
//  DigitalInvoiceScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest

class DigitalInvoiceScreen {
    let app: XCUIApplication
    let getStartedButton: XCUIElement
    let proceedButton: XCUIElement
    let editButton: XCUIElement
    
    
    init(app: XCUIApplication) {
        self.app = app
        proceedButton = app.buttons["Proceed"]
        editButton = app.buttons["Edit"]
        getStartedButton = app.buttons["Get started"]
        
    }
    
    struct VerifyMessage {
        struct DigitalOnboardingScreen {
            static let title = "Digital invoice"
            static let subheading = "Deselect the products you want to return and we will recalculate the price for you."
        }
    }
    
    
    func tapProceedButton() {
        print("User is on Digital Invoice Screen")
        assertDigitalOnboardingSubHeading()
        XCTAssertTrue(getStartedButton.isHittable, "The button should be hittable")
        getStartedButton.tap()
        proceedButton.tap()
    }
    
    func tapEditButton() {
        editButton.tap()
    }
    
    func assertDigitalOnboardingSubHeading(){
        XCTAssertEqual(app.staticTexts[VerifyMessage.DigitalOnboardingScreen.subheading].label, "Deselect the products you want to return and we will recalculate the price for you.", "Text mismatch in the label")
    }

}
