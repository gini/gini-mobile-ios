//
//  GiniWeroNoResultsFlagOnUITests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest

/**
 Wero on No Results screen — client-configuration flag ON.
 The mock backend serves `weroQRCodeScanningEnabled == true` and empty
 extractions, so a Files-app upload of a non-payment QR code lands on the
 QR-flavoured No Results screen and the supported-formats list exposes the
 Wero row at slot 11.
 */
class GiniWeroNoResultsFlagOnUITests: GiniBankSDKExampleUITests {

    override var additionalLaunchArguments: [String] {
        ["-UITestMockScenario", "noResults",
         "-UITestMockClientConfig", "weroQRCodeScanningEnabled=true"]
    }

    /**
     With the Wero flag ON, the No Results QR screen must include a "Wero QR code"
     row in the supported-formats list.
     */
    func testWeroRowShownWhenFlagOn() {
        uploadDocumentViaFilesAndAwaitAnalysis(fileName: TestFixtures.Files.noResultsQR)
        XCTAssertTrue(noResultsScreen.waitForExistence(timeout: 30),
                      "No Results screen should appear after an empty-extractions QR upload.")
        XCTAssertTrue(noResultsScreen.weroFormatCell.waitForExistence(timeout: 10),
                      "Supported-formats list should include \"Wero QR code\" when the flag is ON.")
    }
}
