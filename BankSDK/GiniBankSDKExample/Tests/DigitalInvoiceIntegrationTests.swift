//
//  DigitalInvoiceIntegrationTests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankAPILibrary
@testable import GiniCaptureSDK
@testable import GiniBankSDK

class DigitalInvoiceIntegrationTests: BaseIntegrationTest {
    func testExtractionsForLineItemsWithDiscount() {
        let expect = expectation(description: "The line items extracted from the invoice were accurately compared against the static JSON.")
        let mockedInvoiceName = "Gini_invoice_example_line_items_with_discount"
        uploadAndAnalyzeDocument(fileName: mockedInvoiceName,
                                 delegate: CaptureResultsDelegate(testCase: self, expect: expect))
        wait(for: [expect], timeout: 60)
    }

    class CaptureResultsDelegate: GiniCaptureResultsDelegate {

        let testCase: DigitalInvoiceIntegrationTests
        let expect: XCTestExpectation

        init(testCase: DigitalInvoiceIntegrationTests, expect: XCTestExpectation) {
            self.testCase = testCase
            self.expect = expect
        }

        func giniCaptureAnalysisDidFinishWith(result: AnalysisResult) {
            let mockedInvoiceName = "result_Gini_invoice_example_line_items_with_discount"
            testCase.verifyExtractions(result: result,
                                       fileName: mockedInvoiceName,
                                       verifyLineItemsIfNeeded: true)
            self.expect.fulfill()
        }

        func giniCaptureDidCancelAnalysis() {
            // nothing to test here
        }

        func giniCaptureDidEnterManually() {
            // nothing to test here
        }
    }
}
