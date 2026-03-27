//
//  GiniProductTagSettingsUITests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest

// All the test methods have "manual" as a prefix because the tests require a physical device.
// Please remove the prefix if you want to test locally on a simulator.

/**
 Group A — Tests that verify the Product Tag segmented control in the Settings screen.

 The control exposes three segments:
 - index 0 → "SEPA" (`sepaExtractions`, default)
 - index 1 → "Cross-border" (`cxExtractions`)
 - index 2 → "Auto-detect" (`autoDetectExtractions`)
 */
class GiniProductTagSettingsUITests: GiniBankSDKExampleUITests {

    // MARK: - A1

    func testProductTagDefaultValueIsSEPA() {
        //Tap Configuration button
        mainScreen.configurationButton.tap()
        //Scroll to and assert Product Tag segmented control exists
        mainScreen.swipeToElement(element: settingScreen.productTagSegmentedControl, direction: "up")
        XCTAssertTrue(settingScreen.productTagSegmentedControl.exists,
                      "The Product Tag segmented control should exist in Settings.")
        //Assert that the first segment (SEPA) is selected by default
        let sepaSegment = settingScreen.productTagSegmentedControl.buttons.element(boundBy: 0)
        XCTAssertTrue(sepaSegment.isSelected, "SEPA should be the default selected product tag.")
        //Close Settings
        settingScreen.closeButton.tap()
    }

    // MARK: - A2

    func testProductTagSelectCrossBorder() {
        //Tap Configuration button
        mainScreen.configurationButton.tap()
        //Scroll to Product Tag segmented control
        mainScreen.swipeToElement(element: settingScreen.productTagSegmentedControl, direction: "up")
        //Select Cross-border (index 1)
        settingScreen.productTagSegmentedControl.buttons.element(boundBy: 1).tap()
        //Assert Cross-border is selected
        let crossBorderSegment = settingScreen.productTagSegmentedControl.buttons.element(boundBy: 1)
        XCTAssertTrue(crossBorderSegment.isSelected, "Cross-border segment should be selected.")
        //Close and reopen Settings to verify persistence
        settingScreen.closeButton.tap()
        mainScreen.configurationButton.tap()
        mainScreen.swipeToElement(element: settingScreen.productTagSegmentedControl, direction: "up")
        let crossBorderPersisted = settingScreen.productTagSegmentedControl.buttons.element(boundBy: 1)
        XCTAssertTrue(crossBorderPersisted.isSelected,
                      "Cross-border selection should persist after reopening Settings.")
        settingScreen.closeButton.tap()
    }

    // MARK: - A3

    func testProductTagSelectAutoDetect() {
        //Tap Configuration button
        mainScreen.configurationButton.tap()
        //Scroll to Product Tag segmented control
        mainScreen.swipeToElement(element: settingScreen.productTagSegmentedControl, direction: "up")
        //Select Auto-detect (index 2)
        settingScreen.productTagSegmentedControl.buttons.element(boundBy: 2).tap()
        //Assert Auto-detect is selected
        let autoDetectSegment = settingScreen.productTagSegmentedControl.buttons.element(boundBy: 2)
        XCTAssertTrue(autoDetectSegment.isSelected, "Auto-detect segment should be selected.")
        //Close and reopen Settings to verify persistence
        settingScreen.closeButton.tap()
        mainScreen.configurationButton.tap()
        mainScreen.swipeToElement(element: settingScreen.productTagSegmentedControl, direction: "up")
        let autoDetectPersisted = settingScreen.productTagSegmentedControl.buttons.element(boundBy: 2)
        XCTAssertTrue(autoDetectPersisted.isSelected,
                      "Auto-detect selection should persist after reopening Settings.")
        settingScreen.closeButton.tap()
    }

    // MARK: - A4

    func testProductTagSwitchBackToSEPA() {
        //Tap Configuration button
        mainScreen.configurationButton.tap()
        //Scroll to Product Tag segmented control
        mainScreen.swipeToElement(element: settingScreen.productTagSegmentedControl, direction: "up")
        //Select Cross-border first
        settingScreen.productTagSegmentedControl.buttons.element(boundBy: 1).tap()
        //Switch back to SEPA (index 0)
        settingScreen.productTagSegmentedControl.buttons.element(boundBy: 0).tap()
        //Assert SEPA is now selected
        let sepaSegment = settingScreen.productTagSegmentedControl.buttons.element(boundBy: 0)
        XCTAssertTrue(sepaSegment.isSelected,
                      "SEPA segment should be selected after switching back from Cross-border.")
        settingScreen.closeButton.tap()
    }
}
