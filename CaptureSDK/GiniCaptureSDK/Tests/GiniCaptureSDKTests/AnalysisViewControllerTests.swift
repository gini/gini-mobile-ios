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

    func testAnalysisBadgeStaysWhenCaptureSuggestionsRemoved() {
        GiniCaptureUserDefaultsStorage.ingredientBrandScreens = ["Analysis"]
        let sut = AnalysisViewController(document: makeCameraImageDocument(),
                                         giniConfiguration: sepaExtractionsConfig())

        sut.loadViewIfNeeded()

        XCTAssertNotNil(findBadge(in: sut.view), "Badge should be present initially")
        sut.removeCaptureSuggestions()
        XCTAssertNotNil(findBadge(in: sut.view),
                        "Badge should remain after the capture-suggestions banner is removed")
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
