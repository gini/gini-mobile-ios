//
//  ReviewViewControllerTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 5/11/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniCaptureSDK

extension UIControl {
    func simulateEvent(_ event: UIControl.Event) {
        for target in allTargets {
            let target = target as NSObjectProtocol
            for actionName in actions(forTarget: target, forControlEvent: event) ?? [] {
                let selector = Selector(actionName)
                target.perform(selector)
            }
        }
    }
}
//TODO: Fix the review button click event

//final class ReviewViewControllerTests: XCTestCase {
//
//    
//    var reviewViewController: ReviewViewController!
//    var reviewViewControllerDelegateMock: ReviewViewControllerDelegateMock!
    
//    func testDidReviewOnRotationWithDelegate() {
//        let document = GiniCaptureTestsHelper.loadImageDocument(named: "invoice")
//        reviewViewController = ReviewViewController(document: document, giniConfiguration: GiniConfiguration())
//        _ = reviewViewController.view
//
//        reviewViewControllerDelegateMock = ReviewViewControllerDelegateMock()
//        reviewViewController.delegate = reviewViewControllerDelegateMock
//        let reviewButton = reviewViewController.rotateButton
//        reviewButton.sendActions(for: .touchUpInside)
//
//        XCTAssertTrue(reviewViewControllerDelegateMock.isDocumentReviewed,
//                      "after tapping rotate button the document should have been modified and therefore the delegate" +
//                      "should be notified")
//    }
//}
