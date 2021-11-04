//
//  PageStateViewTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 4/13/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniCaptureSDK
final class PageStateViewTests: XCTestCase {
    
    var statusView: PageStateView!
    
    override func setUp() {
        super.setUp()
        statusView = PageStateView(frame: .zero)
    }
    
    func testLoadingState() {
        statusView.update(to: .loading)
        XCTAssertNil(statusView.icon.image, "icon image should be nil when it is loading")
        XCTAssertTrue(statusView.loadingIndicator.isAnimating, "loading indicator should be animating when loading")
    }
    
    func testSuccessState() {
        statusView.update(to: .succeeded)
        XCTAssertEqual(statusView.backgroundColor, Colors.Gini.springGreen, "background color should be green")
        XCTAssertEqual(statusView.icon.image,
                       UIImage(named: "successfullUploadIcon",
                               in: Bundle(for: GiniCapture.self),
                               compatibleWith: nil),
                       "icon image should match successfullUploadIcon asset")
        XCTAssertFalse(statusView.loadingIndicator.isAnimating,
                       "loading indicator should not be animating when loading")
    }
    
    func testFailureState() {
        statusView.update(to: .failed)
        XCTAssertEqual(statusView.backgroundColor, Colors.Gini.crimson, "background color should be red")
        XCTAssertEqual(statusView.icon.image,
                       UIImage(named: "failureUploadIcon",
                               in: Bundle(for: GiniCapture.self),
                               compatibleWith: nil),
                       "icon image should match failureUploadIcon asset")
        XCTAssertFalse(statusView.loadingIndicator.isAnimating,
                       "loading indicator should not be animating when loading")
    }
    
}
