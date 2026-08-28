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
    let productTagSegmentedControl: XCUIElement
    let paymentDueHintSwitch: XCUIElement
    let paymentScheduleHintSwitch: XCUIElement

    init(app: XCUIApplication, locale: String) {
        self.app = app
        closeButton = app.buttons[SettingScreenAccessibilityIdentifiers.closeButton.rawValue]
        qrCodeScanSwitch = app.switches[SettingScreenAccessibilityIdentifiers.qrCodeScanSwitch.rawValue]
        qrCodeScanOnlySwitch = app.switches[SettingScreenAccessibilityIdentifiers.qrCodeScanOnlySwitch.rawValue]
        multiPageSwitch = app.switches[SettingScreenAccessibilityIdentifiers.multiPageSwitch.rawValue]
        flashToggleSwitch = app.switches[SettingScreenAccessibilityIdentifiers.flashToggleSwitch.rawValue]
        onboardingEveryLaunchSwitch = "Onboarding screens at every launch"
        onboardingAtFirstLaunchSwitch = "Onboarding screens at first launch"
        productTagSegmentedControl = app.segmentedControls[SettingScreenAccessibilityIdentifiers.productTagSegmentedControl.rawValue]
        paymentDueHintSwitch = app.switches[SettingScreenAccessibilityIdentifiers.paymentDueHintSwitch.rawValue]
        paymentScheduleHintSwitch = app.switches[SettingScreenAccessibilityIdentifiers.paymentScheduleHintSwitch.rawValue]
    }
    
    public func tapFlashToggleSwitch(){
        flashToggleSwitch.tap()
        closeButton.tap()
    }

    /**
     Disables a `UISwitch` element if it is currently on.

     `UISwitch` elements in XCUITest do not expose their on/off state through `isSelected`
     (which always returns `false` for switches). Instead, the state is read via `.value`,
     which returns `"1"` when the switch is on and `"0"` when it is off.
     - Parameters:
       - switchElement: The `XCUIElement` representing the `UISwitch` to disable.
     */
    public func disableSwitchIfOn(_ switchElement: XCUIElement) {
        if switchElement.value as? String == "1" {
            switchElement.tap()
        }
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
    }

    /**
     Sets `paymentDueHintEnabled` / `paymentScheduleHintEnabled` on
     `GiniBankConfiguration` via the Settings UI. Assumes both switches
     are visible on screen (Settings screen is open, scroll to Feature
     toggles if needed).
     - Parameters:
       - dueDate: desired `paymentDueHintEnabled` value
       - schedule: desired `paymentScheduleHintEnabled` value
     */
    public func setPaymentHintFlags(dueDate: Bool, schedule: Bool) {
        setSwitch(paymentDueHintSwitch, to: dueDate)
        setSwitch(paymentScheduleHintSwitch, to: schedule)
    }

    private func setSwitch(_ switchElement: XCUIElement, to on: Bool) {
        if !switchElement.exists {
            /// Feature-toggles section is far down the Settings list; scroll
            /// until the switch is on screen before tapping.
            app.swipeUp()
        }
        let currentlyOn = switchElement.value as? String == "1"
        if currentlyOn != on {
            switchElement.tap()
        }
    }
}
