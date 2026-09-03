//
//  GiniCreditNoteMockBackendFlagOffUITests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest

/**
 Credit Note Warning flag matrix — frontend (backend client configuration) flag OFF.
 The mock backend serves `creditNoteHintEnabled == false`; see
 `GiniBankSDKExampleUITests+CreditNote.swift` for the full matrix and shared journeys.
 */
class GiniCreditNoteMockBackendFlagOffUITests: GiniBankSDKExampleUITests {

    override var additionalLaunchArguments: [String] {
        ["-UITestMockScenario", "creditNote",
         "-UITestMockClientConfig", "creditNoteHintEnabled=false"]
    }

    /**
     Frontend flag OFF + SDK flag ON — no warning, processed like an invoice.
     */
    func testWarningNotShownWhenSdkFlagOn() {
        uploadDocumentViaFilesAndAwaitAnalysis(fileName: TestFixtures.Files.creditNote)
        assertProcessedLikeRegularInvoice()
    }

    /**
     Frontend flag OFF + SDK flag OFF — no warning, processed like an invoice.
     */
    func testWarningNotShownWhenSdkFlagOff() {
        disableCreditNoteSdkFlag()
        uploadDocumentViaFilesAndAwaitAnalysis(fileName: TestFixtures.Files.creditNote)
        assertProcessedLikeRegularInvoice()
    }
}
