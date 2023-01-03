//
//  ImageAnalysisNoResultsViewControllerTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 10/16/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniCaptureSDK
final class ImageNoResultsViewControllerTests: XCTestCase {
    
    let viewControllerTitle = "Title"
    lazy var viewController: ImageAnalysisNoResultsViewController =
        ImageAnalysisNoResultsViewController(title: self.viewControllerTitle)
    lazy var items: [(image: UIImage?, text: String)] = [
        (UIImageNamedPreferred(named: "captureSuggestion1"),
         "Capture suggestion text 1"),
        (UIImageNamedPreferred(named: "captureSuggestion2"),
         "Capture suggestion text 2"),
        (UIImageNamedPreferred(named: "captureSuggestion3"),
         "Capture suggestion text 3"),
        (UIImageNamedPreferred(named: "captureSuggestion4"),
         "Capture suggestion text 4")
    ]
    
    override func setUp() {
        _ = viewController.view
        viewController.captureSuggestions = items
    }
    
    func testViewControllerTitleOnInitialization() {
        let vcTitle = viewController.title
        
        XCTAssertEqual(viewControllerTitle, vcTitle,
                       "view controller title should be equals to the one passed in the initialization")
    }
    
    func testSuggestionCollectionItemsCount() {
        let suggestionsCount = items.count
        
        let suggestionsCollectionItemsCount = viewController.collectionView(viewController.suggestionsCollectionView,
                                                                            numberOfItemsInSection: 0)
        
        XCTAssertEqual(suggestionsCount, suggestionsCollectionItemsCount,
                       "suggestionsCollectionView items count should be equal to captureSuggestions array count")
    }
    
    func testSecondSuggestionCell() {
        let indexPath = IndexPath(row: 1, section: 0)
        
        let suggestion2Text = items[indexPath.row].text
        let suggestion2Image = items[indexPath.row].image
        
        let suggestionCollectionCell = viewController
            .collectionView(viewController.suggestionsCollectionView,
                            cellForItemAt: indexPath) as? CaptureSuggestionsCollectionCell
        
        XCTAssertEqual(suggestion2Text, suggestionCollectionCell!.suggestionText.text,
                       "second suggestionsCollectionView item text should be " +
                       "equal to second captureSuggestions item text")
        XCTAssertEqual(suggestion2Image, suggestionCollectionCell!.suggestionImage.image,
                       "second suggestionsCollectionView item image should be equal to " +
                       "second captureSuggestions item image")
        
    }
    
    func testNoBottomButtonWhenNoText() {
        viewController = ImageAnalysisNoResultsViewController(bottomButtonText: nil)
        _ = viewController.view
        
        let bottomButton = viewController.bottomButton
        
        XCTAssertFalse(viewController.view.subviews.contains(bottomButton))
    }
}
