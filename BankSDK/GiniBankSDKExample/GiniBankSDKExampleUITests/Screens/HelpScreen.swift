//
//  HelpScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest
import GiniCaptureSDK

public class HelpScreen {
    let app: XCUIApplication
    let cameraBackButton: XCUIElement
    let tipsForBestResultLabel: XCUIElement
    let supportedFormatsLabel: XCUIElement
    let importDocumentsLabel: XCUIElement
    
    public init(app: XCUIApplication) {
        self.app = app
        cameraBackButton = app.buttons[HelpScreenAccessibilityIdentifiers.cameraBackButton.rawValue]
        tipsForBestResultLabel = app.buttons[HelpScreenAccessibilityIdentifiers.tipsForBestResultLabel.rawValue]
        supportedFormatsLabel = app.buttons[HelpScreenAccessibilityIdentifiers.supportedFormatsLabel.rawValue]
        importDocumentsLabel = app.buttons[HelpScreenAccessibilityIdentifiers.importDocumentsLabel.rawValue]
    }
    
    struct VerifyMessage {
        struct HelpScreenMenuItem {
            static let title = "Good lightning"
        }
    }
}
