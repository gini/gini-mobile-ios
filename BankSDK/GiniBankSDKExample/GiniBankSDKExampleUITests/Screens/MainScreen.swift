//
//  MainScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest
import GiniCaptureSDK

public class MainScreen {
    
    let app: XCUIApplication
    let configurationButton: XCUIElement
    let photoPaymentButton: XCUIElement
    let cameraIconButton: XCUIElement
    
    public init(app: XCUIApplication, locale: String) {
        self.app = app
        photoPaymentButton = app.buttons[MainScreenAccessibilityIdentifiers.photoPaymentButton.rawValue]
        cameraIconButton = app.buttons[MainScreenAccessibilityIdentifiers.photoPaymentButton.rawValue]
        configurationButton = app.buttons[MainScreenAccessibilityIdentifiers.metaInformationLabel.rawValue]
    }
    
    struct VerifyMessage {
        struct MainScreen {
            static let title = "Welcome to Gini"
            static let subheading = "Example of Photo Payment integration in the banking app" }
        
    }
    
    public func assertLabelText(identifier: String, expectedText: String, errorMessage: String) {
        let label = app.staticTexts[identifier]
        XCTAssert(label.exists, "Label with identifier \(identifier) does not exist.")
        XCTAssertEqual(label.label, expectedText, errorMessage)
    }
    
    public func assertMainScreenTitle() {
        assertLabelText(identifier: MainScreenAccessibilityIdentifiers.welcomeTextTitle.rawValue,
                        expectedText: VerifyMessage.MainScreen.title,
                        errorMessage: "Text mismatch in the main screen title")
    }
    
    public func assertMainScreenSubHeading() {
        assertLabelText(identifier: MainScreenAccessibilityIdentifiers.descriptionTextTitle.rawValue,
                        expectedText: "Example of Photo Payment integration in the banking app",
                        errorMessage: "Text mismatch in the main screen subheading")
    }
    
    /*
     This method doesn't work if identifiers outside func
     in future replace with addUIInterruptionMonitor(withDescription:handler:)
     */
    public func handleCameraPermission(answer: Bool) {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        springboard.waitForExistence(timeout: 5)
        
        let allowBtn = springboard.buttons["Allow"]
        let allowBtnDE = springboard.buttons["OK"]
        let dontAllowBtn = springboard.buttons["Don’t Allow"]
        let dontAllowBtnDE = springboard.buttons["Nicht erlauben"]
        
            if answer == true {
                if allowBtn.exists {
                    allowBtn.tap()
                } else if allowBtnDE.exists {
                    allowBtnDE.tap()
                }
            } else {
                if dontAllowBtn.exists {
                    dontAllowBtn.tap()
                } else if allowBtnDE.exists {
                    dontAllowBtnDE.tap()
                }
            }
        }

    /*
     This method doesn't work if identifiers outside func
     in future replace with addUIInterruptionMonitor(withDescription:handler:)
     */
    public func handlePhotoPermission(answer: Bool) {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        springboard.waitForExistence(timeout: 5)
        
        let allowFullAccess =  springboard.buttons["Allow Full Access"]
        let allowFullAccessDE =  springboard.buttons["Zugriff auf alle Fotos erlauben"]
        let dontAllowBtn = springboard.buttons["Don’t Allow"]
        let dontAllowBtnDE = springboard.buttons["Nicht erlauben"]
        
            if answer == true {
                if allowFullAccess.exists {
                    allowFullAccess.tap()
                } else if allowFullAccessDE.exists {
                    allowFullAccessDE.tap()
                }
            } else {
                if dontAllowBtn.exists {
                    dontAllowBtn.tap()
                } else if dontAllowBtnDE.exists {
                    dontAllowBtnDE.tap()
                }
            }
        }

    func swipeToElement(element: XCUIElement, direction: String) {
        var swipeCount = 0
        let maxSwipes = 5
        sleep(1) // Add a pause until all elements loaded
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
            sleep(2) // Add a pause between swipes to allow UI to update
        }
    }

    func handleConfigurationSetting(element: XCUIElement, enabled: Bool) {
        let currentValue = element.value as? String
        if enabled == true && currentValue == "0" {
            element.tap()
        } else if enabled == false && currentValue == "1" {
            element.tap()
        }
    }
    
    func tapSwitchNextToTextElement(text: String) {
            // Locate the cell containing the specified text element
            let cell = app.cells.containing(.staticText, identifier: text).element
            XCTAssertTrue(cell.exists, "Cell containing text '\(text)' does not exist")
            // Locate the switch within the found cell
            let switchElement = cell.switches.element
            XCTAssertTrue(switchElement.exists, "Switch next to text '\(text)' does not exist")
            // Tap the switch
            switchElement.tap()
        }
}

