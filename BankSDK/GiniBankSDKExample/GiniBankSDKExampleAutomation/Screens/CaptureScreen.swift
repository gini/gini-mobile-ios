//
//  CaptureScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest

public class CaptureScreen {
    let app: XCUIApplication
    let captureButton: XCUIElement
    let flashONButton: XCUIElement
    let flashOFFButton: XCUIElement
    let filesButton: XCUIElement
    let cameraTitleText: XCUIElement
    let cancelButtonNavigation: XCUIElement
    let helpButton: XCUIElement
    let uploadPhotoButton: XCUIElement
    let uploadFilesButton: XCUIElement
    let cancelButtonInMenu: XCUIElement
    let openGalleryButton: XCUIElement
    
    public init(app: XCUIApplication, locale: String) {
        self.app = app
        
        switch locale {
        case "en":
            captureButton = app.buttons["Take picture"]
            cameraTitleText = app.staticTexts["Scan"]
            cancelButtonNavigation = app.navigationBars.buttons["Cancel"]
            helpButton = app.buttons["Help"]
            flashONButton = app.buttons["Flash On"]
            flashOFFButton = app.buttons["Flash Off"]
            filesButton = app.buttons["Files"]
            uploadPhotoButton = app.buttons["Upload photo"]
            uploadFilesButton = app.buttons["Upload files"]
            openGalleryButton = app.buttons["Open"]
            cancelButtonInMenu = app.buttons.matching(identifier: "Cancel").element(boundBy: 1)
               
        case "de":
            captureButton = app.buttons["Bild aufnehmen"]
            cameraTitleText = app.staticTexts["Aufnahme"]
            cancelButtonNavigation = app.navigationBars.buttons["Abbrechen"]
            helpButton = app.buttons["Hilfe"]
            flashONButton = app.buttons["Blitz an"]
            flashOFFButton = app.buttons["Blitz aus"]
            filesButton = app.buttons["Dateien"]
            uploadPhotoButton = app.buttons["Fotos hochladen"]
            uploadFilesButton = app.buttons["Dokument hochladen"]
            openGalleryButton = app.buttons["Öffnen"]
            cancelButtonInMenu = app.buttons.matching(identifier: "Abbrechen").element(boundBy: 1)
            
        default:
            fatalError("Locale \(locale) is not supported")
        }
    }
    
    public func assertFlashButton(){
        XCTAssertFalse(flashONButton.exists, "Does not exists")
    }
    public func tapCancelButton(){
        cancelButtonNavigation.tap()
    }
    
    public func tapHelpButton(){
        helpButton.tap()
    }
}
