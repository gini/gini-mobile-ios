//
//  TransferSummaryIntegrationTest.swift
//  GiniBankSDKExample
//
//  Created by Nadya Karaban on 06.04.22.
//

import XCTest
@testable import GiniBankAPILibrary
@testable import GiniCaptureSDK
@testable import GiniBankSDK

class TransferSummaryIntegrationTest: BaseIntegrationTest {

    func testSendTransferSummaryFeedback() {
        let mockedInvoiceName = "Gini_invoice_example_payment_reference"
        let expect = expectation(description: "Transfer summary was correctly sent and extractions were updated")
        uploadAndAnalyzeDocument(fileName: mockedInvoiceName,
                                 delegate: CaptureResultsDelegateForTransferSummaryTest(testCase: self, 
                                                                                        expect: expect),
                                 sendTransferSummaryIfNeeded: true)
        wait(for: [expect], timeout: 60)
    }

    class CaptureResultsDelegateForTransferSummaryTest: GiniCaptureResultsDelegate {
        let testCase: TransferSummaryIntegrationTest
        let expect: XCTestExpectation

        init(testCase: TransferSummaryIntegrationTest, expect: XCTestExpectation) {
            self.testCase = testCase
            self.expect = expect
        }

        func giniCaptureAnalysisDidFinishWith(result: AnalysisResult) {
            let mockedInvoice = "result_Gini_invoice_example_payment_reference"
            // Use the helper method to load the fixture extractions container
            guard let fixtureExtractionsContainer = testCase.loadFixtureExtractionsContainer(from: mockedInvoice) else {
                return
            }

            // Verify the extractions
            testCase.verifyExtractions(result: result, fixtureContainer: fixtureExtractionsContainer)

            // Call the updateAndVerifyTransferSummary method to handle the transfer summary update
            testCase.updateAndVerifyTransferSummary(result: result, expect: expect)
        }

        func giniCaptureDidCancelAnalysis() {
            // nothing to test here
        }

        func giniCaptureDidEnterManually() {
            // nothing to test heretestCase
        }
    }
}
