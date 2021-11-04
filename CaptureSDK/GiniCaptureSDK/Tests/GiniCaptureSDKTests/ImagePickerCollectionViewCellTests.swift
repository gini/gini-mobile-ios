//
//  ImagePickerCollectionViewCellTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 5/24/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniCaptureSDK
final class ImagePickerCollectionViewCellTests: XCTestCase {
    
    let cell = ImagePickerCollectionViewCell(frame: .zero)

    func testCellCheckIndicatorBackgroundOnSelected() {
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.galleryPickerItemSelectedBackgroundCheckColor = .black
        
        cell.changeCheckCircle(to: true, giniConfiguration: giniConfiguration)
        
        XCTAssertEqual(cell.checkImage.alpha, 1, "check image should be visible when cell is selected")
        XCTAssertEqual(cell.checkCircleBackground.backgroundColor,
                       giniConfiguration.galleryPickerItemSelectedBackgroundCheckColor,
                       "check circle background should match the one specified in the GiniConfiguration")
    }
    
    func testCellCheckIndicatorBackgroundOnDeselected() {
        let giniConfiguration = GiniConfiguration()
        
        cell.changeCheckCircle(to: false, giniConfiguration: giniConfiguration)
        XCTAssertEqual(cell.checkImage.alpha, 0, "check image should not be visible when cell is selected")
        XCTAssertEqual(cell.checkCircleBackground.backgroundColor,
                       UIColor.clear, "check circle background should be transparent when cell is not selected")

    }
}
