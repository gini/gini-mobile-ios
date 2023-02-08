//
//  GiniCaptureFontTests.swift
//  GiniCapture-Unit-Tests
//
//  Created by Enrique del Pozo Gómez on 1/23/19.
//

import XCTest
@testable import GiniCaptureSDK
final class GiniCaptureFontTests: XCTestCase {

    let font = GiniCaptureFont(regular: UIFont.systemFont(ofSize: 14, weight: .regular),
                              bold: UIFont.systemFont(ofSize: 14, weight: .bold),
                              light: UIFont.systemFont(ofSize: 14, weight: .light),
                              thin: UIFont.systemFont(ofSize: 14, weight: .thin),
                              isEnabled: false)
    
    override func setUp() {
        super.setUp()
    }
    
    func testRegularDynamicFontGeneration() {
        let dynamicFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: font.regular)
        XCTAssertEqual(dynamicFont, font.with(weight: .regular, size: 14, style: .body))
    }
    
    func testBoldDynamicFontGeneration() {
        let dynamicFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: font.bold)
        XCTAssertEqual(dynamicFont, font.with(weight: .bold, size: 14, style: .body))
    }
    
    func testThinDynamicFontGeneration() {
        let dynamicFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: font.thin)
        XCTAssertEqual(dynamicFont, font.with(weight: .thin, size: 14, style: .body))
    }
    
    func testLightDynamicFontGeneration() {
        let dynamicFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: font.light)
        XCTAssertEqual(dynamicFont, font.with(weight: .light, size: 14, style: .body))
    }
    
}
