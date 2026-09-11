//
//  QRCodeOverlayTests.swift
//  GiniCaptureSDK_Tests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniCaptureSDK
@testable import GiniUtilites

/**
 Covers the PP-2570 ingredient-brand badge integration on `QRCodeOverlay`
 (Figma flow "5.2 QR code flow"). The rest of the overlay's behavior
 (education flow, correct/incorrect QR feedback, layout) has no test file
 yet — this suite is intentionally scoped to the badge.
 */
final class QRCodeOverlayTests: XCTestCase {

    override func setUp() {
        super.setUp()
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = nil
    }

    override func tearDown() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = nil
        super.tearDown()
    }

    // MARK: - Badge insertion (gated by ingredientBrandScreens)

    func testBadgeIsAddedHiddenWhenIngredientBrandScreensContainsAnalysis() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = ["Analysis"]

        let sut = QRCodeOverlay()

        let badge = findBadge(in: sut)
        XCTAssertNotNil(badge, "Expected the badge to be added to the overlay when the flag is set")
        XCTAssertTrue(badge?.isHidden == true,
                      "Expected the badge to start hidden — it becomes visible only on correct-QR state")
    }

    func testBadgeIsAddedWhenScreenNameIsLowercase() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = ["analysis"]

        let sut = QRCodeOverlay()

        XCTAssertNotNil(findBadge(in: sut),
                        "Expected the ingredientBrandScreens match to be case-insensitive")
    }

    func testBadgeIsNotAddedWhenIngredientBrandScreensIsEmpty() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = []

        let sut = QRCodeOverlay()

        XCTAssertNil(findBadge(in: sut),
                     "Expected no badge when the flag is an empty array")
    }

    func testBadgeIsNotAddedWhenIngredientBrandScreensIsNil() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = nil

        let sut = QRCodeOverlay()

        XCTAssertNil(findBadge(in: sut),
                     "Expected no badge when the flag is nil (fresh install, no /configurations fetched yet)")
    }

    // MARK: - Visibility gating (correct-QR only)

    func testBadgeBecomesVisibleOnCorrectQRState() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = ["Analysis"]
        let sut = QRCodeOverlay()

        sut.configureQrCodeOverlay(withCorrectQrCode: true)

        XCTAssertFalse(findBadge(in: sut)?.isHidden ?? true,
                       "Expected the badge to be visible on the dark full-overlay valid-QR state")
    }

    func testBadgeStaysHiddenOnIncorrectQRState() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = ["Analysis"]
        let sut = QRCodeOverlay()

        sut.configureQrCodeOverlay(withCorrectQrCode: false)

        XCTAssertTrue(findBadge(in: sut)?.isHidden ?? false,
                      "Expected the badge to stay hidden on the clear-background invalid-QR state — a white pill on transparent camera preview would look wrong")
    }

    func testBadgeTogglesFromIncorrectToCorrect() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = ["Analysis"]
        let sut = QRCodeOverlay()

        sut.configureQrCodeOverlay(withCorrectQrCode: false)
        XCTAssertTrue(findBadge(in: sut)?.isHidden ?? false)

        sut.configureQrCodeOverlay(withCorrectQrCode: true)
        XCTAssertFalse(findBadge(in: sut)?.isHidden ?? true,
                       "Expected the badge to become visible when the overlay transitions from invalid to valid QR")
    }

    // MARK: - Helpers

    private func findBadge(in view: UIView) -> PoweredByGiniBadgeView? {
        if let badge = view as? PoweredByGiniBadgeView { return badge }
        for subview in view.subviews {
            if let badge = findBadge(in: subview) { return badge }
        }
        return nil
    }
}
