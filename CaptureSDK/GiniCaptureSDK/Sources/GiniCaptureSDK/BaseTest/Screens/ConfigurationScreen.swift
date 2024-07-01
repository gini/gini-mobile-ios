//
//  ConfigurationScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest

public class ConfigurationScreen {
    
    let app: XCUIApplication
    let closeButton: XCUIElement
    let qrCodeScanSwitch: XCUIElement
    let qrCodeScanOnlySwitch: XCUIElement
    let multiPageSwitch: XCUIElement
    let flashToggleSwitch: XCUIElement
    
    public init(app: XCUIApplication) {
        self.app = app
        closeButton = app.buttons[ConfigurationScreenAccessibilityIdentifier.closeButton.rawValue]
        qrCodeScanSwitch = app.buttons[ConfigurationScreenAccessibilityIdentifier.qrCodeScanSwitch.rawValue]
        qrCodeScanOnlySwitch = app.buttons[ConfigurationScreenAccessibilityIdentifier.qrCodeScanOnlySwitch.rawValue]
        multiPageSwitch = app.buttons[ConfigurationScreenAccessibilityIdentifier.multiPageSwitch.rawValue]
        flashToggleSwitch = app.switches[ConfigurationScreenAccessibilityIdentifier.flashToggleSwitch.rawValue]
      
    }
    
    public func tapFlashToggleSwitch(){
        flashToggleSwitch.tap()
        closeButton.tap()
      }
    
}
