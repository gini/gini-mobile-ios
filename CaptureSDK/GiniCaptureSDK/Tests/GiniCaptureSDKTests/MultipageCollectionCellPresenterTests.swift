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
    var setUpPageCollectionCell: MultipageReviewPagesCollectionCell {
        let cell = presenter
            .setUp(.pages(MultipageReviewPagesCollectionCell(frame: .zero)),
                   with: testPage,
                   isSelected: true,
                   at: IndexPath(row: 0, section: 0)) as? MultipageReviewPagesCollectionCell
        return cell!
    }
    
    var setUpMainCollectionCell: MultipageReviewMainCollectionCell {
        let cell = presenter
            .setUp(.main(MultipageReviewMainCollectionCell(frame: .zero), { _ in}),
                   with: testPage,
                   isSelected: true,
                   at: IndexPath(row: 0, section: 0)) as? MultipageReviewMainCollectionCell
        return cell!
    }

    override func setUp() {
        super.setUp()
        giniConfiguration = GiniConfiguration()
        presenter = MultipageReviewCollectionCellPresenter(giniConfiguration: giniConfiguration)
    }
    
    func testPageIndicatorLabel() {
        giniConfiguration.multipagePageIndicatorColor = .black
        XCTAssertEqual(setUpPageCollectionCell.pageIndicatorLabel.textColor,
                       giniConfiguration.multipagePageIndicatorColor,
                       "page cell indicator color should match the one specified in the configuration")
    }
    
    func testPageBottomContainerColor() {
        giniConfiguration.multipagePageBackgroundColor = GiniColor.init(lightModeColor: .red, darkModeColor: .red)
        XCTAssertEqual(setUpPageCollectionCell.bottomContainer.backgroundColor?.cgColor,
                       UIColor.from(giniColor: giniConfiguration.multipagePageBackgroundColor).cgColor,
                       "page cell background color should match the one specified in the configuration")
    }
    
    func testPageSelectedIndicatorColor() {
        giniConfiguration.multipagePageSelectedIndicatorColor = .red
        
        XCTAssertEqual(setUpPageCollectionCell.pageSelectedLine.backgroundColor,
                       giniConfiguration.multipagePageSelectedIndicatorColor,
                       "selected line indicator background color should match the one specified in the configuration")
    }
    
    func testPageDraggableIconColor() {
        giniConfiguration.multipageDraggableIconColor = .red
        
        XCTAssertEqual(setUpPageCollectionCell.draggableIcon.tintColor,
                       giniConfiguration.multipageDraggableIconColor,
                       "page draggable icon tint color should match the one specified in the configuration")
    }
    
    func testPagesCollectionCellImage() {
        presenter.thumbnails[testPage.document.id, default: [:]][.small] = testPage.document.previewImage
        
        XCTAssertEqual(setUpPageCollectionCell.documentImage.image, testPage.document.previewImage,
                       "Pages collection cells image content mode should match the one passed in the initializer")
    }
    
    func testPagesCollectionCellImageContentMode() {
        presenter.thumbnails[testPage.document.id, default: [:]][.small] = testPage.document.previewImage
        
        XCTAssertEqual(setUpPageCollectionCell.documentImage.contentMode, UIView.ContentMode.scaleAspectFill,
                       "Pages collection cells image content mode should match the one passed in the initializer")
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
