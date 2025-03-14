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
        let delegate = CaptureResultsDelegateForTransferSummaryTest(testCase: self,
                                                                    mockedInvoiceResultName: "result_Gini_invoice_example_payment_reference",
                                                                    mockedInvoiceResultAfterFeedbackName: "result_Gini_invoice_example_payment_reference_after_feedback",
                                                                    expect: expect)
        uploadAndAnalyzeDocument(fileName: mockedInvoiceName,
                                 delegate: delegate)
        wait(for: [expect], timeout: 30)
    }

    class CaptureResultsDelegateForTransferSummaryTest: GiniCaptureResultsDelegate {
        let testCase: TransferSummaryIntegrationTest
        let mockedInvoiceResultName: String
        let mockedInvoiceResultAfterFeedbackName: String
        let expect: XCTestExpectation

        init(testCase: TransferSummaryIntegrationTest,
             mockedInvoiceResultName: String,
             mockedInvoiceResultAfterFeedbackName: String,
             expect: XCTestExpectation) {
            self.testCase = testCase
            self.mockedInvoiceResultName = mockedInvoiceResultName
            self.mockedInvoiceResultAfterFeedbackName = mockedInvoiceResultAfterFeedbackName
            self.expect = expect
        }

        func giniCaptureAnalysisDidFinishWith(result: AnalysisResult) {
            GiniBankConfiguration.shared.sendTransferSummary(
                paymentRecipient: result.extractions["paymentRecipient"]?.value ?? "",
                paymentReference: result.extractions["paymentReference"]?.value ?? "",
                paymentPurpose: result.extractions["paymentPurpose"]?.value ?? "",
                iban: result.extractions["iban"]?.value ?? "",
                bic: result.extractions["bic"]?.value ?? "",
                amountToPay: ExtractionAmount(value: 950.00, currency: .EUR)
            )
            
            let mockedInvoice = mockedInvoiceResultName
            // Use the helper method to load the fixture extractions container
            guard let fixtureExtractionsContainer = testCase.loadFixtureExtractionsContainer(from: mockedInvoice) else {
                return
            }

            // Verify the extractions
            testCase.verifyExtractions(result: result, fixtureContainer: fixtureExtractionsContainer)

            // Call the updateAndVerifyTransferSummary method to handle the transfer summary update
            testCase.updateAndVerifyTransferSummary(result: result,
                                                    mockedInvoiceUpdatedResultName: mockedInvoiceResultAfterFeedbackName,
                                                    expect: expect)
        }

        func giniCaptureDidCancelAnalysis() {
            // nothing to test here
        }

        func giniCaptureDidEnterManually() {
            // nothing to test heretestCase
        }
    }
}
