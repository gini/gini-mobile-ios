//
//  PaymentHintScreen.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest

/**
 Page Object for the payment-hint bottom sheet
 (`PaymentHintBottomSheetViewController` in `GiniCaptureSDK`). Element
 lookups go through `accessibilityIdentifier`, so the object is
 locale-independent.
 */
class PaymentHintScreen {

    let app: XCUIApplication

    // MARK: - Due Date state

    let dueDateContainer: XCUIElement
    let dueDateTitle: XCUIElement
    let dueDateDescription: XCUIElement
    let dueDateProceedButton: XCUIElement
    let dueDateCancelButton: XCUIElement

    // MARK: - Schedule Payment state

    let scheduleContainer: XCUIElement
    let scheduleTitle: XCUIElement
    let scheduleDescription: XCUIElement
    let scheduleButton: XCUIElement
    let scheduleProceedButton: XCUIElement

    init(app: XCUIApplication) {
        self.app = app

        dueDateContainer = app.otherElements[PaymentHintScreenAccessibilityIdentifiers.DueDate.container]
        dueDateTitle = app.staticTexts[PaymentHintScreenAccessibilityIdentifiers.DueDate.title]
        dueDateDescription = app.staticTexts[PaymentHintScreenAccessibilityIdentifiers.DueDate.description]
        dueDateProceedButton = app.buttons[PaymentHintScreenAccessibilityIdentifiers.DueDate.proceedButton]
        dueDateCancelButton = app.buttons[PaymentHintScreenAccessibilityIdentifiers.DueDate.cancelButton]

        scheduleContainer = app.otherElements[PaymentHintScreenAccessibilityIdentifiers.Schedule.container]
        scheduleTitle = app.staticTexts[PaymentHintScreenAccessibilityIdentifiers.Schedule.title]
        scheduleDescription = app.staticTexts[PaymentHintScreenAccessibilityIdentifiers.Schedule.description]
        scheduleButton = app.buttons[PaymentHintScreenAccessibilityIdentifiers.Schedule.scheduleButton]
        scheduleProceedButton = app.buttons[PaymentHintScreenAccessibilityIdentifiers.Schedule.proceedButton]
    }

    /**
     Waits for the Due Date Hint sheet to appear.
     */
    @discardableResult
    func waitForDueDateSheet(timeout: TimeInterval = 60) -> Bool {
        dueDateContainer.waitForExistence(timeout: timeout)
    }

    /**
     Waits for the Schedule Payment sheet to appear.
     */
    @discardableResult
    func waitForScheduleSheet(timeout: TimeInterval = 60) -> Bool {
        scheduleContainer.waitForExistence(timeout: timeout)
    }
}
