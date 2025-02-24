//
//  TransactionDocsScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest

public class TransactionDocsScreen {
    
    let app: XCUIApplication
    let onlyForThisTransaction: XCUIElement
    let dontAttach: XCUIElement
    let alwaysAttach: XCUIElement
    let documentName: XCUIElement
    let editButton: XCUIElement
    let deleteButton: XCUIElement
    let cancelButton: XCUIElement
    let editButtonPreview: XCUIElement
    
    public init(app: XCUIApplication, locale: String) {
        self.app = app
        documentName = app.staticTexts["Tap to view Document"]
        editButton = app.buttons["transactionDocs attached docum"]
        editButtonPreview = app.navigationBars.buttons["transactionDocs attached docum"]

        switch locale {
        case "en":
            onlyForThisTransaction = app.buttons["Only for this transaction"]
            dontAttach = app.buttons["Don't attach"]
            alwaysAttach = app.buttons["Always attach"]
            deleteButton = app.buttons["Delete"]
            cancelButton = app.buttons["Cancel"]
            
        case "de":
            onlyForThisTransaction = app.buttons["Nur für diese Transaktion"]
            dontAttach = app.buttons["Nicht anhängen"]
            alwaysAttach = app.buttons["Immer anhängen"]
            deleteButton = app.buttons["Löschen"]
            cancelButton = app.buttons["Abbrechen"]
        default:
            fatalError("Locale \(locale) is not supported")
        }
    }
    
}
