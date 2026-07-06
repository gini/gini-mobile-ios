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
        editButtonPreview = app.navigationBars.buttons["transactionDocs attached docum"]

        switch locale {
        case "en":
            documentName = app.tables.cells.otherElements["Tap to view Document.png"]
            onlyForThisTransaction = app.buttons["Only for this transaction"]
            dontAttach = app.buttons["Don't attach"]
            alwaysAttach = app.buttons["Always attach"]
            deleteButton = app.buttons["Delete"]
            cancelButton = app.buttons["Cancel"]
            editButton = app.buttons["Options"]
            
        case "de":
            documentName = app.tables.cells.otherElements["Zur Ansicht hier tippen Document.png"]
            onlyForThisTransaction = app.buttons["Nur für diese Transaktion"]
            dontAttach = app.buttons["Nicht anhängen"]
            alwaysAttach = app.buttons["Immer anhängen"]
            deleteButton = app.buttons["Löschen"]
            cancelButton = app.buttons["Abbrechen"]
            editButton = app.buttons["Optionen"]
        default:
            fatalError("Locale \(locale) is not supported")
        }
    }
    
}
