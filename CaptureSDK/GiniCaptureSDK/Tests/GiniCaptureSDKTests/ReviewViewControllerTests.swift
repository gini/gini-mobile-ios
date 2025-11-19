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

    // MARK: - Helper Methods

    private func calculateExpectedItemSize() -> CGSize {
        let a4Ratio = 1.4142

        if UIDevice.current.isIpad {
            var availableHeight = reviewViewController.view.bounds.height
            availableHeight -= 260 // Base overhead

            if giniConfiguration.bottomNavigationBarEnabled {
                availableHeight -= 114 // Bottom navigation bar height
                availableHeight -= 16 // Padding
            }

            // Note: Not accounting for saveToGalleryView in test for simplicity

            let width = availableHeight / a4Ratio
            return CGSize(width: width, height: availableHeight)
        } else {
            // iPhone - replicate calculateHeightMultiplier() logic
            let multiplier = calculateExpectedHeightMultiplier()
            let height = reviewViewController.view.bounds.height * multiplier
            let width = height / a4Ratio
            return CGSize(width: width, height: height)
        }
    }

    private func calculateExpectedHeightMultiplier() -> CGFloat {
        let isLandscape = UIDevice.current.isLandscape
        let isSmallDevice = UIDevice.current.isNonNotchSmallScreen()

        if isSmallDevice {
            return isLandscape ? 0.5 : 0.45
        } else if isLandscape {
            return 0.55
        } else {
            // Portrait
            let baseMultiplier: CGFloat
            if reviewViewController.view.safeAreaInsets.bottom > 0 {
                // Device with safe area (notch)
                baseMultiplier = giniConfiguration.bottomNavigationBarEnabled ? 0.52 : 0.6
            } else {
                // Device without safe area
                baseMultiplier = giniConfiguration.bottomNavigationBarEnabled ? 0.42 : 0.5
            }
            return baseMultiplier
        }
    }

    // MARK: - Tests

    func testCollectionsItemsCount() {
        XCTAssertEqual(reviewViewController.collectionView.numberOfItems(inSection: 0),
                       3,
                       "main collection items count should be 3")
    }

    func testMainCollectionCellSize() {
        reviewViewController.view.setNeedsLayout()
        reviewViewController.view.layoutIfNeeded()

        let firstCellIndexPath = IndexPath(row: 0, section: 0)
        let cellSize = reviewViewController.collectionView(
            reviewViewController.collectionView,
            layout: reviewViewController.collectionView.collectionViewLayout,
            sizeForItemAt: firstCellIndexPath
        )

        let expectedItemSize = calculateExpectedItemSize()

        XCTAssertEqual(cellSize,
                       expectedItemSize,
                       "Cell size should match the calculated item size")
    }

    func testMainCollectionInsets() {
        let collectionInsets = reviewViewController.collectionView(
            reviewViewController.collectionView,
            layout: reviewViewController.collectionView.collectionViewLayout,
            insetForSectionAt: 0
        )

        let itemSize = calculateExpectedItemSize()
        let margin = (reviewViewController.view.bounds.width - itemSize.width) / 2
        let expectedInset = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)

        XCTAssertEqual(collectionInsets,
                       expectedInset,
                       "Main collection insets should match calculated values")
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
