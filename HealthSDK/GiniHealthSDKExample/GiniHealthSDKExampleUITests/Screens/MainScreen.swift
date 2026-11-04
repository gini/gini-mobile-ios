//
//  MainScreen.swift
//  GiniHealthSDKExampleUITests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest

/**
 Host-app entry screen (`SelectAPIViewController`).

 Buttons are addressed by accessibility identifier set programmatically in the
 host app's `viewDidLoad` — the IDs are stable across localizations and survive
 any xib regeneration.
 */
final class MainScreen {

    let app: XCUIApplication

    /** "Start with Test Document" — launches the SDK with a pre-canned document. */
    let startWithTestDocumentButton: XCUIElement

    /**
     "Start with Gini Capture" — launches the Capture SDK's camera/import flow.
     HEAL-282 (image import) and HEAL-284 (PDF import) enter here.
     */
    let startWithGiniCaptureButton: XCUIElement

    /** "Invoices List" — entry point for HEAL-285. */
    let invoicesListButton: XCUIElement

    /** "Orders List" — entry point for HEAL-286, HEAL-300, HEAL-301. */
    let ordersListButton: XCUIElement

    init(app: XCUIApplication) {
        self.app = app
        self.startWithTestDocumentButton = app.buttons["health.main.startWithTestDocument"]
        self.startWithGiniCaptureButton = app.buttons["health.main.startWithGiniCapture"]
        self.invoicesListButton = app.buttons["health.main.invoicesList"]
        self.ordersListButton = app.buttons["health.main.ordersList"]
    }

    /**
     Handles the system permission alert shown after a flow requests access.

     Button labels are localised and the hosting process differs by iOS version:

     - Classic alerts (camera, microphone, pre-iOS 17 photo library) live in
       **SpringBoard**.
     - iOS 17+ `PHPickerViewController` limited-access consent sheet lives
       **in-process** in the host app's accessibility tree (behind the camera
       screen, with photo previews). SpringBoard does not host it.

     Both locations are checked; `answer == true` taps the first "Allow"-equivalent
     found, `false` taps "Don't Allow". Returns silently if no alert appears within
     `timeout` — some BrowserStack sessions prime the alert before the test attaches,
     in which case it is already dismissed.
     */
    func handleSystemPermission(answer: Bool, timeout: TimeInterval = 5) {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        _ = springboard.wait(for: .runningForeground, timeout: timeout)
        let allowTitles = ["Allow",
                           "OK",
                           "Allow Full Access",
                           "Allow Access to All Photos",
                           "Zugriff auf alle Fotos erlauben"]
        let denyTitles = ["Don't Allow", "Don\u{2019}t Allow", "Nicht erlauben"]
        let targets = answer ? allowTitles : denyTitles
        for title in targets {
            let sbButton = springboard.buttons[title]
            if sbButton.waitForExistence(timeout: 1), sbButton.isHittable {
                sbButton.tap()
                return
            }
            let appButton = app.buttons[title]
            if appButton.waitForExistence(timeout: 1), appButton.isHittable {
                appButton.tap()
                return
            }
        }
    }
}
