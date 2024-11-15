//
//  ReviewScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest

class ReviewScreen {
    
    let app: XCUIApplication
    let reviewTitleText: XCUIElement
    let backButtonNavigation: XCUIElement
    let processButton: XCUIElement
    let deleteButton: XCUIElement
    let addPageButton: XCUIElement

    init(app: XCUIApplication, locale: String) {
        self.app = app
        
        switch locale {
        case "en":
            processButton = app.buttons["Process"]
            reviewTitleText = app.buttons["Review"]
            backButtonNavigation = app.navigationBars.buttons["Cancel"]
            deleteButton = app.buttons["Delete page"]
            addPageButton = app.buttons["Add pages"]
            
        case "de":
            processButton = app.buttons["Verarbeiten"]
            reviewTitleText = app.buttons["Übersicht"]
            backButtonNavigation = app.navigationBars.buttons["Abbrechen"]
            deleteButton = app.buttons["Seite löschen"]
            addPageButton = app.buttons["Seiten hinzufügen"]
        default:
            fatalError("Locale \(locale) is not supported")
        }
    }
    
    func waitForElementToBecomeEnabled(_ element: XCUIElement, timeout: TimeInterval = 10) {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "isEnabled == true"), object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)

        if result != .completed {
            XCTFail("\(element) did not become enabled within \(timeout) seconds")
        }
    }

}
