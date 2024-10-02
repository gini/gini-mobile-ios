//
//  ConfigurationScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest

public class SettingScreen {
    
    let app: XCUIApplication
    let closeButton: XCUIElement
    let qrCodeScanSwitch: XCUIElement
    let qrCodeScanOnlySwitch: XCUIElement
    let multiPageSwitch: XCUIElement
    let flashToggleSwitch: XCUIElement
    let onboardingEveryLaunchSwitch: XCUIElement
    let onboardingAtFirstLaunchSwitch: XCUIElement
    let bottomNavBar: XCUIElement
    let onboardingCustomBottomNavBar: XCUIElement
    
    public init(app: XCUIApplication, locale: String) {
        self.app = app
        closeButton = app.buttons["Close"]
        qrCodeScanSwitch = app.buttons[SettingScreenAccessibilityIdentifiers.qrCodeScanSwitch.rawValue]
        qrCodeScanOnlySwitch = app.buttons[SettingScreenAccessibilityIdentifiers.qrCodeScanOnlySwitch.rawValue]
        multiPageSwitch = app.buttons[SettingScreenAccessibilityIdentifiers.multiPageSwitch.rawValue]
        flashToggleSwitch = app.switches[SettingScreenAccessibilityIdentifiers.flashToggleSwitch.rawValue]
        onboardingEveryLaunchSwitch = app.switches["Onboarding screens at every launch"]
        onboardingAtFirstLaunchSwitch = app.switches["Onboarding screens at first launch, Overwrites `Onboarding screens at every launch` for the first launch."]
        bottomNavBar = app.switches["Bottom navigation bar"]
        onboardingCustomBottomNavBar = app.switches["Onboarding custom bottom navigation bar, The custom bottom navigation bar is shown if `Bottom navigation bar` is also enabled."]
    }
    
    public func tapFlashToggleSwitch(){
        flashToggleSwitch.tap()
        closeButton.tap()
      }
}
