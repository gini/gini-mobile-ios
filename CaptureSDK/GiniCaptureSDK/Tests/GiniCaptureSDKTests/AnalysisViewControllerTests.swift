//
//  AnalysisViewControllerTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 10/5/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniCaptureSDK

final class AnalysisViewControllerTests: XCTestCase {
    
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

    // MARK: - Helpers

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
