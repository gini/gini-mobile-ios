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

extension BaseIntegrationTest {

    // Method to handle updating and verifying feedback
    func updateAndVerifyTransferSummary(result: AnalysisResult, expect: XCTestExpectation) {
        // Assuming the user updated the amountToPay to "950.00:EUR"
        result.extractions["amountToPay"]?.value = "950.00:EUR"

        if result.extractions["amountToPay"] != nil {
            // Delay to simulate feedback update process
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                // 5. Verify that the extractions were updated after feedback
                self.getUpdatedExtractionsFromGiniBankSDK(for: result.document!) { updatedResult in
                    switch updatedResult {
                    case let .success(extractionResult):
                            let extractionsAfterFeedback = extractionResult.extractions

                            let mockedInvoice = "result_Gini_invoice_example_payment_reference_after_feedback"
                            // Load the expected fixture after feedback
                            guard let fixtureExtractionsAfterFeedbackContainer = self.loadFixtureExtractionsContainer(from: mockedInvoice)
                            else {
                                return
                            }

                            // Validate the updated extractions against the fixture
                            XCTAssertEqual(fixtureExtractionsAfterFeedbackContainer.extractions.first(where: { $0.name == "iban" })?.value,
                                           extractionsAfterFeedback.first(where: { $0.name == "iban" })?.value)

                            let paymentRecipientExtraction = extractionsAfterFeedback.first(where: { $0.name == "paymentRecipient" })
                            self.verifyPaymentRecipient(paymentRecipientExtraction)

                            XCTAssertEqual(fixtureExtractionsAfterFeedbackContainer.extractions.first(where: { $0.name == "bic" })?.value,
                                           extractionsAfterFeedback.first(where: { $0.name == "bic" })?.value)
                            XCTAssertEqual(fixtureExtractionsAfterFeedbackContainer.extractions.first(where: { $0.name == "amountToPay" })?.value,
                                           extractionsAfterFeedback.first(where: { $0.name == "amountToPay" })?.value)


                            // Validate line items if applicable
                            let fixtureLineItems = fixtureExtractionsAfterFeedbackContainer.compoundExtractions?.lineItems
                            if let firstLineItemAfterFeedback = extractionResult.lineItems?.first, let fixtureLineItem = fixtureLineItems?.first {
                                XCTAssertEqual(fixtureLineItem.first(where: { $0.name == "baseGross" })?.value,
                                               firstLineItemAfterFeedback.first(where: { $0.name == "baseGross" })?.value)
                                XCTAssertEqual(fixtureLineItem.first(where: { $0.name == "description" })?.value,
                                               firstLineItemAfterFeedback.first(where: { $0.name == "description" })?.value)
                                XCTAssertEqual(fixtureLineItem.first(where: { $0.name == "quantity" })?.value,
                                               firstLineItemAfterFeedback.first(where: { $0.name == "quantity" })?.value)
                                XCTAssertEqual(fixtureLineItem.first(where: { $0.name == "artNumber" })?.value,
                                               firstLineItemAfterFeedback.first(where: { $0.name == "artNumber" })?.value)
                            }

                            // Free resources and cleanup
                            GiniBankConfiguration.shared.cleanup()
                            XCTAssertNil(GiniBankConfiguration.shared.documentService)

                            expect.fulfill()
                        case let .failure(error):
                            XCTFail("Error updating transfer summary: \(error)")
                    }
                }
            }
        }
    }

    /**
     * This method reproduces getting updated extractions for the already known document by the Bank SDK.
     * It is assumed that transfer summary was sent, and we retrieve the updated extractions for verification.
     */
    private func getUpdatedExtractionsFromGiniBankSDK(for document: Document, completion: @escaping AnalysisCompletion) {
        self.giniHelper.giniBankAPIDocumentService.extractions(for: document,
                                                               cancellationToken: CancellationToken()) { result in
            switch result {
            case let .success(extractionResult):
                completion(.success(extractionResult))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
