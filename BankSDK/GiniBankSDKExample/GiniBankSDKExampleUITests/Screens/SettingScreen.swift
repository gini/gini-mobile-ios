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
    /**
     Row title of the credit note hint feature toggle — the example-app settings UI
     is English-only, so no locale switch is needed. The switch itself carries no
     accessibility identifier yet, so it is located through its cell text.
     */
    let creditNoteHintCellText = "Credit note hint feature"


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
     Scrolls the settings list until the cell containing the given text exists.
     Table view cells outside the visible area do not exist for XCUITest queries,
     so the list must be swiped until the target row is on screen.
     - Parameters:
       - text: The static text inside the target cell.
     - Returns: The switch element inside the found cell.
     */
    public func switchInCell(containing text: String) -> XCUIElement {
        // Wait for the settings screen to finish presenting before scrolling.
        XCTAssertTrue(closeButton.waitForExistence(timeout: 5), "Settings screen did not appear")
        let cell = app.cells.containing(.staticText, identifier: text).firstMatch
        var swipeCount = 0
        while !cell.exists && swipeCount < 8 {
            app.swipeUp()
            swipeCount += 1
        }
        XCTAssertTrue(cell.waitForExistence(timeout: 3), "Cell containing text '\(text)' not found in Settings")
        let switchElement = cell.switches.firstMatch
        XCTAssertTrue(switchElement.waitForExistence(timeout: 3),
                      "Switch in the cell containing text '\(text)' not found in Settings")
        return switchElement
    }

    /**
     Sets a settings switch located by its cell text to the requested state.
     - Parameters:
       - text: The static text inside the cell containing the switch.
       - enabled: Desired switch state.
     */
    public func setSwitch(nextTo text: String,
                          enabled: Bool) {
        let switchElement = switchInCell(containing: text)
        let currentValue = switchElement.value as? String
        if (enabled && currentValue == "0") || (!enabled && currentValue == "1") {
            switchElement.tap()
        }
        XCTAssertEqual(switchElement.value as? String, enabled ? "1" : "0",
                       "Switch next to '\(text)' did not reach state \(enabled).")
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
     Sets `paymentDueHintEnabled` / `paymentScheduleHintEnabled` via Settings.
     Scrolls to the Feature-toggles section if either switch is offscreen.
     */
    public func setPaymentHintFlags(dueDate: Bool,
                                    schedule: Bool) {
        setSwitch(paymentDueHintSwitch, to: dueDate)
        setSwitch(paymentScheduleHintSwitch, to: schedule)
    }

    /**
     Scrolls up to six swipes until the switch is hittable, then sets it.
     Fails explicitly if the switch never becomes hittable.
     */
    private func setSwitch(_ switchElement: XCUIElement,
                           to on: Bool) {
        var attempts = 0
        while !switchElement.isHittable && attempts < 6 {
            app.swipeUp()
            attempts += 1
        }
        guard switchElement.isHittable else {
            XCTFail("Could not scroll \(switchElement) into view within \(attempts) swipes")
            return
        }
        let currentlyOn = switchElement.value as? String == "1"
        if currentlyOn != on {
            switchElement.tap()
        }
    }
}
