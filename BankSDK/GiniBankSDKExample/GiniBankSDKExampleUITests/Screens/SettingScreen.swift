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
    let productTagSegmentedControl: XCUIElement
    
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
        productTagSegmentedControl = app.segmentedControls[SettingScreenAccessibilityIdentifiers.productTagSegmentedControl.rawValue]
    }
    
    public func tapFlashToggleSwitch(){
        flashToggleSwitch.tap()
        closeButton.tap()
    }

    /**
     Selects a segment of the Product Tag control and closes Settings.
     - Parameters:
       - index: 0 = SEPA, 1 = Cross-border, 2 = Auto-detect
     */
    public func selectProductTag(index: Int) {
        let segment = productTagSegmentedControl.buttons.element(boundBy: index)
        if segment.isHittable {
            segment.tap()
        }
        closeButton.tap()
    }
}
