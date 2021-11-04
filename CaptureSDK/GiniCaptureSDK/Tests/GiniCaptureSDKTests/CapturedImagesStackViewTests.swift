//
//  CapturedImagesStackViewTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 5/7/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniCaptureSDK
final class CapturedImagesStackViewTests: XCTestCase {
    
    var capturedImagesStackView: CapturedImagesStackView!
    
    override func setUp() {
        super.setUp()
        capturedImagesStackView = CapturedImagesStackView()
    }
    
    func testCaptureStackWhenNoImages() {
        capturedImagesStackView.replaceStackImages(with: [])
        
        XCTAssertTrue(capturedImagesStackView.isHidden,
                      "capturedImagesStackView should be hidden when there are no images")
        
    }
    
    func testCaptureStackVisibilityWhenOneImageCaptured() {
        let images = [GiniCaptureTestsHelper.loadImage(named: "invoice")]
        
        capturedImagesStackView.replaceStackImages(with: images)
        
        XCTAssertFalse(capturedImagesStackView.isHidden,
                      "capturedImagesStackView should not be hidden when it is filled")
        XCTAssertTrue(capturedImagesStackView.thumbnailStackBackgroundView.isHidden,
                      "thumbnailStackBackgroundView should be hidden when there is only 1 image")
        
    }
    
    func testCaptureStackVisibilityWhenTwoImageCaptured() {
        let images = [GiniCaptureTestsHelper.loadImage(named: "invoice"),
                      GiniCaptureTestsHelper.loadImage(named: "invoice2")]
        capturedImagesStackView.replaceStackImages(with: images)

        XCTAssertFalse(capturedImagesStackView.thumbnailStackBackgroundView.isHidden,
                       "thumbnailStackBackgroundView should not be hidden when there are 2 images")

    }
    
    func testCaptureStackWhenTwoImageCaptured() {
        let images = [GiniCaptureTestsHelper.loadImage(named: "invoice"),
                      GiniCaptureTestsHelper.loadImage(named: "invoice2")]
        capturedImagesStackView.replaceStackImages(with: images)

        XCTAssertEqual(capturedImagesStackView.thumbnailButton.image(for: .normal), images[1],
                       "thumbnailButton image should match last image in array")
        
    }
    
    func testIndicatorLabelTextColor() {
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.imagesStackIndicatorLabelTextcolor = .black
        let stackView = CapturedImagesStackView(giniConfiguration: giniConfiguration)
        
        XCTAssertEqual(stackView.stackIndicatorLabel.textColor, giniConfiguration.imagesStackIndicatorLabelTextcolor,
                       "stack indicator label text color should match the one specified in the configuration")
    }
    
}
