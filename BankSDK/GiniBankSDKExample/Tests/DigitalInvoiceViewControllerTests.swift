//
//  DigitalInvoiceViewControllerTests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankAPILibrary
@testable import GiniCaptureSDK
@testable import GiniBankSDK

class DigitalInvoiceIntegrationTests: XCTestCase {

    lazy var giniHelper = GiniSetupHelper()

    override func setUp() {

        giniHelper.setup()
    }

    func testExtractionsForLineItemsWithDiscount() {
        let expect = expectation(description: "The line items extracted from the invoice were all accurately compared against the static JSON.")

        // 1a. Getting the extractions for the uploaded document.
        self.getExtractionsFromGiniBankSDK(delegate: CaptureResultsDelegate(expect: expect))

        wait(for: [expect], timeout: 60)
    }


    class CaptureResultsDelegate: GiniCaptureResultsDelegate {

        let expect: XCTestExpectation

        init(expect: XCTestExpectation) {
            self.expect = expect
        }

        func giniCaptureAnalysisDidFinishWith(result: AnalysisResult) {
            // 1b. Received the extractions for the uploaded document
            let fileName = "result_Gini_invoice_example_line_items_with_discount"
            guard let fixtureExtractionsJson = FileLoader.loadFile(withName: fileName, ofType: "json") else {
                XCTFail("Error loading file: `\(fileName).json`")
                return
            }

            let fixtureExtractionsContainer = try? JSONDecoder().decode(ExtractionsContainer.self, from: fixtureExtractionsJson)

            // 2. Verify we received the correct extractions for this test
            XCTAssertEqual(fixtureExtractionsContainer?.extractions.first(where: { $0.name == "iban" })?.value,
                           result.extractions["iban"]?.value)

            verifyPaymentRecipient(result.extractions["paymentRecipient"])

            XCTAssertEqual(fixtureExtractionsContainer?.extractions.first(where: { $0.name == "bic" })?.value,
                           result.extractions["bic"]?.value)
            XCTAssertEqual(fixtureExtractionsContainer?.extractions.first(where: { $0.name == "amountToPay" })?.value,
                           result.extractions["amountToPay"]?.value)
            

            let fixtureLineItems = fixtureExtractionsContainer?.compoundExtractions?.lineItems

            // Ensure both arrays are of the same length and not empty
            guard let fixtureLineItems = fixtureLineItems,
                  let resultLineItems = result.lineItems,
                  !fixtureLineItems.isEmpty,
                  !resultLineItems.isEmpty,
                  fixtureLineItems.count == resultLineItems.count else {
                XCTFail("Arrays are either empty or have different lengths")
                return
            }

            // Iterate through both arrays simultaneously if they have the same count

            // The zip function iterates over these two arrays simultaneously.
            // For each iteration, fixtureItem will represent an element from fixtureLineItems, and
            // resultItem will represent the corresponding element from resultLineItems.


            //Compare extractions by name == "baseGross" when line items have discount
            for (fixtureItem, resultItem) in zip(fixtureLineItems, resultLineItems) {


                // Find the element with name property "baseGross" in each array
                if let fixtureBaseGrossExtraction = fixtureItem.first(where: { $0.name == "baseGross" }),
                   let resultBaseGrossExtraction = resultItem.first(where: { $0.name == "baseGross" }) {

                    // Compare the values of baseGross extractions
                    XCTAssertEqual(fixtureBaseGrossExtraction.value, resultBaseGrossExtraction.value, "Values for baseGross are not equal.")
                } else {
                    XCTFail("baseGross not found in one or both arrays.")
                }
            }

            self.expect.fulfill()
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
            XCTAssertNotNil(paymentRecipientExtraction, "The paymentRecipient extraction should be present in the fixtureExtractionsContainer.")
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
        let fileName = "Gini_invoice_example_line_items_with_discount"
        guard let testDocumentData = FileLoader.loadFile(withName: fileName, ofType: "pdf") else {
            XCTFail("Error loading file: `\(fileName).pdf")
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

                            case let .failure(error):
                                XCTFail(String(describing: error))
                        }
                    }
                case let .failure(error):
                    XCTFail(String(describing: error))
            }
        }
    }
}

