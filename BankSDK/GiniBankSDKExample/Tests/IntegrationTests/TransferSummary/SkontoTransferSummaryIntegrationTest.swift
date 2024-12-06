//
//  SkontoTransferSummaryIntegrationTest.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import XCTest
@testable import GiniBankAPILibrary
@testable import GiniCaptureSDK
@testable import GiniBankSDK

class SkontoTransferSummaryIntegrationTest: BaseIntegrationTest {
    
    func testSendSkontoTransferSummary() {
        let mockedInvoiceName = "Gini_invoice_example_skonto"
        let expect = expectation(description: "Transfer summary was correctly sent and extractions were updated")
        let skontoTransferSummaryHandler = SkontoTransferSummaryHandler(testCase: self,
                                                                        mockedInvoiceResultName: "result_Gini_invoice_example_skonto",
                                                                        mockedInvoiceResultAfterFeedbackName: "result_Gini_invoice_example_skonto_after_transfer_summary",
                                                                        expect: expect)
        uploadAndAnalyzeDocument(fileName: mockedInvoiceName,
                                 delegate: skontoTransferSummaryHandler)
        wait(for: [expect], timeout: 60)
    }
    
    class SkontoTransferSummaryHandler: GiniCaptureResultsDelegate {
        let testCase: SkontoTransferSummaryIntegrationTest
        let mockedInvoiceResultName: String
        let mockedInvoiceResultAfterFeedbackName: String
        let expect: XCTestExpectation

        init(testCase: SkontoTransferSummaryIntegrationTest,
             mockedInvoiceResultName: String,
             mockedInvoiceResultAfterFeedbackName: String,
             expect: XCTestExpectation) {
            self.testCase = testCase
            self.mockedInvoiceResultName = mockedInvoiceResultName
            self.mockedInvoiceResultAfterFeedbackName = mockedInvoiceResultAfterFeedbackName
            self.expect = expect
        }

        func giniCaptureAnalysisDidFinishWith(result: AnalysisResult) {
            let mockedInvoice = mockedInvoiceResultName
            // Use the helper method to load the fixture extractions container
            guard let fixtureExtractionsContainer = testCase.loadFixtureExtractionsContainer(from: mockedInvoice) else {
                return
            }

            // Verify the extractions
            testCase.verifyExtractions(result: result, fixtureContainer: fixtureExtractionsContainer)
            
            guard  let skontoDiscountExtraction = result.skontoDiscounts?.first else {
                return
            }
            let updatedAmountToPayString = "1000.00:EUR"
            let updatedPercentage = "50.0"
            result.extractions["amountToPay"]?.value = updatedAmountToPayString
            let modifiedSkontoExtractions = skontoDiscountExtraction.map { extraction -> Extraction in
                let modifiedExtraction = extraction
                switch modifiedExtraction.name {
                case "skontoAmountToPay", "skontoAmountToPayCalculated":
                    modifiedExtraction.value = updatedAmountToPayString
                case "skontoPercentageDiscounted", "skontoPercentageDiscountedCalculated":
                    modifiedExtraction.value = updatedPercentage
                default:
                    break
                }
                return modifiedExtraction
            }
            GiniBankConfiguration.shared.skontoDiscounts = [modifiedSkontoExtractions]
            
            let amountExtraction = self.createAmountExtraction(value: updatedAmountToPayString)
            GiniBankConfiguration.shared.sendTransferSummaryWithSkonto(amountExtraction: amountExtraction,
                                                                       amountToPayString: updatedAmountToPayString)
            
            // Call the updateAndVerifyTransferSummary method to handle the transfer summary update
            self.updateAndVerifyTransferSummary(result: result, mockedInvoiceUpdatedResultName: mockedInvoiceResultAfterFeedbackName, expect: expect)
        }

        func giniCaptureDidCancelAnalysis() {
            // nothing to test here
        }

        func giniCaptureDidEnterManually() {
            // nothing to test heretestCase
        }
        
        private func createAmountExtraction(value: String) -> Extraction {
            return Extraction(box: nil,
                              candidates: nil,
                              entity: "amount",
                              value: value,
                              name: "amountToPay")
        }
        
        func updateAndVerifyTransferSummary(result: AnalysisResult,
                                            mockedInvoiceUpdatedResultName: String,
                                            expect: XCTestExpectation) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
                self?.testCase.getUpdatedExtractionsFromGiniBankSDK(for: result.document!) { updatedResult in
                    switch updatedResult {
                        case let .success(extractionResult):
                            self?.handleSuccessfulTransferSummary(extractionResult: extractionResult,
                                                                       mockedInvoiceUpdatedResultName: mockedInvoiceUpdatedResultName,
                                                                       expect: expect,
                                                                       result: result)
                        case let .failure(error):
                            XCTFail("Error updating transfer summary: \(error)")
                    }
                }
            }
        }

        private func handleSuccessfulTransferSummary(extractionResult: ExtractionResult,
                                                           mockedInvoiceUpdatedResultName: String,
                                                           expect: XCTestExpectation,
                                                           result: AnalysisResult) {
            let extractionsAfterFeedback = extractionResult.extractions
            // Load the expected fixture after feedback
            guard let fixtureExtractionsAfterFeedbackContainer = testCase.loadFixtureExtractionsContainer(from: mockedInvoiceUpdatedResultName) else {
                return
            }

            // Validate the updated extractions against the fixture
            XCTAssertEqual(fixtureExtractionsAfterFeedbackContainer.extractions.first(where: { $0.name == "iban" })?.value,
                           extractionsAfterFeedback.first(where: { $0.name == "iban" })?.value)

            let paymentRecipientExtraction = extractionsAfterFeedback.first(where: { $0.name == "paymentRecipient" })
            testCase.verifyPaymentRecipient(paymentRecipientExtraction)

            XCTAssertEqual(fixtureExtractionsAfterFeedbackContainer.extractions.first(where: { $0.name == "bic" })?.value,
                           extractionsAfterFeedback.first(where: { $0.name == "bic" })?.value)
            XCTAssertEqual(fixtureExtractionsAfterFeedbackContainer.extractions.first(where: { $0.name == "amountToPay" })?.value,
                           extractionsAfterFeedback.first(where: { $0.name == "amountToPay" })?.value)

            // Validate line items if applicable
            let fixtureSkontoDiscounts = fixtureExtractionsAfterFeedbackContainer.compoundExtractions?.skontoDiscounts?.first
            if let fixtureSkontoDiscountsAfterFeedback = extractionResult.skontoDiscounts?.first {
                XCTAssertEqual(fixtureSkontoDiscounts?.first(where: { $0.name == "skontoAmountToPayCalculated" })?.value,
                               fixtureSkontoDiscountsAfterFeedback.first(where: { $0.name == "skontoAmountToPayCalculated" })?.value)
            }

            // Free resources and cleanup
            GiniBankConfiguration.shared.cleanup()
            XCTAssertNil(GiniBankConfiguration.shared.documentService)

            expect.fulfill()
        }
    }
}
