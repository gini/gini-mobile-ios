//
//  HelpScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest
import GiniCaptureSDK

class HelpScreen {
    let app: XCUIApplication
    let cameraBackButton: XCUIElement
    let tipsForBestResultLabel: XCUIElement
    let supportedFormatsLabel: XCUIElement
    let importDocumentsLabel: XCUIElement
    let helpBackButton: XCUIElement
    
    init(app: XCUIApplication, locale: String) {
        self.app = app
        switch locale {
        case "en":
            cameraBackButton = app.buttons["Camera Back"]
            tipsForBestResultLabel = app.staticTexts["Tips for best results from photos"]
            supportedFormatsLabel = app.staticTexts["Supported formats"]
            importDocumentsLabel = app.staticTexts["Import documents from other apps"]
            helpBackButton = app.buttons["Help Back"]
        case "de":
            cameraBackButton = app.buttons["Kamera Zurück"]
            tipsForBestResultLabel = app.staticTexts["Tipps für bessere Ergebnisse"]
            supportedFormatsLabel = app.staticTexts["Unterstützte Formate"]
            importDocumentsLabel = app.staticTexts["Dokumente von anderen Apps importieren"]
            helpBackButton = app.buttons["Hilfe Zurück"]
        default:
            fatalError("Locale \(locale) is not supported")
        }
    }
}
