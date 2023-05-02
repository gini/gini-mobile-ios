//
//  ReviewViewControllerTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 1/30/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniCaptureSDK
final class ReviewViewControllerTests: XCTestCase {
    
    let giniConfiguration = GiniConfiguration.shared
    lazy var reviewViewController: ReviewViewController = {
        let vc = ReviewViewController(pages: self.imagePages,
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
        XCTAssertEqual(reviewViewController.collectionView.numberOfItems(inSection: 0), 3,
                       "main collection items count should be 3")
    }
    
    func testMainCollectionCellSize() {
        reviewViewController.view.setNeedsLayout()
        reviewViewController.view.layoutIfNeeded()
        
        let firstCellIndexPath = IndexPath(row: 0, section: 0)
        let cellSize = reviewViewController.collectionView(reviewViewController.collectionView,
                                         layout: reviewViewController.collectionView.collectionViewLayout,
                                         sizeForItemAt: firstCellIndexPath)

        let itemSize: CGSize = {
            let a4Ratio = 1.4142
            if UIDevice.current.isIpad {
                let height = reviewViewController.view.bounds.height - 260
                let width = height / a4Ratio
                return CGSize(width: width, height: height)
            } else {
                if reviewViewController.view.safeAreaInsets.bottom > 0 {
                    let height = reviewViewController.view.bounds.height * 0.6
                    let width = height / a4Ratio
                    let cellSize = CGSize(width: width, height: height)
                    return cellSize
                } else {
                    let height = reviewViewController.view.bounds.height * 0.5
                    let width = height / a4Ratio
                    let cellSize = CGSize(width: width, height: height)
                    return cellSize
                }
            }
        }()

        XCTAssertEqual(cellSize, itemSize,
                       "First cell image should match the one passed in the initializer")
    }
    
    func testMainCollectionInsets() {
        let collectionInsets = reviewViewController
            .collectionView(reviewViewController.collectionView,
                            layout: reviewViewController.collectionView.collectionViewLayout,
                            insetForSectionAt: 0)

        let itemSize: CGSize = {
            let a4Ratio = 1.4142
            if UIDevice.current.isIpad {
                let height = reviewViewController.view.bounds.height - 260
                let width = height / a4Ratio
                return CGSize(width: width, height: height)
            } else {
                if reviewViewController.view.safeAreaInsets.bottom > 0 {
                    let height = reviewViewController.view.bounds.height * 0.6
                    let width = height / a4Ratio
                    let cellSize = CGSize(width: width, height: height)
                    return cellSize
                } else {
                    let height = reviewViewController.view.bounds.height * 0.5
                    let width = height / a4Ratio
                    let cellSize = CGSize(width: width, height: height)
                    return cellSize
                }
            }
        }()

        let margin = (reviewViewController.view.bounds.width - itemSize.width) / 2
        let calculatedInset = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
        XCTAssertEqual(collectionInsets, calculatedInset, "Main collection insets should be zero")
    }

// MARK: - Fix the test with tap event simulation

//    func testDatasourceOnDelete() {
//        let vc = ReviewViewController(pages: imagePages,
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
