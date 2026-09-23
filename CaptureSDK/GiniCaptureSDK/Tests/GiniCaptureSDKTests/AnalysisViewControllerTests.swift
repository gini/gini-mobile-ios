//
//  AnalysisViewControllerTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 10/5/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniCaptureSDK
@testable import GiniUtilites

final class AnalysisViewControllerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = nil
    }

    override func tearDown() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = nil
        super.tearDown()
    }

    func testPDFPagesCountLocalizedString() {
        let key = "ginicapture.analysis.pdfpages"
        let localizedStringFormat = NSLocalizedStringPreferredFormat(key,
                                                         comment: "Text appearing at the top of the " +
                                                                  "analysis screen indicating pdf number of pages")
        let localizedString = String(format: localizedStringFormat, arguments: [2])

        XCTAssertNotEqual(key, localizedString)
    }

    // MARK: - shouldDisplayEducationFlow

    func testShouldDisplayEducationFlowWhenAllConditionsMet() {
        let config = GiniConfiguration()
        config.productTag = .sepaExtractions
        config.fileImportSupportedTypes = .pdf
        let sut = AnalysisViewController(document: makeCameraImageDocument(), giniConfiguration: config)

        XCTAssertTrue(sut.shouldDisplayEducationFlow,
                      "Education flow should be displayed when product tag is not CX, document is not imported, and file import is enabled")
    }

    func testShouldDisplayEducationFlowWhenProductTagIsCXExtractions() {
        let config = GiniConfiguration()
        config.productTag = .cxExtractions
        config.fileImportSupportedTypes = .pdf
        let sut = AnalysisViewController(document: makeCameraImageDocument(), giniConfiguration: config)

        XCTAssertFalse(sut.shouldDisplayEducationFlow,
                       "Education flow should not be displayed when product tag is CX extractions")
    }

    func testShouldDisplayEducationFlowWhenDocumentIsImported() {
        let config = GiniConfiguration()
        config.productTag = .sepaExtractions
        config.fileImportSupportedTypes = .pdf
        let sut = AnalysisViewController(document: makeImportImageDocument(), giniConfiguration: config)

        XCTAssertFalse(sut.shouldDisplayEducationFlow,
                       "Education flow should not be displayed when document is imported")
    }

    func testShouldDisplayEducationFlowWhenFileImportSupportedTypesIsNone() {
        let config = GiniConfiguration()
        config.productTag = .sepaExtractions
        config.fileImportSupportedTypes = .none
        let sut = AnalysisViewController(document: makeCameraImageDocument(), giniConfiguration: config)

        XCTAssertFalse(sut.shouldDisplayEducationFlow,
                       "Education flow should not be displayed when file import is disabled")
    }

    func testShouldDisplayEducationFlowWhenAllConditionsAreFalse() {
        let config = GiniConfiguration()
        config.productTag = .cxExtractions
        config.fileImportSupportedTypes = .none
        let sut = AnalysisViewController(document: makeImportImageDocument(), giniConfiguration: config)

        XCTAssertFalse(sut.shouldDisplayEducationFlow,
                       "Education flow should not be displayed when all conditions are false")
    }

    // MARK: - Powered by Gini badge (ingredient brand)

    func testAnalysisShowsPoweredByBadgeWhenIngredientBrandScreensContainsAnalysis() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = ["Analysis"]
        let sut = AnalysisViewController(document: makeCameraImageDocument(),
                                         giniConfiguration: sepaExtractionsConfig())

        sut.loadViewIfNeeded()

        XCTAssertNotNil(findBadge(in: sut.view),
                        "Expected PoweredByGiniBadgeView to be added when storage contains \"Analysis\"")
    }

    func testAnalysisShowsBadgeWhenScreenNameIsLowercase() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = ["analysis"]
        let sut = AnalysisViewController(document: makeCameraImageDocument(),
                                         giniConfiguration: sepaExtractionsConfig())

        sut.loadViewIfNeeded()

        XCTAssertNotNil(findBadge(in: sut.view),
                        "Expected badge match to be case-insensitive")
    }

    func testAnalysisHidesBadgeWhenIngredientBrandScreensIsEmpty() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = []
        let sut = AnalysisViewController(document: makeCameraImageDocument(),
                                         giniConfiguration: sepaExtractionsConfig())

        sut.loadViewIfNeeded()

        XCTAssertNil(findBadge(in: sut.view),
                     "Expected no PoweredByGiniBadgeView when ingredientBrandScreens is empty")
    }

    func testAnalysisHidesBadgeWhenIngredientBrandScreensIsNil() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = nil
        let sut = AnalysisViewController(document: makeCameraImageDocument(),
                                         giniConfiguration: sepaExtractionsConfig())

        sut.loadViewIfNeeded()

        XCTAssertNil(findBadge(in: sut.view),
                     "Expected no PoweredByGiniBadgeView when ingredientBrandScreens is nil (no /configurations fetch yet)")
    }

    func testAnalysisBadgeIsVisibleInitiallyEvenForImageDocs() {
        /// The banner has a 4s pre-appearance delay; the badge is visible until then.
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = ["Analysis"]
        let sut = AnalysisViewController(document: makeCameraImageDocument(),
                                         giniConfiguration: sepaExtractionsConfig())

        sut.loadViewIfNeeded()

        let badge = findBadge(in: sut.view)
        XCTAssertNotNil(badge, "Badge should be present in the view tree for image docs when the flag is set")
        XCTAssertFalse(badge?.isHidden ?? true,
                       "Expected badge to be visible immediately — the banner has not appeared yet (4s delay)")
    }

    func testAnalysisBadgeHidesOnFirstBannerAppearanceAndStaysHidden() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = ["Analysis"]
        let sut = AnalysisViewController(document: makeCameraImageDocument(),
                                         giniConfiguration: sepaExtractionsConfig())

        sut.loadViewIfNeeded()

        let badge = findBadge(in: sut.view)
        XCTAssertNotNil(badge,
                        "Precondition: badge should be inserted for image docs when the flag is set")
        XCTAssertFalse(badge?.isHidden ?? true,
                       "Precondition: badge should be visible before the banner appears")

        let banner = findCaptureSuggestions(in: sut.view)
        XCTAssertNotNil(banner,
                        "Precondition: showCaptureSuggestions should install the banner for image docs")

        /// First banner appearance — badge hides alongside the banner animation.
        banner?.onBannerVisibilityChange?(true)
        XCTAssertTrue(badge?.isHidden == true,
                      "Expected badge to hide on the first banner appearance")

        /// Banner cycles to hidden — badge stays hidden (Figma alternation is one-way once the banner has shown).
        banner?.onBannerVisibilityChange?(false)
        XCTAssertTrue(badge?.isHidden == true,
                      "Expected badge to stay hidden after the banner cycles to hidden")

        /// A later banner appearance — badge remains hidden, not toggled back on.
        banner?.onBannerVisibilityChange?(true)
        XCTAssertTrue(badge?.isHidden == true,
                      "Expected badge to stay hidden on subsequent banner appearances")
    }

    func testAnalysisBadgeStaysWhenCaptureSuggestionsRemoved() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = ["Analysis"]
        let sut = AnalysisViewController(document: makeCameraImageDocument(),
                                         giniConfiguration: sepaExtractionsConfig())

        sut.loadViewIfNeeded()

        XCTAssertNotNil(findBadge(in: sut.view), "Badge should be present initially")
        sut.removeCaptureSuggestions()

        let badge = findBadge(in: sut.view)
        XCTAssertNotNil(badge,
                        "Badge should remain in the view tree after the banner is removed")
        XCTAssertFalse(badge?.isHidden ?? true,
                       "Expected badge to be visible after removeCaptureSuggestions — the screen is dismissing and the badge should be in a clean visible state for any re-presentation")
    }

    // MARK: - Powered by Gini loading indicator (PP-3511, ingredient brand)

    func testAnalysisShowsPoweredByGiniLoadingIndicatorWhenScreensListContainsAnalysis() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = ["Analysis"]
        let sut = AnalysisViewController(document: makeImportImageDocument(),
                                         giniConfiguration: sepaExtractionsConfig())

        sut.loadViewIfNeeded()

        XCTAssertNotNil(findLoadingIndicator(in: sut.view),
                        "Expected PoweredByGiniLoadingIndicatorView to be added when storage contains \"Analysis\"")
        XCTAssertNil(findActivitySpinner(in: sut.view),
                     "Expected default UIActivityIndicatorView to be omitted when Gini indicator is active")
    }

    func testAnalysisShowsPoweredByGiniLoadingIndicatorWhenScreenNameIsLowercase() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = ["analysis"]
        let sut = AnalysisViewController(document: makeImportImageDocument(),
                                         giniConfiguration: sepaExtractionsConfig())

        sut.loadViewIfNeeded()

        XCTAssertNotNil(findLoadingIndicator(in: sut.view),
                        "Expected loading-indicator match to be case-insensitive")
    }

    func testAnalysisHidesPoweredByGiniLoadingIndicatorWhenIngredientBrandScreensIsEmpty() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = []
        let sut = AnalysisViewController(document: makeImportImageDocument(),
                                         giniConfiguration: sepaExtractionsConfig())

        sut.loadViewIfNeeded()

        XCTAssertNil(findLoadingIndicator(in: sut.view),
                     "Expected no PoweredByGiniLoadingIndicatorView when ingredientBrandScreens is empty")
        XCTAssertNotNil(findActivitySpinner(in: sut.view),
                        "Expected default UIActivityIndicatorView when flag is off")
    }

    func testAnalysisPoweredByGiniLoadingIndicatorOverridesCustomLoadingIndicator() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = ["Analysis"]
        let config = sepaExtractionsConfig()
        let stubAdapter = StubLoadingIndicatorAdapter()
        config.customLoadingIndicator = stubAdapter
        let sut = AnalysisViewController(document: makeImportImageDocument(),
                                         giniConfiguration: config)

        sut.loadViewIfNeeded()

        XCTAssertNotNil(findLoadingIndicator(in: sut.view),
                        "Expected Gini indicator to win over customLoadingIndicator when the flag is on")
        XCTAssertFalse(stubAdapter.startAnimationCalled,
                       "Expected customLoadingIndicator.startAnimation() to NOT be called when the Gini indicator is active")
    }

    func testAnalysisFallsBackToDefaultSpinnerWhenGiniIndicatorAssetIsUnavailable() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = ["Analysis"]
        let sut = AnalysisViewController(document: makeImportImageDocument(),
                                         giniConfiguration: sepaExtractionsConfig())
        /// Pre-empt the lazy var so `showOriginalLoadingMessage` sees a nil indicator,
        /// exercising the asset-missing fallback (R7) without touching the GIF bundle.
        sut.poweredByGiniLoadingIndicatorView = nil

        sut.loadViewIfNeeded()

        XCTAssertNil(findLoadingIndicator(in: sut.view),
                     "Expected no PoweredByGiniLoadingIndicatorView when the asset is unavailable")
        XCTAssertNotNil(findActivitySpinner(in: sut.view),
                        "Expected default UIActivityIndicatorView as R7 fallback")
    }

    // MARK: - Helpers

    private func sepaExtractionsConfig() -> GiniConfiguration {
        let config = GiniConfiguration()
        config.productTag = .sepaExtractions
        config.fileImportSupportedTypes = .pdf
        return config
    }

    private func findBadge(in view: UIView) -> PoweredByGiniBadgeView? {
        if let badge = view as? PoweredByGiniBadgeView { return badge }
        for subview in view.subviews {
            if let badge = findBadge(in: subview) { return badge }
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

    private func findActivitySpinner(in view: UIView) -> UIActivityIndicatorView? {
        if let spinner = view as? UIActivityIndicatorView { return spinner }
        for subview in view.subviews {
            if let spinner = findActivitySpinner(in: subview) { return spinner }
        }
        return nil
    }

    private func findCaptureSuggestions(in view: UIView) -> CaptureSuggestionsView? {
        if let banner = view as? CaptureSuggestionsView { return banner }
        for subview in view.subviews {
            if let banner = findCaptureSuggestions(in: subview) { return banner }
        }
        return nil
    }

    private func makeCameraImageDocument() -> GiniImageDocument {
        let image = GiniCaptureTestsHelper.loadImage(named: "invoice")
        guard let imageData = image.jpegData(compressionQuality: 0.2) else {
            XCTFail("Failed to create JPEG data from invoice image")
            return GiniImageDocument(data: Data(), imageSource: .camera)
        }
        return GiniImageDocument(data: imageData, imageSource: .camera)
    }

    private func makeImportImageDocument() -> GiniImageDocument {
        let image = GiniCaptureTestsHelper.loadImage(named: "invoice")
        guard let imageData = image.jpegData(compressionQuality: 0.2) else {
            XCTFail("Failed to create JPEG data from invoice image")
            return GiniImageDocument(data: Data(), imageSource: .external)
        }
        return GiniImageDocument(data: imageData, imageSource: .external)
    }
}

private final class StubLoadingIndicatorAdapter: CustomLoadingIndicatorAdapter {
    private(set) var startAnimationCalled = false
    private(set) var stopAnimationCalled = false
    private let hostedView = UIView()

    func injectedView() -> UIView { hostedView }
    func onDeinit() {}
    func startAnimation() { startAnimationCalled = true }
    func stopAnimation() { stopAnimationCalled = true }
}
