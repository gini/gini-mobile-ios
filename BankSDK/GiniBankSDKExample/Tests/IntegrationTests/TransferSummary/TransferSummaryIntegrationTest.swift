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

    func testSendTransferSummary() {
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

    func testSendTransferSummaryWithInstantPayment() {
        let mockedInvoiceName = "Gini_invoice_example_instant_payment_remslips"
        let mockedInvoiceResultName = "result_Gini_invoice_example_instant_payment_remslips"
        let mockedInvoiceResultAfterFeedbackName = "result_Gini_invoice_example_instant_payment_remslips_after_feedback"
        let expect = expectation(description: "Transfer summary was correctly sent and extractions were updated")
        let delegate = CaptureResultsDelegateForTransferSummaryTest(testCase: self,
                                                                    mockedInvoiceResultName: mockedInvoiceResultName,
                                                                    mockedInvoiceResultAfterFeedbackName: mockedInvoiceResultAfterFeedbackName,
                                                                    verifyInstantPayment: true,
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
        let verifyInstantPayment: Bool?

        init(testCase: TransferSummaryIntegrationTest,
             mockedInvoiceResultName: String,
             mockedInvoiceResultAfterFeedbackName: String,
             verifyInstantPayment: Bool? = nil,
             expect: XCTestExpectation) {
            self.testCase = testCase
            self.mockedInvoiceResultName = mockedInvoiceResultName
            self.mockedInvoiceResultAfterFeedbackName = mockedInvoiceResultAfterFeedbackName
            self.verifyInstantPayment = verifyInstantPayment
            self.expect = expect
        }

        func giniCaptureAnalysisDidFinishWith(result: AnalysisResult) {
            sentTransferSummery(result: result, verifyInstantPayment: verifyInstantPayment)
            let mockedInvoice = mockedInvoiceResultName
            // Use the helper method to load the fixture extractions container
            guard let fixtureExtractionsContainer = testCase.loadFixtureExtractionsContainer(from: mockedInvoice) else {
                return
            }

            // Verify the extractions
            testCase.verifyExtractions(result: result,
                                       fixtureContainer: fixtureExtractionsContainer,
                                       verifyInstantPayment: verifyInstantPayment)

            // Call the updateAndVerifyTransferSummary method to handle the transfer summary update
            testCase.updateAndVerifyTransferSummary(result: result,
                                                    mockedInvoiceUpdatedResultName: mockedInvoiceResultAfterFeedbackName,
                                                    expect: expect)
        }

        private func sentTransferSummery(result: AnalysisResult, verifyInstantPayment: Bool?) {
            var instantPaymentString = ""
            var instantPayment: Bool?
            if let instantPaymentExtractionResult = result.extractions["instantPayment"] {
                instantPaymentString = instantPaymentExtractionResult.value
                instantPayment = verifyInstantPayment == true ? (instantPaymentString.lowercased() == "true") : nil
            }

            GiniBankConfiguration.shared.sendTransferSummary(
                paymentRecipient: result.extractions["paymentRecipient"]?.value ?? "",
                paymentReference: result.extractions["paymentReference"]?.value ?? "",
                paymentPurpose: result.extractions["paymentPurpose"]?.value ?? "",
                iban: result.extractions["iban"]?.value ?? "",
                bic: result.extractions["bic"]?.value ?? "",
                amountToPay: ExtractionAmount(value: 950.00, currency: .EUR),
                instantPayment: instantPayment)
        }
        func giniCaptureDidCancelAnalysis() {
            // nothing to test here
        }

        func giniCaptureDidEnterManually() {
            // nothing to test heretestCase
        }
    }
}
