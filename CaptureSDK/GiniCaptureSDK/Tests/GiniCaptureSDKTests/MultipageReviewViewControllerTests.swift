//
//  MultipageReviewViewControllerTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 1/30/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniCaptureSDK
final class MultipageReviewViewControllerTests: XCTestCase {
    
    let giniConfiguration = GiniConfiguration.shared
    lazy var multipageReviewViewController: MultipageReviewViewController = {
        let vc = MultipageReviewViewController(pages: self.imagePages,
                                               giniConfiguration: self.giniConfiguration)
        _ = vc.view
        return vc
    }()
    
    var imagePages: [GiniCapturePage] = [
        GiniCaptureTestsHelper.loadImagePage(named: "invoice"),
        GiniCaptureTestsHelper.loadImagePage(named: "invoice2"),
        GiniCaptureTestsHelper.loadImagePage(named: "invoice3")
    ]
    
    func testCollectionsItemsCount() {
        XCTAssertEqual(multipageReviewViewController.collectionView.numberOfItems(inSection: 0), 3,
                       "main collection items count should be 3")
    }
    
    func testMainCollectionCellSize() {
        multipageReviewViewController.view.setNeedsLayout()
        multipageReviewViewController.view.layoutIfNeeded()
        
        let firstCellIndexPath = IndexPath(row: 0, section: 0)
        let cellSize = multipageReviewViewController.collectionView(multipageReviewViewController.collectionView,
                                         layout: multipageReviewViewController.collectionView.collectionViewLayout,
                                         sizeForItemAt: firstCellIndexPath)

        let itemSize: CGSize = {
            let width = multipageReviewViewController.view.bounds.width - 64
            let height = width * 1.4142 // A4 aspect ratio
            return CGSize(width: width, height: height)
        }()

        XCTAssertEqual(cellSize, itemSize,
                       "First cell image should match the one passed in the initializer")
    }
    
    func testMainCollectionInsets() {
        let collectionInsets = multipageReviewViewController
            .collectionView(multipageReviewViewController.collectionView,
                            layout: multipageReviewViewController.collectionView.collectionViewLayout,
                            insetForSectionAt: 0)
        
        XCTAssertEqual(collectionInsets, UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32),
                       "Main collection insets should be zero")
    }

// MARK: - Fix the test with tap event simulation

//    func testDatasourceOnDelete() {
//        let vc = MultipageReviewViewController(pages: imagePages,
//                                               giniConfiguration: giniConfiguration)
//        _ = vc.view
//        vc.view.setNeedsLayout()
//        vc.view.layoutIfNeeded()
//        if let button = (vc.deleteButton.customView as? UIButton){
//            button.simulateEvent(.touchUpInside)
//        }
//
//
//        //(vc.deleteButton.customView as? UIButton)?.sendActions(for: .touchUpInside)
//
//        XCTAssertEqual(vc.mainCollection.numberOfItems(inSection: 0), 2,
//                       "main collection items count should be 2")
//        XCTAssertEqual(vc.pagesCollection.numberOfItems(inSection: 0), 2,
//                       "pages collection items count should be 2")
//    }
}
