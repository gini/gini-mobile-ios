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
        XCTAssertEqual(multipageReviewViewController.mainCollection.numberOfItems(inSection: 0), 3,
                       "main collection items count should be 3")
        
        XCTAssertEqual(multipageReviewViewController.pagesCollection.numberOfItems(inSection: 0), 3,
                       "pages collection items count should be 3")
    }
    
    func testMainCollectionCellSize() {
        multipageReviewViewController.view.setNeedsLayout()
        multipageReviewViewController.view.layoutIfNeeded()
        
        let firstCellIndexPath = IndexPath(row: 0, section: 0)
        let cellSize = multipageReviewViewController.collectionView(multipageReviewViewController.mainCollection,
                                         layout: multipageReviewViewController.mainCollection.collectionViewLayout,
                                         sizeForItemAt: firstCellIndexPath)
        
        XCTAssertEqual(cellSize, multipageReviewViewController.mainCollection.frame.size,
                       "First cell image should match the one passed in the initializer")
    }
    
    func testMainCollectionInsets() {
        let collectionInsets = multipageReviewViewController
            .collectionView(multipageReviewViewController.mainCollection,
                            layout: multipageReviewViewController.mainCollection.collectionViewLayout,
                            insetForSectionAt: 0)
        
        XCTAssertEqual(collectionInsets, .zero,
                       "Main collection insets should be zero")
    }
    
    func testPagesCollectionCellsIndex() {
        let firstCell = multipageReviewViewController
            .collectionView(multipageReviewViewController.pagesCollection,
                            cellForItemAt: IndexPath(row: 0, section: 0)) as? MultipageReviewPagesCollectionCell
        let secondCell = multipageReviewViewController
            .collectionView(multipageReviewViewController.pagesCollection,
                            cellForItemAt: IndexPath(row: 1, section: 0)) as? MultipageReviewPagesCollectionCell
        let thirdCell = multipageReviewViewController
            .collectionView(multipageReviewViewController.pagesCollection,
                            cellForItemAt: IndexPath(row: 2, section: 0)) as? MultipageReviewPagesCollectionCell
        XCTAssertEqual(firstCell?.pageIndicatorLabel.text, "1",
                       "First cell indicator should match its position")
        XCTAssertEqual(secondCell?.pageIndicatorLabel.text, "2",
                       "Second cell indicator should match its position")
        XCTAssertEqual(thirdCell?.pageIndicatorLabel.text, "3",
                       "Third cell indicator should match its position")
    }
    
    func testPagesCollectionCellSize() {
        multipageReviewViewController.view.setNeedsLayout()
        multipageReviewViewController.view.layoutIfNeeded()
        
        let firstCellIndexPath = IndexPath(row: 0, section: 0)
        let cellSize = multipageReviewViewController.collectionView(multipageReviewViewController.pagesCollection,
                                         layout: multipageReviewViewController.pagesCollection.collectionViewLayout,
                                         sizeForItemAt: firstCellIndexPath)
        
        let size = MultipageReviewPagesCollectionCell.size(in: multipageReviewViewController.pagesCollection)
        
        XCTAssertEqual(cellSize, size,
                       "Pages collection cells should have the value declared in the class")
    }
    
    func testPagesCollectionInsets() {
        let collectionInsets = multipageReviewViewController
            .collectionView(multipageReviewViewController.pagesCollection,
                            layout: multipageReviewViewController.pagesCollection.collectionViewLayout,
                            insetForSectionAt: 0)
        
        XCTAssertEqual(collectionInsets, multipageReviewViewController.pagesCollectionInsets,
                       "Main collection insets should be zero")
    }
    
    func testToolBarItemsOnInitialization() {
        guard let items = self.multipageReviewViewController.toolBar.items else {
            assertionFailure("MultipageReviewViewController toolbar items are nil")
            return
        }
        XCTAssertEqual(items[1], self.multipageReviewViewController.rotateButton,
                       "First toolbar item should be the rotateButton")
        XCTAssertEqual(items[4], self.multipageReviewViewController.deleteButton,
                       "Fifth toolbar item should be the deleteButton")
    }
    
    func testToolBarTintColor() {
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.multipagePagesContainerAndToolBarColor = GiniColor(lightModeColor: .black, darkModeColor: .black)
        let multipageReviewViewController = MultipageReviewViewController(pages: [],
                                                                          giniConfiguration: giniConfiguration)
        
        XCTAssertEqual(multipageReviewViewController.toolBar.barTintColor?.cgColor,
                       UIColor.from(giniColor: giniConfiguration.multipagePagesContainerAndToolBarColor).cgColor,
                       "toolbar tint color should match the one specified in the configuration")
    }
    
    func testPagesContainerBackgroundColor() {
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.multipagePagesContainerAndToolBarColor = GiniColor(lightModeColor: .black, darkModeColor: .black)
        let multipageReviewViewController = MultipageReviewViewController(pages: [],
                                                                          giniConfiguration: giniConfiguration)
        
        XCTAssertEqual(multipageReviewViewController.pagesCollectionContainer.backgroundColor?.cgColor,
                       UIColor.from(giniColor: giniConfiguration.multipagePagesContainerAndToolBarColor).cgColor,
                       "pages container background color should match the one specified in the gini configuration")
    }
    
    func testToolbarItemsColor() {
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.multipageToolbarItemsColor = .black
        let multipageReviewViewController = MultipageReviewViewController(pages: [],
                                                                          giniConfiguration: giniConfiguration)
        
        _ = multipageReviewViewController.view
        XCTAssertEqual((multipageReviewViewController.deleteButton.customView as? UIButton)?.tintColor,
                       giniConfiguration.multipageToolbarItemsColor,
                       "delete button tint color should match the one specified in the gini configuration")
        XCTAssertEqual((multipageReviewViewController.rotateButton.customView as? UIButton)?.tintColor,
                       giniConfiguration.multipageToolbarItemsColor,
                       "rotate button tint color should match the one specified in the gini configuration")
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
    
    func testDeleteButtonDisabledWhenToolTipIsShown() {
        ToolTipView.shouldShowReorderPagesButtonToolTip = true
        
        multipageReviewViewController = MultipageReviewViewController(pages: imagePages,
                                                                      giniConfiguration: giniConfiguration)
        _ = multipageReviewViewController.view
        multipageReviewViewController.viewDidAppear(false)
        
        XCTAssertFalse(multipageReviewViewController.deleteButton.isEnabled,
                       "delete button should be disabled when tooltip is shown")
        
    }
    
    func testDeleteButtonEnabledWhenToolTipIsNotShown() {
        ToolTipView.shouldShowReorderPagesButtonToolTip = false
        
        multipageReviewViewController = MultipageReviewViewController(pages: imagePages,
                                                                      giniConfiguration: giniConfiguration)
        _ = multipageReviewViewController.view
        multipageReviewViewController.viewDidAppear(false)
        
        XCTAssertTrue(multipageReviewViewController.deleteButton.isEnabled,
                       "delete button should be disabled when tooltip is shown")
        
    }
    
    func testRotateButtonDisabledWhenToolTipIsShown() {
        ToolTipView.shouldShowReorderPagesButtonToolTip = true

        multipageReviewViewController = MultipageReviewViewController(pages: imagePages,
                                                                      giniConfiguration: giniConfiguration)
        _ = multipageReviewViewController.view
        multipageReviewViewController.viewDidAppear(false)

        XCTAssertFalse(multipageReviewViewController.rotateButton.isEnabled,
                       "rotate button should be disabled when tooltip is shown")
        
    }
    
    func testRotateButtonEnabledWhenToolTipIsNotShown() {
        ToolTipView.shouldShowReorderPagesButtonToolTip = false
        
        multipageReviewViewController = MultipageReviewViewController(pages: imagePages,
                                                                      giniConfiguration: giniConfiguration)
        _ = multipageReviewViewController.view
        multipageReviewViewController.viewDidAppear(false)
        
        XCTAssertTrue(multipageReviewViewController.rotateButton.isEnabled,
                       "rotate button should be disabled when tooltip is shown")
        
    }
    
    func testToolTipShouldAppearTheFirstTime() {
        ToolTipView.shouldShowReorderPagesButtonToolTip = true
        
        multipageReviewViewController = MultipageReviewViewController(pages: imagePages,
                                                                      giniConfiguration: giniConfiguration)
        _ = multipageReviewViewController.view
        
        XCTAssertNotNil(multipageReviewViewController.reorderContainerTooltipView,
                     "rotate button should be disabled when tooltip is shown")
        
    }
    
    func testToolTipShouldNotAppearWhenItWasShownBefore() {
        ToolTipView.shouldShowReorderPagesButtonToolTip = false
        
        multipageReviewViewController = MultipageReviewViewController(pages: imagePages,
                                                                      giniConfiguration: giniConfiguration)
        _ = multipageReviewViewController.view
        
        XCTAssertNil(multipageReviewViewController.reorderContainerTooltipView,
                     "rotate button should be disabled when tooltip is shown")
        
    }
    
    func testSelectingItemAtNegativePositionSelectsFirstItem() {
        ToolTipView.shouldShowReorderPagesButtonToolTip = false
        
        multipageReviewViewController = MultipageReviewViewController(pages: imagePages,
                                                                      giniConfiguration: giniConfiguration)
        _ = multipageReviewViewController.view
        
        multipageReviewViewController.selectItem(at: -1)
        
        XCTAssertEqual(multipageReviewViewController.pagesCollection.indexPathsForSelectedItems?[0].row, 0,
                       "pages collection selected item position should be 0")
    }
    
    func testSelectingItemAtOutOfUpperBoundPositionSelectsFirstItem() {
        ToolTipView.shouldShowReorderPagesButtonToolTip = false
        
        multipageReviewViewController = MultipageReviewViewController(pages: imagePages,
                                                                      giniConfiguration: giniConfiguration)
        _ = multipageReviewViewController.view
        
        multipageReviewViewController.selectItem(at: imagePages.count)
        
        XCTAssertEqual(multipageReviewViewController.pagesCollection.indexPathsForSelectedItems?[0].row, 0,
                       "pages collection selected item position should be 0")
    }
    
    func testSelectingItemDoesNothingIfPagesIsEmpty() {
        ToolTipView.shouldShowReorderPagesButtonToolTip = false
        
        multipageReviewViewController = MultipageReviewViewController(pages: [],
                                                                      giniConfiguration: giniConfiguration)
        _ = multipageReviewViewController.view
        
        multipageReviewViewController.selectItem(at: 1)
        
        XCTAssertEqual(multipageReviewViewController.pagesCollection.indexPathsForSelectedItems?.count, 0,
                       "pages collection has no selected items")
    }
}
