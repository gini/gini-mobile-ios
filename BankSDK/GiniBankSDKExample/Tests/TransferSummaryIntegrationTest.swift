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

class TransferSummaryIntegrationTest: XCTestCase {
    lazy var giniHelper = GiniSetupHelper()

    override func setUp() {

        giniHelper.setup()
    }

    func testSendTransferSummaryFeedback() {
        let expect = expectation(description: "transfer summary was correctly sent and extractions were updated")

        // 1a. Getting the extractions for the uploaded document.
        // (subsequent steps are in CaptureResultsDelegateForTransferSummaryTest)
        self.getExtractionsFromGiniBankSDK(delegate: CaptureResultsDelegateForTransferSummaryTest(integrationTest: self, expect: expect))

        wait(for: [expect], timeout: 60)
    }

    /**
     * This GiniCaptureResultsDelegate implementation shows you how you can send transfer summary for the extractions you receive.
     */
    class CaptureResultsDelegateForTransferSummaryTest: GiniCaptureResultsDelegate {

        let integrationTest: TransferSummaryIntegrationTest
        let expect: XCTestExpectation

        init(integrationTest: TransferSummaryIntegrationTest, expect: XCTestExpectation) {
            self.integrationTest = integrationTest
            self.expect = expect
        }

        func giniCaptureAnalysisDidFinishWith(result: AnalysisResult) {
            // 1b. Received the extractions for the uploaded document
            let fileName = "result_Gini_invoice_example_payment_reference"
           guard let fixtureExtractionsJson = FileLoader.loadFile(withName: fileName, ofType: "json") else {
                XCTFail("Error loading file: `\(fileName).json`")
                return
            }
            let fixtureExtractionsContainer = try! JSONDecoder().decode(ExtractionsContainer.self, from: fixtureExtractionsJson)

            // 2. Verify we received the correct extractions for this test
            XCTAssertEqual(fixtureExtractionsContainer.extractions.first(where: { $0.name == "iban" })?.value,
                           result.extractions["iban"]?.value)

            verifyPaymentRecipient(result.extractions["paymentRecipient"])

            XCTAssertEqual(fixtureExtractionsContainer.extractions.first(where: { $0.name == "bic" })?.value,
                           result.extractions["bic"]?.value)
            XCTAssertEqual(fixtureExtractionsContainer.extractions.first(where: { $0.name == "amountToPay" })?.value,
                           result.extractions["amountToPay"]?.value)

            // 3. Assuming the user saw the following extractions:
            //    amountToPay, iban, bic, paymentPurpose and paymentRecipient
            //    Supposing the user changed the amountToPay from "995.00:EUR" to "950.00:EUR"
            //    we need to update that extraction
            result.extractions["amountToPay"]?.value = "950.00:EUR"

            if result.extractions["amountToPay"] != nil {

                DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
                    // 5. Verify that the extractions were updated
                    self.integrationTest.getUpdatedExtractionsFromGiniBankSDK(for: result.document!) { result in
                        switch result {
                        case let .success(extractionResult):
                                let extractionsAfterFeedback = extractionResult.extractions

                                let fileName = "result_Gini_invoice_example_payment_reference_after_feedback"
                                guard let fixtureExtractionsAfterFeedbackJson = FileLoader.loadFile(withName: fileName,
                                                                                                    ofType: "json") else {
                                    XCTFail("Error loading file: `\(fileName).json`")
                                    return
                                }
                                let fixtureExtractionsAfterFeedbackContainer = try! JSONDecoder().decode(ExtractionsContainer.self,
                                                                                                         from: fixtureExtractionsAfterFeedbackJson)

                                XCTAssertEqual(fixtureExtractionsAfterFeedbackContainer.extractions.first(where: { $0.name == "iban" })?.value,
                                               extractionsAfterFeedback.first(where: { $0.name == "iban" })?.value)

                                let paymentRecipientExtraction = extractionsAfterFeedback.first(where: { $0.name == "paymentRecipient" })
                                self.verifyPaymentRecipient(paymentRecipientExtraction)

                                XCTAssertEqual(fixtureExtractionsAfterFeedbackContainer.extractions.first(where: { $0.name == "bic" })?.value,
                                               extractionsAfterFeedback.first(where: { $0.name == "bic" })?.value)
                                XCTAssertEqual(fixtureExtractionsAfterFeedbackContainer.extractions.first(where: { $0.name == "amountToPay" })?.value,
                                               extractionsAfterFeedback.first(where: { $0.name == "amountToPay" })?.value)

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

                                // 6. Free up resources after TAN verification
                                GiniBankConfiguration.shared.cleanup()
                                XCTAssertNil(GiniBankConfiguration.shared.documentService)
                                self.expect.fulfill()
                        case let .failure(error):
                                XCTFail(String(describing: error))
                        }
                    }
                })
            }
        }

        func giniCaptureDidEnterManually() {
        }

        func giniCaptureDidCancelAnalysis() {
        }

        /*
         Verifies that the `paymentRecipient` extraction is present and has a non-nil value.

         This method asserts that:
         - The `paymentRecipient` extraction exists.
         - The `paymentRecipient` extraction has a non-nil value.

         If either of these conditions is not met, the test will fail.

         - Parameter paymentRecipientExtraction: The extraction to be verified.
         */
        private func verifyPaymentRecipient(_ paymentRecipientExtraction: Extraction?) {
            XCTAssertNotNil(paymentRecipientExtraction, "The paymentRecipient extraction should be present in the extractions.")
            XCTAssertNotNil(paymentRecipientExtraction?.value, "The value of paymentRecipient extraction should not be nil.")
        }
    }

    /**
      * This method reproduces the document upload and analysis done by the Bank SDK.
      *
      * The intent of this method is to create extractions like the one your app
      * receives after a user analysed a document with the Bank SDK.
      *
      * In your production code you should not call `DocumentService` methods.
      * Interaction with the network service is handled by the Bank SDK internally.
      */
    private func getExtractionsFromGiniBankSDK(delegate: GiniCaptureResultsDelegate) {
        let fileName = "Gini_invoice_example_payment_reference"
        guard let testDocumentData = FileLoader.loadFile(withName: fileName, ofType: "pdf") else {
            XCTFail("Error loading file: `\(fileName).pdf`")
            return
        }
        let builder = GiniCaptureDocumentBuilder(documentSource: .appName(name: "GiniBankSDKExample"))
        let captureDocument = builder.build(with: testDocumentData,
                                            fileName: "\(fileName).pdf")!

        GiniBankConfiguration.shared.documentService = giniHelper.giniCaptureSDKDocumentService

        // Upload a test document
        giniHelper.giniCaptureSDKDocumentService.upload(document: captureDocument) { result in
            switch result {
            case .success(_):
                // Analyze the uploaded test document
                    self.giniHelper.giniCaptureSDKDocumentService?.startAnalysis { result in
                    switch result {
                    case let .success(extractionResult):
                        let extractions: [String: Extraction] = Dictionary(uniqueKeysWithValues: extractionResult.extractions.compactMap {
                            guard let name = $0.name else { return nil }

                            return (name, $0)
                        })

                        let analysisResult = AnalysisResult(extractions: extractions,
                                                            lineItems: extractionResult.lineItems,
                                                            images: [],
                                                            document: self.giniHelper.giniCaptureSDKDocumentService?.document,
                                                            candidates: [:])

                        delegate.giniCaptureAnalysisDidFinishWith(result: analysisResult)

                        GiniBankConfiguration.shared.lineItems = extractionResult.lineItems
                        // 4. Send transfer summary for the extractions the user saw
                        //    with the final (user confirmed or updated) extraction values
                        GiniBankConfiguration.shared.sendTransferSummary(paymentRecipient: extractions["paymentRecipient"]?.value ?? "",
                                                                         paymentReference: extractions["paymentReference"]?.value ?? "",
                                                                         paymentPurpose: extractions["paymentPurpose"]?.value ?? "",
                                                                         iban: extractions["iban"]?.value ?? "",
                                                                         bic: extractions["bic"]?.value ?? "",
                                                                         amountToPay: ExtractionAmount(value: 950.00, currency: .EUR))

                    case let .failure(error):
                        XCTFail(String(describing: error))
                    }
                }
            case let .failure(error):
                XCTFail(String(describing: error))
            }
        }
    }

    /**
      * This method reproduces the getting extractions for the already known document by the Bank SDK.
      * In your production code you should not call  any`GiniBankAPILibrary` methods.
      * Interaction with the network service is handled by the Bank SDK internally.
      */
    private func getUpdatedExtractionsFromGiniBankSDK(for document: Document, completion: @escaping AnalysisCompletion){
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

