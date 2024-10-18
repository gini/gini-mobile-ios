//
//  ConfigurationScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest

class SettingScreen {
    
    let app: XCUIApplication
    let closeButton: XCUIElement
    let qrCodeScanSwitch: XCUIElement
    let qrCodeScanOnlySwitch: XCUIElement
    let multiPageSwitch: XCUIElement
    let flashToggleSwitch: XCUIElement
    let onboardingEveryLaunchSwitch: String
    let onboardingAtFirstLaunchSwitch: String
    let bottomNavBar: String
    let onboardingCustomBottomNavBar: String
    
    init(app: XCUIApplication, locale: String) {
        self.app = app
        closeButton = app.buttons["Close"]
        qrCodeScanSwitch = app.buttons[SettingScreenAccessibilityIdentifiers.qrCodeScanSwitch.rawValue]
        qrCodeScanOnlySwitch = app.buttons[SettingScreenAccessibilityIdentifiers.qrCodeScanOnlySwitch.rawValue]
        multiPageSwitch = app.buttons[SettingScreenAccessibilityIdentifiers.multiPageSwitch.rawValue]
        flashToggleSwitch = app.switches[SettingScreenAccessibilityIdentifiers.flashToggleSwitch.rawValue]
        onboardingEveryLaunchSwitch = "Onboarding screens at every launch"
        onboardingAtFirstLaunchSwitch = "Onboarding screens at first launch"
        bottomNavBar = "Bottom navigation bar"
        onboardingCustomBottomNavBar = "Onboarding custom bottom navigation bar"
    }
    
    public func tapFlashToggleSwitch(){
        flashToggleSwitch.tap()
        closeButton.tap()
      }
}
