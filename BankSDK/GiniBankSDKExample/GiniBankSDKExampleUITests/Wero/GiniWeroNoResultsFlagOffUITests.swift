//
//  GiniWeroNoResultsFlagOffUITests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest

/**
 Wero on No Results screen — client-configuration flag OFF (default).
 The mock backend serves `weroQRCodeScanningEnabled == false` and empty
 extractions, so a Files-app upload of a non-payment QR code lands on the
 QR-flavoured No Results screen and the supported-formats list does NOT
 expose the Wero row.
 */
class GiniWeroNoResultsFlagOffUITests: GiniBankSDKExampleUITests {

    override var additionalLaunchArguments: [String] {
        ["-UITestMockScenario", "noResults",
         "-UITestMockClientConfig", "weroQRCodeScanningEnabled=false"]
    }

    /**
     With the Wero flag OFF, the No Results QR screen must not expose a
     "Wero QR code" row in the supported-formats list.
     */
    func testWeroRowHiddenWhenFlagOff() {
        uploadDocumentViaFilesAndAwaitAnalysis(fileName: TestFixtures.Files.noResultsQR)
        XCTAssertTrue(noResultsScreen.waitForExistence(timeout: 30),
                      "No Results screen should appear after an empty-extractions QR upload.")
        XCTAssertFalse(noResultsScreen.weroFormatCell.waitForExistence(timeout: 5),
                       "Supported-formats list must not include \"Wero QR code\" when the flag is OFF.")
    }
}
