//
//  QRCodeOverlayTests.swift
//  GiniCaptureSDK_Tests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
@testable import GiniCaptureSDK
@testable import GiniUtilites

/**
 Covers the "Powered by Gini" ingredient brand integration on `QRCodeOverlay`:
 insertion gated by `GiniCaptureUserDefaultsStorage.ingredientBrandScreens`, and
 visibility gated by the correct-QR state. Other overlay behavior (education flow,
 feedback, layout) is intentionally out of scope.
 */
@Suite("QRCodeOverlay — Powered by Gini ingredient brand", .serialized)
@MainActor
struct QRCodeOverlayTests {

    init() {
        /// Every test starts from a fresh "no configuration fetched yet" state.
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = nil
    }

    // MARK: - Insertion gating (ingredientBrandScreens)

    @Test("Ingredient brand is inserted (initially hidden) when the screens list contains \"Analysis\"")
    func ingredientBrandIsInsertedHiddenWhenScreensListContainsAnalysis() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = ["Analysis"]

        let sut = QRCodeOverlay()
        let ingredientBrand = findBadge(in: sut)

        #expect(ingredientBrand != nil,
                "Expected the ingredient brand to be inserted when the flag lists Analysis")
        #expect(ingredientBrand?.isHidden == true,
                "Expected the ingredient brand to start hidden — it becomes visible only on the correct-QR state")
    }

    @Test("Ingredient brand screens list match is case-insensitive")
    func ingredientBrandMatchesScreensListCaseInsensitively() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = ["analysis"]

        let sut = QRCodeOverlay()

        #expect(findBadge(in: sut) != nil,
                "Expected the ingredientBrandScreens match to be case-insensitive")
    }

    @Test("Ingredient brand is omitted when the screens list is empty")
    func ingredientBrandIsOmittedWhenScreensListIsEmpty() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = []

        let sut = QRCodeOverlay()

        #expect(findBadge(in: sut) == nil,
                "Expected no ingredient brand when the flag is an empty array")
    }

    @Test("Ingredient brand is omitted before /configurations has been fetched")
    func ingredientBrandIsOmittedBeforeConfigurationsFetch() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = nil

        let sut = QRCodeOverlay()

        #expect(findBadge(in: sut) == nil,
                "Expected no ingredient brand when the flag is nil (fresh install, no /configurations fetched yet)")
    }

    // MARK: - Visibility gating (correct-QR state)

    @Test("Ingredient brand shows on the correct-QR (dark full-overlay) state")
    func ingredientBrandShowsOnValidQRState() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = ["Analysis"]
        let sut = QRCodeOverlay()

        sut.configureQrCodeOverlay(withCorrectQrCode: true)

        #expect(findBadge(in: sut)?.isHidden == false,
                "Expected the ingredient brand to be visible on the dark full-overlay valid-QR state")
    }

    @Test("Ingredient brand stays hidden on the incorrect-QR (clear-background) state")
    func ingredientBrandStaysHiddenOnInvalidQRState() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = ["Analysis"]
        let sut = QRCodeOverlay()

        sut.configureQrCodeOverlay(withCorrectQrCode: false)

        #expect(findBadge(in: sut)?.isHidden == true,
                "Expected the ingredient brand to stay hidden on the clear-background invalid-QR state — a white pill on transparent camera preview would look wrong")
    }

    @Test("Ingredient brand appears on invalid → valid QR transition")
    func ingredientBrandAppearsOnInvalidToValidQRTransition() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = ["Analysis"]
        let sut = QRCodeOverlay()

        sut.configureQrCodeOverlay(withCorrectQrCode: false)
        #expect(findBadge(in: sut)?.isHidden == true,
                "Expected the ingredient brand hidden on the invalid state before the transition")

        sut.configureQrCodeOverlay(withCorrectQrCode: true)
        #expect(findBadge(in: sut)?.isHidden == false,
                "Expected the ingredient brand to become visible when the overlay transitions from invalid to valid QR")
    }

    // MARK: - Helpers

    private func findBadge(in view: UIView) -> PoweredByGiniBadgeView? {
        if let ingredientBrand = view as? PoweredByGiniBadgeView { return ingredientBrand }
        for subview in view.subviews {
            if let ingredientBrand = findBadge(in: subview) { return ingredientBrand }
        }
        return nil
    }
}
