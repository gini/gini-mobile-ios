//
//  ConfigurationScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest
import GiniCaptureSDK

public class SettingScreen {
    
    let app: XCUIApplication
    let closeButton: XCUIElement
    let qrCodeScanSwitch: XCUIElement
    let qrCodeScanOnlySwitch: XCUIElement
    let multiPageSwitch: XCUIElement
    let flashToggleSwitch: XCUIElement
    
    public init(app: XCUIApplication) {
        self.app = app
        closeButton = app.buttons[SettingScreenAccessibilityIdentifiers.closeButton.rawValue]
        qrCodeScanSwitch = app.buttons[SettingScreenAccessibilityIdentifiers.qrCodeScanSwitch.rawValue]
        qrCodeScanOnlySwitch = app.buttons[SettingScreenAccessibilityIdentifiers.qrCodeScanOnlySwitch.rawValue]
        multiPageSwitch = app.buttons[SettingScreenAccessibilityIdentifiers.multiPageSwitch.rawValue]
        flashToggleSwitch = app.switches[SettingScreenAccessibilityIdentifiers.flashToggleSwitch.rawValue]

    }
    
    public func tapFlashToggleSwitch(){
        flashToggleSwitch.tap()
        closeButton.tap()
      }
}
