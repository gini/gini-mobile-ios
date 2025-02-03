//
//  BaseIntegrationTest+TransferSummary.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import XCTest
@testable import GiniBankAPILibrary
@testable import GiniCaptureSDK
@testable import GiniBankSDK

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
                            self.handleSuccessfulTransferSummaryUpdate(extractionResult: extractionResult,
                                                                       expect: expect,
                                                                       result: result)
                        case let .failure(error):
                            XCTFail("Error updating transfer summary: \(error)")
                    }
                }
            }
        }
    }

    /**
     Handles the successful result of updating the transfer summary.

     - Parameters:
     - extractionResult: The updated extractions after feedback.
     - expect: The XCTestExpectation that needs to be fulfilled upon success.
     - result: The initial analysis result.
     */
    private func handleSuccessfulTransferSummaryUpdate(extractionResult: ExtractionResult,
                                                       expect: XCTestExpectation,
                                                       result: AnalysisResult) {
        let extractionsAfterFeedback = extractionResult.extractions

        let mockedInvoice = "result_Gini_invoice_example_payment_reference_after_feedback"
        // Load the expected fixture after feedback
        guard let fixtureExtractionsAfterFeedbackContainer = self.loadFixtureExtractionsContainer(from: mockedInvoice) else {
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
    }


    /**
     * This method reproduces getting updated extractions for the already known document by the Bank SDK.
     * It is assumed that transfer summary was sent, and we retrieve the updated extractions for verification.
     */
    private func getUpdatedExtractionsFromGiniBankSDK(for document: Document, completion: @escaping AnalysisCompletion) {
        giniHelper.giniBankAPIDocumentService.extractions(for: document,
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
