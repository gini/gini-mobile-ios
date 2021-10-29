//
//  AnalysisViewControllerTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 10/5/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniCaptureSDK

final class AnalysisViewControllerTests: XCTestCase {
    
    func testPDFPagesCountLocalizedString() {
        let key = "ginicapture.analysis.pdfpages"
        let localizedStringFormat = NSLocalizedStringPreferredFormat(key,
                                                         comment: "Text appearing at the top of the " +
                                                                  "analysis screen indicating pdf number of pages")
        let localizedString = String(format: localizedStringFormat, arguments: [2])

        XCTAssertNotEqual(key, localizedString)
    }
}
