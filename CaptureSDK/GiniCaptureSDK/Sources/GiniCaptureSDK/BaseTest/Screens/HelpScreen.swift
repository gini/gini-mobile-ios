//
//  HelpScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest

public class HelpScreen {
    let app: XCUIApplication
    let cameraBackButton: XCUIElement
    let tipsForBestResultLabel: XCUIElement
    let supportedFormatsLabel: XCUIElement
    let importDocumentsLabel: XCUIElement
    
    public init(app: XCUIApplication) {
        self.app = app
        cameraBackButton = app.buttons[HelpScreenAccessibilityIdentifier.cameraBackButton.rawValue]
        tipsForBestResultLabel = app.buttons[HelpScreenAccessibilityIdentifier.tipsForBestResultLabel.rawValue]
        supportedFormatsLabel = app.buttons[HelpScreenAccessibilityIdentifier.supportedFormatsLabel.rawValue]
        importDocumentsLabel = app.buttons[HelpScreenAccessibilityIdentifier.importDocumentsLabel.rawValue]
    }
    
    struct VerifyMessage {
        struct HelpScreenMenuItem {
            static let title = "Good lightning"
        }
    }
}
