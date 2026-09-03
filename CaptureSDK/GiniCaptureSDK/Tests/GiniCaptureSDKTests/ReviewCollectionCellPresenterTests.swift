//
//  MultipageCollectionCellPresenterTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 6/4/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniCaptureSDK
final class ReviewCollectionCellPresenterTests: XCTestCase {
    
    var presenter: ReviewCollectionCellPresenter!
    var giniConfiguration: GiniConfiguration!
    var testPage = GiniCaptureTestsHelper.loadImagePage(named: "invoice")
    
    var setUpMainCollectionCell: ReviewCollectionCell {
        let cell = presenter.setUp(ReviewCollectionCell(frame: .zero),
                                   with: testPage, at: IndexPath(row: 0, section: 0))
        as? ReviewCollectionCell
        return cell!
    }

    override func setUp() {
        super.setUp()
        giniConfiguration = GiniConfiguration()
        presenter = ReviewCollectionCellPresenter(giniConfiguration: giniConfiguration)
    }
    
    func testMainCollectionCellImage() {
        presenter.thumbnails[testPage.document.id, default: [:]][.big] = testPage.document.previewImage
        
        XCTAssertEqual(setUpMainCollectionCell.documentImageView.image, testPage.document.previewImage,
                       "Pages collection cells image content mode should match the one passed in the initializer")
    }
    
    func testMainCollectionCellImageContentMode() {
        XCTAssertEqual(setUpMainCollectionCell.documentImageView.contentMode, UIView.ContentMode.scaleAspectFit,
                       "Main collection cells image content mode should match the one passed in the initializer")
    }
    
}
