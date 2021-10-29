//
//  OpaqueViewFactoryTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 6/13/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniCaptureSDK
final class OpaqueViewFactoryTests: XCTestCase {
    
    func testBlurStyle() {
        let opaqueView = OpaqueViewFactory.create(with: .blurred(style: .light)) as? UIVisualEffectView
        let blurEffect = opaqueView?.effect as? UIBlurEffect
        
        XCTAssertNotNil(opaqueView)
        XCTAssertNotNil(blurEffect)
    }
    
    func testDarkStyle() {
        let opaqueView = OpaqueViewFactory.create(with: .dimmed)
        
        XCTAssertEqual(opaqueView.backgroundColor, UIColor.black.withAlphaComponent(0.8))
    }
    
}
