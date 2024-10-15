//
//  SkontoIntegrationTests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest

@testable import GiniBankAPILibrary
@testable import GiniCaptureSDK
@testable import GiniBankSDK

class SkontoIntegrationTests: BaseIntegrationTest {

    func testExtractionsForSkonto() {
        let expect = expectation(description: "The skonto details extracted from the invoice were accurately compared against the static JSON.")
        let mockedInvoiceName = "Gini_invoice_example_skonto"
        let captureDelegate = CaptureResultsDelegate(testCase: self, expect: expect)
        uploadAndAnalyzeDocument(fileName: mockedInvoiceName,
                                 delegate: captureDelegate)
        wait(for: [expect], timeout: 60)
    }

    class CaptureResultsDelegate: GiniCaptureResultsDelegate {

        let testCase: SkontoIntegrationTests
        let expect: XCTestExpectation

        init(testCase: SkontoIntegrationTests, expect: XCTestExpectation) {
            self.testCase = testCase
            self.expect = expect
        }

        func giniCaptureAnalysisDidFinishWith(result: AnalysisResult) {
            let mockedInvoiceName = "result_Gini_invoice_example_skonto"
            guard let analysisExtractionResult = testCase.analysisExtractionResult,
                  let fixtureContainer = testCase.verifyExtractions(result: result,
                                                                    fileName: mockedInvoiceName) else {
                return
            }
            testCase.verifySkontoDiscounts(result: analysisExtractionResult, fixtureContainer: fixtureContainer)
            expect.fulfill()
        }

        func giniCaptureDidCancelAnalysis() {
            // nothing to test here
        }

        func giniCaptureDidEnterManually() {
            // nothing to test here
        }
    }
}
