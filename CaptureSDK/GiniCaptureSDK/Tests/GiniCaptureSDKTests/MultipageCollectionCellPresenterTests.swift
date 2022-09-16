//
//  MultipageCollectionCellPresenterTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 6/4/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniCaptureSDK
final class MultipageCollectionCellPresenterTests: XCTestCase {
    
    var presenter: MultipageReviewCollectionCellPresenter!
    var giniConfiguration: GiniConfiguration!
    var testPage = GiniCaptureTestsHelper.loadImagePage(named: "invoice")
    
    var setUpMainCollectionCell: MultipageReviewMainCollectionCell {
        let cell = presenter.setUp(MultipageReviewMainCollectionCell(frame: .zero),
                                   with: testPage, at: IndexPath(row: 0, section: 0))
        as? MultipageReviewMainCollectionCell
        return cell!
    }

    override func setUp() {
        super.setUp()
        giniConfiguration = GiniConfiguration()
        presenter = MultipageReviewCollectionCellPresenter(giniConfiguration: giniConfiguration)
    }
    
    func testMainCollectionCellImage() {
        presenter.thumbnails[testPage.document.id, default: [:]][.big] = testPage.document.previewImage
        
        XCTAssertEqual(setUpMainCollectionCell.documentImage.image, testPage.document.previewImage,
                       "Pages collection cells image content mode should match the one passed in the initializer")
    }
    
    func testMainCollectionCellImageContentMode() {
        XCTAssertEqual(setUpMainCollectionCell.documentImage.contentMode, UIView.ContentMode.scaleAspectFit,
                       "Main collection cells image content mode should match the one passed in the initializer")
    }
    
}
