//
//  OpenWithTutorialViewControllerTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 10/20/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniCaptureSDK
final class OpenWithTutorialViewControllerTests: XCTestCase {
    
    let openWithTutorialViewController = OpenWithTutorialViewController()
    
    lazy var items: [OpenWithTutorialStep] = [
        (NSLocalizedStringPreferredFormat("ginicapture.help.openWithTutorial.step1.title",
                                    comment: "first step title for open with tutorial"),
         NSLocalizedStringPreferredFormat("ginicapture.help.openWithTutorial.step1.subTitle",
                                    comment: "first step subtitle for open with tutorial"),
         UIImageNamedPreferred(named: .localized(resource: ImageAssetsStrings.openWithTutorialStep1))),
        (NSLocalizedStringPreferredFormat("ginicapture.help.openWithTutorial.step2.title",
                                    comment: "second step title for open with tutorial"),
         String(format: NSLocalizedStringPreferredFormat("ginicapture.help.openWithTutorial.step2.subTitle",
                                                   comment: "second step subtitle for open with tutorial"),
                self.openWithTutorialViewController.appName, self.openWithTutorialViewController.appName),
         UIImageNamedPreferred(named: .localized(resource: ImageAssetsStrings.openWithTutorialStep2))),
        (NSLocalizedStringPreferredFormat("ginicapture.help.openWithTutorial.step3.title",
                                    comment: "third step title for open with tutorial"),
         String(format: NSLocalizedStringPreferredFormat("ginicapture.help.openWithTutorial.step3.subTitle",
                                                   comment: "third step subtitle for open with tutorial"),
                self.openWithTutorialViewController.appName,
                self.openWithTutorialViewController.appName,
                self.openWithTutorialViewController.appName),
         UIImageNamedPreferred(named: .localized(resource: ImageAssetsStrings.openWithTutorialStep3)))
    ]
    
    override func setUp() {
        super.setUp()
        _ = openWithTutorialViewController.view
    }
    
    func testSectionCount() {
        let sectionsCount = openWithTutorialViewController
            .numberOfSections(in: openWithTutorialViewController.collectionView!)
        
        XCTAssertEqual(sectionsCount, 1, "sections count should always be 1")
    }
    
    func testCollectionItemsCount() {        
        let collectionSection0ItemsCount = openWithTutorialViewController
            .collectionView(openWithTutorialViewController.collectionView!, numberOfItemsInSection: 0)
        
        XCTAssertEqual(items.count, collectionSection0ItemsCount,
                       "the items count in section 0 should be the same as the one declared on initialization")
    }
    
    func testFirstStepProperties() {
        let indexPath = IndexPath(row: 0, section: 0)
        let item = items[indexPath.row]
        
        let cell = openWithTutorialViewController
            .collectionView(openWithTutorialViewController.collectionView!,
                            cellForItemAt: indexPath) as? OpenWithTutorialCollectionCell
        
        XCTAssertEqual(cell!.stepIndicator.text, String(describing: indexPath.row + 1),
                       "step indicator for first step should be the same as the one declared on initialisation")
        XCTAssertEqual(cell!.stepTitle.text, item.title,
                       "step title for first step should be the same as the one declared on initialisation")
        XCTAssertEqual(cell!.stepSubTitle.text, item.subtitle,
                       "step subtitle for first step should be the same as the one declared on initialisation")
        XCTAssertEqual(cell!.stepImage.image, item.image,
                       "step image for first step should be the same as the one declared on initialisation")
    }
    
    func testSecondStepProperties() {
        let indexPath = IndexPath(row: 1, section: 0)
        let item = items[indexPath.row]
        
        let cell = openWithTutorialViewController
            .collectionView(openWithTutorialViewController.collectionView!,
                            cellForItemAt: indexPath) as? OpenWithTutorialCollectionCell
        
        XCTAssertEqual(cell!.stepIndicator.text, String(describing: indexPath.row + 1),
                       "step indicator for second step should be the same as the one declared on initialisation")
        XCTAssertEqual(cell!.stepTitle.text, item.title,
                       "step title for second step should be the same as the one declared on initialisation")
        XCTAssertEqual(cell!.stepSubTitle.text, item.subtitle,
                       "step subtitle for second step should be the same as the one declared on initialisation")
        XCTAssertEqual(cell!.stepImage.image, item.image,
                       "step image for second step should be the same as the one declared on initialisation")
    }
    
    func testThirdStepProperties() {
        let indexPath = IndexPath(row: 2, section: 0)
        let item = items[indexPath.row]
        
        let cell = openWithTutorialViewController
            .collectionView(openWithTutorialViewController.collectionView!,
                            cellForItemAt: indexPath) as? OpenWithTutorialCollectionCell
        
        XCTAssertEqual(cell!.stepIndicator.text, String(describing: indexPath.row + 1),
                       "step indicator for third step should be the same as the one declared on initialisation")
        XCTAssertEqual(cell!.stepTitle.text, item.title,
                       "step title for third step should be the same as the one declared on initialisation")
        XCTAssertEqual(cell!.stepSubTitle.text, item.subtitle,
                       "step for third step subtitle should be the same as the one declared on initialisation")
        XCTAssertEqual(cell!.stepImage.image, item.image,
                       "step image for third step should be the same as the one declared on initialisation")
    }

    func testHeaderDissapearInLandscape() {
        let collectionView = openWithTutorialViewController.collectionView!
        openWithTutorialViewController.view.frame.size = CGSize(width: 1, height: 0) // Simulate landscape
        
        let headerSize = openWithTutorialViewController
            .collectionView(collectionView,
                            layout: collectionView.collectionViewLayout,
                            referenceSizeForHeaderInSection: 0)
        
        XCTAssertEqual(headerSize.height, 0, "header size should be 0 on landscape mode")
        
    }
    
    func testItemsWhenDragAndDropTipDoesNotAppear() {
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.shouldShowDragAndDropTutorial = false
        
        let openWithTutorialViewController = OpenWithTutorialViewController(giniConfiguration: giniConfiguration)
        let dragAndDropStepImage =  UIImage(named: "openWithTutorialStep3", in: Bundle.module, compatibleWith: nil)
        
        XCTAssertFalse(openWithTutorialViewController.items.map { $0.image }.contains(dragAndDropStepImage),
                      "open with items should not contain drag and drop image")
    }
}
