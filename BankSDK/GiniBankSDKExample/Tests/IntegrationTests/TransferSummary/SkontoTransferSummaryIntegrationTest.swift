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
        
        let handler = SkontoTransferSummaryHandler(
            testCase: self,
            mockedInvoiceResultName: "result_Gini_invoice_example_skonto",
            mockedInvoiceResultAfterFeedbackName: "result_Gini_invoice_example_skonto_after_transfer_summary",
            expect: expect)
        
        uploadAndAnalyzeDocument(fileName: mockedInvoiceName, delegate: handler)
        wait(for: [expect], timeout: 60)
    }
}

class SkontoNotAppliedTransferSummaryIntegrationTest: BaseIntegrationTest {
    
    func testSendSkontoTransferSummary() {
        let mockedInvoiceName = "Gini_invoice_example_skonto"
        let expect = expectation(description: "Transfer summary was correctly sent and extractions were updated")
        
        let handler = SkontoNotAppliedTransferSummaryHandler(
            testCase: self,
            mockedInvoiceResultName: "result_Gini_invoice_example_skonto",
            mockedInvoiceResultAfterFeedbackName: "result_Gini_invoice_example_skonto",
            expect: expect)
        
        uploadAndAnalyzeDocument(fileName: mockedInvoiceName, delegate: handler)
        wait(for: [expect], timeout: 60)
    }
}

// MARK: - Base Handler

class BaseSkontoTransferSummaryHandler<TestCase: BaseIntegrationTest>: GiniCaptureResultsDelegate {
    let testCase: TestCase
    let mockedInvoiceResultName: String
    let mockedInvoiceResultAfterFeedbackName: String
    let expect: XCTestExpectation

    init(testCase: TestCase,
         mockedInvoiceResultName: String,
         mockedInvoiceResultAfterFeedbackName: String,
         expect: XCTestExpectation) {
        self.testCase = testCase
        self.mockedInvoiceResultName = mockedInvoiceResultName
        self.mockedInvoiceResultAfterFeedbackName = mockedInvoiceResultAfterFeedbackName
        self.expect = expect
    }

    func giniCaptureAnalysisDidFinishWith(result: AnalysisResult) {
        guard let fixtureExtractionsContainer = testCase.loadFixtureExtractionsContainer(from: mockedInvoiceResultName) else {
            return
        }

        testCase.verifyExtractions(result: result, fixtureContainer: fixtureExtractionsContainer)
        applySkontoChangesIfNeeded(result: result)
        sendTransferSummary(result: result)
        updateAndVerifyTransferSummary(result: result,
                                       mockedInvoiceUpdatedResultName: mockedInvoiceResultAfterFeedbackName,
                                       expect: expect)
    }

    func giniCaptureDidCancelAnalysis() {
        // not tested
    }

    func giniCaptureDidEnterManually() {
        // not tested
    }

    // MARK: - Methods to override or customize in subclasses if needed

    /// Override this method in subclasses to apply any skonto-related modifications.
    func applySkontoChangesIfNeeded(result: AnalysisResult) {
        // Default: no changes
    }

    /// Override this method in subclasses if the transfer summary should be sent differently.
    func sendTransferSummary(result: AnalysisResult) {
        guard let amountToPayString = result.extractions["amountToPay"]?.value else { return }
        let amountExtraction = createAmountExtraction(value: amountToPayString)
        GiniBankConfiguration.shared.sendTransferSummaryWithSkonto(amountToPayExtraction: amountExtraction,
                                                                   amountToPayString: amountToPayString)
    }

    // MARK: - Common logic

    func updateAndVerifyTransferSummary(result: AnalysisResult,
                                        mockedInvoiceUpdatedResultName: String,
                                        expect: XCTestExpectation) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            guard let self = self else { return }
            self.testCase.getUpdatedExtractionsFromGiniBankSDK(for: result.document!) { updatedResult in
                switch updatedResult {
                case let .success(extractionResult):
                    self.handleSuccessfulTransferSummary(extractionResult: extractionResult,
                                                         mockedInvoiceUpdatedResultName: mockedInvoiceUpdatedResultName,
                                                         expect: expect,
                                                         result: result)
                case let .failure(error):
                    XCTFail("Error updating transfer summary: \(error)")
                }
            }
        }
    }

    func handleSuccessfulTransferSummary(extractionResult: ExtractionResult,
                                         mockedInvoiceUpdatedResultName: String,
                                         expect: XCTestExpectation,
                                         result: AnalysisResult) {
        let extractionsAfterFeedback = extractionResult.extractions
        guard let fixtureExtractionsAfterFeedbackContainer = testCase.loadFixtureExtractionsContainer(from: mockedInvoiceUpdatedResultName) else {
            return
        }

        // Validate basic extractions
        XCTAssertEqual(fixtureExtractionsAfterFeedbackContainer.extractions.first(where: { $0.name == "iban" })?.value,
                       extractionsAfterFeedback.first(where: { $0.name == "iban" })?.value)
        
        let paymentRecipientExtraction = extractionsAfterFeedback.first(where: { $0.name == "paymentRecipient" })
        testCase.verifyPaymentRecipient(paymentRecipientExtraction)
        
        XCTAssertEqual(fixtureExtractionsAfterFeedbackContainer.extractions.first(where: { $0.name == "bic" })?.value,
                       extractionsAfterFeedback.first(where: { $0.name == "bic" })?.value)
        
        XCTAssertEqual(fixtureExtractionsAfterFeedbackContainer.extractions.first(where: { $0.name == "amountToPay" })?.value,
                       extractionsAfterFeedback.first(where: { $0.name == "amountToPay" })?.value)

        // Validate skonto discounts if applicable
        validateSkontoDiscounts(fixtureContainer: fixtureExtractionsAfterFeedbackContainer,
                                extractionResult: extractionResult)

        // Cleanup
        GiniBankConfiguration.shared.cleanup()
        XCTAssertNil(GiniBankConfiguration.shared.documentService)
        
        expect.fulfill()
    }

    func validateSkontoDiscounts(fixtureContainer: ExtractionsContainer,
                                 extractionResult: ExtractionResult) {
        let fixtureSkontoDiscounts = fixtureContainer.compoundExtractions?.skontoDiscounts?.first
        if let fixtureSkontoDiscountsAfterFeedback = extractionResult.skontoDiscounts?.first {
            XCTAssertEqual(fixtureSkontoDiscounts?.first(where: { $0.name == "skontoAmountToPayCalculated" })?.value,
                           fixtureSkontoDiscountsAfterFeedback.first(where: { $0.name == "skontoAmountToPayCalculated" })?.value)
        }
    }

    func createAmountExtraction(value: String) -> Extraction {
        Extraction(box: nil,
                   candidates: nil,
                   entity: "amount",
                   value: value,
                   name: "amountToPay")
    }
}

// MARK: - Specific Handlers

class SkontoTransferSummaryHandler: BaseSkontoTransferSummaryHandler<SkontoTransferSummaryIntegrationTest> {

    override func applySkontoChangesIfNeeded(result: AnalysisResult) {
        guard let skontoDiscountExtraction = result.skontoDiscounts?.first else { return }

        let updatedAmountToPayString = "1000.00:EUR"
        let updatedPercentage = "50.0"

        // Modify result extractions
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
    }
}

class SkontoNotAppliedTransferSummaryHandler: BaseSkontoTransferSummaryHandler<SkontoNotAppliedTransferSummaryIntegrationTest> {

    override func applySkontoChangesIfNeeded(result: AnalysisResult) {
        guard let skontoDiscountExtraction = result.skontoDiscounts?.first else { return }
        GiniBankConfiguration.shared.skontoDiscounts = [skontoDiscountExtraction]
    }
}
