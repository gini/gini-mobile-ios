//
//  OnboardingScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest

/**
 The title of one onboarding page: the visible text, kept for failure messages,
 and the element that shows it.

 Matched by `label` only: the page's illustration carries the same text as its accessibility
 value, and a plain `staticTexts[text]` lookup could match both.
 */
struct OnboardingPageTitle {
    let text: String
    let element: XCUIElement

    init(app: XCUIApplication, text: String) {
        self.text = text
        self.element = app.staticTexts.matching(NSPredicate(format: "label == %@", text)).firstMatch
    }
}

class OnboardingScreen {

    let app: XCUIApplication
    let nextButton: XCUIElement
    let skipButton: XCUIElement
    let getStartedButton: XCUIElement
    let flatPaperTitle: OnboardingPageTitle
    let goodLightingTitle: OnboardingPageTitle
    let multiPagesTitle: OnboardingPageTitle
    let qrCodeTitle: OnboardingPageTitle

    init(app: XCUIApplication, locale: String) {
        self.app = app

        switch locale {
        case "en":
            nextButton = app.staticTexts["Next"]
            skipButton = app.navigationBars.buttons["Skip"]
            getStartedButton = app.buttons["Get Started"]
            flatPaperTitle = OnboardingPageTitle(app: app, text: "Flat paper within the frame")
            goodLightingTitle = OnboardingPageTitle(app: app, text: "Good lighting")
            multiPagesTitle = OnboardingPageTitle(app: app, text: "Add multiple pages")
            qrCodeTitle = OnboardingPageTitle(app: app, text: "QR codes supported")
        case "de":
            nextButton = app.staticTexts["Weiter"]
            skipButton = app.navigationBars.buttons["Überspringen"]
            getStartedButton = app.buttons["Los geht’s"]
            flatPaperTitle = OnboardingPageTitle(app: app, text: "Dokument flach ausrichten")
            goodLightingTitle = OnboardingPageTitle(app: app, text: "Gute Lichtverhältnisse")
            multiPagesTitle = OnboardingPageTitle(app: app, text: "Mehrere Seiten")
            qrCodeTitle = OnboardingPageTitle(app: app, text: "QR-Codes scannen")
        default:
            fatalError("Locale \(locale) is not supported")
        }
    }

    func skipOnboardingScreens() {
        /// waitForExistence instead of bare `exists`: right after launch/permission
        /// alerts the app is still settling, and a single-snapshot `exists` query can
        /// stall ("Timed out while evaluating UI query") or return a premature false
        /// that silently skips the tap.
        if skipButton.waitForExistence(timeout: 5) {
            skipButton.tap()
        }
    }

    /**
     Waits until the page with `title` is the page on screen, and fails the test if it is not.

     A page change is an animated collection-view scroll. The neighbour pages can exist in the
     accessibility tree while they are off screen, but an off-screen element is never hittable,
     so the wait needs both `exists` and `isHittable`.
     */
    func waitForPage(_ title: OnboardingPageTitle,
                     timeout: TimeInterval = Constants.pageTimeout,
                     file: StaticString = #filePath,
                     line: UInt = #line) {
        let shown = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == true AND isHittable == true"),
                                              object: title.element)
        let result = XCTWaiter().wait(for: [shown], timeout: timeout)
        if result != .completed {
            XCTFail("Onboarding page '\(title.text)' not shown within \(Int(timeout)) s",
                    file: file,
                    line: line)
        }
    }

    /**
     Taps Next and waits for the page with `title`.

     The SDK reads the current page only when the scroll animation ends, so a second Next tap
     during the animation would move to the same page again. Waiting for the next page first
     keeps every tap.
     */
    func tapNextAndWaitFor(_ title: OnboardingPageTitle,
                           file: StaticString = #filePath,
                           line: UInt = #line) {
        nextButton.tap()
        waitForPage(title, file: file, line: line)
    }

    /**
     Taps Skip. Unlike `skipOnboardingScreens()`, a missing Skip button fails the test.
     */
    func tapSkip() {
        skipButton.tap()
    }

    /**
     Swipes on the pages, away from the screen edge where the navigation back gesture starts.
     */
    func swipeToNextPage() {
        app.collectionViews.firstMatch.swipeLeft()
    }

    /**
     Swipes back one page, like `swipeToNextPage()` away from the screen edge.
     */
    func swipeToPreviousPage() {
        app.collectionViews.firstMatch.swipeRight()
    }

    enum Constants {
        static let pageTimeout: TimeInterval = 5
        /// The first page also waits for the modal presentation after the permission alert.
        static let firstPageTimeout: TimeInterval = 10
    }
}
