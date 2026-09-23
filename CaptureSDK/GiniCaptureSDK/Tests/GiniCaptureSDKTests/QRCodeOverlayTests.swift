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
        GiniConfiguration.shared.customLoadingIndicator = nil
    }

    // MARK: - Insertion gating (ingredientBrandScreens)

    @Test("Ingredient brand is inserted (initially hidden) when the screens list contains \"Analysis\"")
    func ingredientBrandIsInsertedHiddenWhenScreensListContainsAnalysis() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = ["Analysis"]

        let sut = QRCodeOverlay()
        sut.configureQrCodeOverlay(withCorrectQrCode: false)
        let ingredientBrand = findBadge(in: sut)

        #expect(ingredientBrand != nil,
                "Expected the ingredient brand to be inserted when the flag lists Analysis")
        #expect(ingredientBrand?.isHidden == true,
                "Expected the ingredient brand to stay hidden on the invalid-QR state")
    }

    @Test("Ingredient brand screens list match is case-insensitive")
    func ingredientBrandMatchesScreensListCaseInsensitively() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = ["analysis"]

        let sut = QRCodeOverlay()
        sut.configureQrCodeOverlay(withCorrectQrCode: false)

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

    // MARK: - Loading indicator gating

    @Test("Standard flow uses UIActivityIndicatorView when the ingredient-brand gate is off")
    func standardLoaderWhenGateOff() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = nil

        let sut = QRCodeOverlay()

        #expect(findActivityIndicator(in: sut) != nil,
                "Expected the standard UIActivityIndicatorView when the ingredient-brand gate is off")
        #expect(findLoadingIndicator(in: sut) == nil,
                "Expected no PoweredByGiniLoadingIndicatorView when the gate is off")
    }

    @Test("Branded g replaces UIActivityIndicatorView when the gate is on and no customLoadingIndicator is set")
    func brandedLoaderWhenGateOnAndNoCustomIndicator() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = ["Analysis"]

        let sut = QRCodeOverlay()
        sut.showAnimation()

        #expect(findLoadingIndicator(in: sut) != nil,
                "Expected the PoweredByGiniLoadingIndicatorView when the gate is on and no integrator loader is injected")
        #expect(findActivityIndicator(in: sut) == nil,
                "Expected the standard UIActivityIndicatorView to be omitted when the branded loader wins")
    }

    @Test("Branded g wins over integrator's customLoadingIndicator when the gate is on")
    func brandedLoaderWinsOverIntegratorCustomLoader() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = ["Analysis"]
        let stub = StubCustomLoadingIndicator()
        GiniConfiguration.shared.customLoadingIndicator = stub

        let sut = QRCodeOverlay()
        sut.showAnimation()

        #expect(findLoadingIndicator(in: sut) != nil,
                "Expected the branded g to win over the integrator's custom loading indicator when the gate is on")
        #expect(findView(in: sut, matching: { $0 === stub.injected }) == nil,
                "Expected the integrator's injected view to be swapped out of the loading container")
        #expect(stub.startAnimationCalled == false,
                "Expected the integrator's startAnimation not to be called on the branded path")
    }

    @Test("Integrator's customLoadingIndicator is honored when the ingredient-brand gate is off")
    func integratorCustomLoaderUsedWhenGateOff() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = nil
        let stub = StubCustomLoadingIndicator()
        GiniConfiguration.shared.customLoadingIndicator = stub

        let sut = QRCodeOverlay()
        sut.showAnimation()

        #expect(findView(in: sut, matching: { $0 === stub.injected }) != nil,
                "Expected the integrator's injected view to be used when the gate is off")
        #expect(findLoadingIndicator(in: sut) == nil,
                "Expected no PoweredByGiniLoadingIndicatorView when the gate is off")
    }

    // MARK: - Helpers

    private func findBadge(in view: UIView) -> PoweredByGiniBadgeView? {
        if let ingredientBrand = view as? PoweredByGiniBadgeView { return ingredientBrand }
        for subview in view.subviews {
            if let ingredientBrand = findBadge(in: subview) { return ingredientBrand }
        }
        return nil
    }

    private func findLoadingIndicator(in view: UIView) -> PoweredByGiniLoadingIndicatorView? {
        if let indicator = view as? PoweredByGiniLoadingIndicatorView { return indicator }
        for subview in view.subviews {
            if let indicator = findLoadingIndicator(in: subview) { return indicator }
        }
        return nil
    }

    private func findActivityIndicator(in view: UIView) -> UIActivityIndicatorView? {
        for subview in view.subviews where subview.superview is UIStackView {
            if let indicator = subview as? UIActivityIndicatorView { return indicator }
        }
        for subview in view.subviews {
            if let indicator = findActivityIndicator(in: subview) { return indicator }
        }
        return nil
    }

    private func findView(in view: UIView,
                          matching predicate: (UIView) -> Bool) -> UIView? {
        if predicate(view) { return view }
        for subview in view.subviews {
            if let match = findView(in: subview, matching: predicate) { return match }
        }
        return nil
    }
}

/**
 Manual `CustomLoadingIndicatorAdapter` conformance — no third-party mocking
 framework per the repo testing standard.
 */
private final class StubCustomLoadingIndicator: CustomLoadingIndicatorAdapter {
    let injected = UIView()
    var startAnimationCalled = false

    func injectedView() -> UIView { injected }
    func startAnimation() { startAnimationCalled = true }
    func stopAnimation() {}
    func onDeinit() {}
}
