//
//  MainScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest
import GiniCaptureSDK

class MainScreen {
    
    let app: XCUIApplication
    let configurationButton: XCUIElement
    let photoPaymentButton: XCUIElement
    let cameraIconButton: XCUIElement
    let deleteButton: XCUIElement
    let sendFeedbackButton: XCUIElement
    let onMyPhoneButton: XCUIElement
    let onMyPhoneText: XCUIElement
    let browseButton: XCUIElement

    init(app: XCUIApplication, locale: String) {
        self.app = app

        switch locale {
        case "en":
            deleteButton = app.buttons["Delete"]
            sendFeedbackButton = app.navigationBars.buttons["Done"]
            onMyPhoneButton = app.buttons["On My iPhone"].firstMatch
            onMyPhoneText   = app.staticTexts["On My iPhone"].firstMatch
            browseButton    = app.buttons["Browse"].firstMatch
        case "de":
            deleteButton = app.buttons["Löschen"]
            sendFeedbackButton = app.navigationBars.buttons["Done"]
            onMyPhoneButton = app.buttons["Auf meinem iPhone"].firstMatch
            onMyPhoneText   = app.staticTexts["Auf meinem iPhone"].firstMatch
            browseButton    = app.buttons["Durchsuchen"].firstMatch
        default:
            fatalError("Locale \(locale) is not supported")
        }
        
        photoPaymentButton = app.buttons[MainScreenAccessibilityIdentifiers.photoPaymentButton.rawValue]
        cameraIconButton = app.buttons[MainScreenAccessibilityIdentifiers.cameraIconButton.rawValue]
        configurationButton = app.buttons[MainScreenAccessibilityIdentifiers.settingsButton.rawValue]
    }
    
    /*
     This method won't work if identifiers  are accessed outside the function scope in future replace with addUIInterruptionMonitor(withDescription:handler:)
     */
    public func handleCameraPermission(answer: Bool) {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let _ = springboard.waitForExistence(timeout: 5)
        let allowButton = springboard.buttons["Allow"]
        let allowButtonDE = springboard.buttons["OK"]
        let dontAllowButton = springboard.buttons["Don’t Allow"]
        let dontAllowButtonDE = springboard.buttons["Nicht erlauben"]
        let buttonToTap: XCUIElement
        
        if answer {
            buttonToTap = allowButton.exists ? allowButton : allowButtonDE
        } else {
            buttonToTap = dontAllowButton.exists ? dontAllowButton : dontAllowButtonDE
        }
        
        if buttonToTap.exists {
            buttonToTap.tap()
        }
        
//        XCUIDevice.shared.orientation = .landscapeLeft
        
    }

    /*
     This method doesn't work if identifiers outside func
     in future replace with addUIInterruptionMonitor(withDescription:handler:)
     */
    public func handlePhotoPermission(answer: Bool) {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let allowFullAccess = springboard.buttons["Allow Full Access"]
        let allowFullAccessDE = springboard.buttons["Zugriff auf alle Fotos erlauben"]
        let dontAllowButton = springboard.buttons["Don’t Allow"]
        let dontAllowButtonDE = springboard.buttons["Nicht erlauben"]

        let buttonToTap: XCUIElement
        if answer {
            /// Wait for the dialog to actually appear before checking which button is present.
            if allowFullAccess.waitForExistence(timeout: 5) {
                buttonToTap = allowFullAccess
            } else if allowFullAccessDE.waitForExistence(timeout: 1) {
                buttonToTap = allowFullAccessDE
            } else {
                return
            }
        } else {
            buttonToTap = dontAllowButton.exists ? dontAllowButton : dontAllowButtonDE
        }

        if buttonToTap.exists {
            buttonToTap.tap()
        }
    }

    func swipeToElement(element: XCUIElement, direction: String) {
        var swipeCount = 0
        let maxSwipes = 5
        sleep(1) // Pause until all elements loaded
        while !element.isHittable {
            
            if swipeCount >= maxSwipes {
                XCTFail("Failed to find the element after \(maxSwipes) swipes.")
                break
            }

            switch direction.lowercased() {
            case "up":
                app.swipeUp()
            case "down":
                app.swipeDown()
            case "left":
                app.swipeLeft()
            case "right":
                app.swipeRight()
            default:
                XCTFail("Invalid swipe direction. Use 'up', 'down', 'left', or 'right'.")
                return
            }
            
            swipeCount += 1
            sleep(1) // Pause between swipes to allow UI to update
        }
    }

    func handleConfigurationSetting(element: XCUIElement, enabled: Bool) {
        let currentValue = element.value as? String
        if (enabled && currentValue == "0") || (!enabled && currentValue == "1") {
            element.tap()
        }
    }
    
    func tapSwitchNextToTextElement(text: String, enabled: Bool) {
        // Locate the cell containing the specified text element
        let cell = app.cells.containing(.staticText, identifier: text).element
        XCTAssertTrue(cell.exists, "Cell containing text '\(text)' does not exist")
        // Locate the switch within the found cell
        let switchElement = cell.switches.element
        XCTAssertTrue(switchElement.exists, "Switch next to text '\(text)' does not exist")
        // Scroll to switch
        switchElement.tap()
        // Tap the switch
        handleConfigurationSetting(element: switchElement,enabled: enabled)
        
    }
    
    func clearInputField(element: XCUIElement) {

        guard let stringValue = element.value as? String else {
            XCTFail("Tried to clear non string value")
            return
        }
        let lowerRightCorner = element.coordinate(withNormalizedOffset: CGVectorMake(0.9, 0.9))
        lowerRightCorner.press(forDuration: 2)
        
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        element.typeText(deleteString)
        lowerRightCorner.tap()
        element.typeText(deleteString)
    }
    
    func tapFileWithName(fileName: String) {
        // If the picker opened in Recents/grid view, tap Browse to reach the sidebar.
        if browseButton.waitForExistence(timeout: 3) {
            browseButton.tap()
        }

        // Navigate to On My iPhone.
        _ = onMyPhoneButton.waitForExistence(timeout: 5) || onMyPhoneText.waitForExistence(timeout: 5)
        if onMyPhoneButton.exists {
            onMyPhoneButton.tap()
        } else if onMyPhoneText.exists {
            onMyPhoneText.tap()
        }

        // Open the app folder.
        let appFolder = app.staticTexts["GiniBankSDKExample"].firstMatch
        XCTAssertTrue(appFolder.waitForExistence(timeout: 5),
                      "GiniBankSDKExample folder not found. Run scripts/copy_test_fixtures.sh first.")
        appFolder.tap()

        sleep(1)

        // Cells must be tried before staticTexts: tapping a staticText (the filename label)
        // in the Files picker opens a full-screen preview and stays in Files app.
        // Tapping the cell row properly selects the file for the document picker.
        func findFileElement() -> XCUIElement? {
            let byCell = app.cells.matching(NSPredicate(format: "label CONTAINS[c] %@", fileName)).firstMatch
            if byCell.exists { return byCell }

            let byStaticText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", fileName)).firstMatch
            if byStaticText.exists { return byStaticText }

            let byButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", fileName)).firstMatch
            if byButton.exists { return byButton }

            return nil
        }

        var swipeAttempts = 0
        while findFileElement() == nil && swipeAttempts < 5 {
            app.swipeUp()
            swipeAttempts += 1
            sleep(1)
        }

        guard let fileElement = findFileElement() else {
            XCTFail("File '\(fileName)' not found. Run scripts/copy_test_fixtures.sh to copy fixtures to the simulator.")
            return
        }

        fileElement.tap()

        // After selecting a file from a folder in "On My iPhone", the document picker
        // shows an "Open" button in the navigation bar to confirm the selection.
        // Tap it here so callers do not need a separate openGalleryButton.tap() call.
        let openButton = app.buttons["Open"].firstMatch
        let openButtonDE = app.buttons["Öffnen"].firstMatch
        if openButton.waitForExistence(timeout: 3) {
            openButton.tap()
        } else if openButtonDE.waitForExistence(timeout: 1) {
            openButtonDE.tap()
        }
    }
    
    func assertTextIsDisplayedInAnyStaticText(expectedText: String) {
        
        // Get all static text elements
        let staticTexts = app.staticTexts.allElementsBoundByIndex
        // Iterate through all static text elements
        for staticText in staticTexts {
            if let labelValue = staticText.label as String?, labelValue.contains(expectedText) {
                XCTAssertTrue(labelValue.contains(expectedText),
                             "The text '\(expectedText)' was found in static text '\(labelValue)'")
                return // Exit the function as the expected text was found
            }
        }
        // If the text was not found in any static text element
        XCTFail("The text '\(expectedText)' was not found in any static text element.")
    }

}

