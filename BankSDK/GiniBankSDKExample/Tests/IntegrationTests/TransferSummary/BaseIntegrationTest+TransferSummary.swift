//
//  BaseIntegrationTest+TransferSummary.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import XCTest
@testable import GiniBankAPILibrary
@testable import GiniCaptureSDK
@testable import GiniBankSDK

/**
 Polling cadence for waiting on the backend to process transfer summary feedback.
 */
private enum Constants {
    static let pollInterval: TimeInterval = 2
    static let maxPollAttempts = 30
}

extension BaseIntegrationTest {

    // Method to handle updating and verifying feedback
    func updateAndVerifyTransferSummary(result: AnalysisResult,
                                        mockedInvoiceUpdatedResultName: String,
                                        expect: XCTestExpectation,
                                        verifyInstantPayment: Bool? = nil) {
        // Assuming the user updated the amountToPay to "950.00:EUR"
        result.extractions["amountToPay"]?.value = "950.00:EUR"

        guard result.extractions["amountToPay"] != nil else { return }
        guard let document = result.document else {
            XCTFail("Analysis result has no document to verify the transfer summary against")
            return
        }

        /// The fed-back `amountToPay` appearing in the fetched extractions signals
        /// that the backend has processed the transfer summary.
        pollUpdatedExtractions(for: document,
                               expectedAmountToPay: "950.00:EUR") { extractionResult in
            self.handleSuccessfulTransferSummaryUpdate(extractionResult: extractionResult,
                                                       mockedInvoiceUpdatedResultName: mockedInvoiceUpdatedResultName,
                                                       expect: expect,
                                                       result: result,
                                                       verifyInstantPayment: verifyInstantPayment)
        }
    }

    /**
     Polls the updated extractions for `document` until the fed-back `amountToPay`
     value becomes visible or the attempts are exhausted, then calls `completion`
     on the main queue with the last fetched result.

     Replaces the previous fixed 10-second delay: on a slow backend the delay
     expired before the feedback was processed and the assertions compared stale
     values. Exhausting the attempts still calls `completion` so the assertions
     produce a readable failure instead of a bare timeout.
     */
    func pollUpdatedExtractions(for document: Document,
                                expectedAmountToPay: String,
                                attemptsLeft: Int = Constants.maxPollAttempts,
                                completion: @escaping (ExtractionResult) -> Void) {
        getUpdatedExtractionsFromGiniBankSDK(for: document) { updatedResult in
            DispatchQueue.main.async {
                guard !self.isTestFinished else { return }
                switch updatedResult {
                    case let .success(extractionResult):
                        let amountToPay = extractionResult.extractions.first(where: { $0.name == "amountToPay" })?.value
                        if amountToPay == expectedAmountToPay || attemptsLeft <= 1 {
                            completion(extractionResult)
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.pollInterval) {
                                guard !self.isTestFinished else { return }
                                self.pollUpdatedExtractions(for: document,
                                                            expectedAmountToPay: expectedAmountToPay,
                                                            attemptsLeft: attemptsLeft - 1,
                                                            completion: completion)
                            }
                        }
                    case let .failure(error):
                        XCTFail("Error updating transfer summary: \(error)")
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
                                                       mockedInvoiceUpdatedResultName: String,
                                                       expect: XCTestExpectation,
                                                       result: AnalysisResult,
                                                       verifyInstantPayment: Bool? = nil) {
        let extractionsAfterFeedback = extractionResult.extractions
        // Load the expected fixture after feedback
        guard let fixtureExtractionsAfterFeedbackContainer = self.loadFixtureExtractionsContainer(from: mockedInvoiceUpdatedResultName) else {
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

        // Validate instant payment extraction if applicable
        if let verifyInstantPayment, verifyInstantPayment {
            XCTAssertEqual(fixtureExtractionsAfterFeedbackContainer.extractions.first(where: { $0.name == "instantPayment" })?.value,
                           extractionsAfterFeedback.first(where: { $0.name == "instantPayment" })?.value)
        } else {
            // For now for every case that is not instant payment detected on the invoice or is on the invoice but not check marked, we receive from CVIE it as false
            XCTAssertEqual(extractionsAfterFeedback.first(where: { $0.name == "instantPayment" })?.value,
                           "false")
        }

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
    func getUpdatedExtractionsFromGiniBankSDK(for document: Document, completion: @escaping AnalysisCompletion) {
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
