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
    let recentsButton: XCUIElement
    let recentsText: XCUIElement
    
    init(app: XCUIApplication, locale: String) {
        self.app = app
        
        switch locale {
        case "en":
            deleteButton = app.buttons["Delete"]
            sendFeedbackButton = app.navigationBars.buttons["Send feedback and close"]
            recentsButton = app.buttons["Recents"].firstMatch
            recentsText = app.staticTexts["Recents"].firstMatch
        case "de":
            deleteButton = app.buttons["Löschen"]
            sendFeedbackButton = app.navigationBars.buttons["Feedback senden und schließen"]
            recentsButton = app.buttons["Verlauf"].firstMatch
            recentsText = app.staticTexts["Verlauf"].firstMatch
        default:
            fatalError("Locale \(locale) is not supported")
        }
        //photoPaymentButton
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
        let _ = springboard.waitForExistence(timeout: 5)
        let allowFullAccess =  springboard.buttons["Allow Full Access"]
        let allowFullAccessDE =  springboard.buttons["Zugriff auf alle Fotos erlauben"]
        let dontAllowButton = springboard.buttons["Don’t Allow"]
        let dontAllowButtonDE = springboard.buttons["Nicht erlauben"]
        let buttonToTap: XCUIElement
        
        if answer {
            buttonToTap = allowFullAccess.exists ? allowFullAccess : allowFullAccessDE
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
        var switchElement = cell.switches.element
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
        sleep(1)

        if recentsButton.exists {
            recentsButton.tap()
        } else if recentsText.exists {
            recentsText.tap()
        }

        var fileElement = app.staticTexts[fileName].firstMatch
        var swipeAttempts = 0

        while !fileElement.exists && swipeAttempts < 4 {
            
            XCUIDevice.shared.orientation = .portrait
            app.swipeUp()
            swipeAttempts += 1
            sleep(1) 
            fileElement = app.staticTexts[fileName].firstMatch
        }

        XCTAssertTrue(fileElement.waitForExistence(timeout: 3),
                      "Please add file with file name '\(fileName)' to the device before launching the test.")
        
        fileElement.tap()
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

