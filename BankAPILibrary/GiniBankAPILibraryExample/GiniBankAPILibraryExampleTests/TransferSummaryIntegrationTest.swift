////
////  TransferSummaryIntegrationTest.swift
////  GiniBankAPILibraryExampleTests
////
////  Created by Nadya Karaban on 04.03.22.
////

import Foundation

import XCTest
@testable import GiniBankAPILibrary

class TransferSummaryIntegrationTest: XCTestCase {
    let clientId = ProcessInfo.processInfo.environment["CLIENT_ID"]!
    let clientSecret = ProcessInfo.processInfo.environment["CLIENT_SECRET"]!
    var giniBankAPILib: GiniBankAPI!
    var documentService: DefaultDocumentService!

    override func setUp() {
        giniBankAPILib = GiniBankAPI
               .Builder(client: Client(id: clientId,
                                       secret: clientSecret,
                                       domain: "pay-api-lib-example"))
               .build()
        documentService = giniBankAPILib.documentService()
    }

    func loadFile(withName name: String, ofType type: String) -> Data {
        let fileURLPath: String? = Bundle.main
            .path(forResource: name, ofType: type)
        let data = try? Data.init(contentsOf: URL(fileURLWithPath: fileURLPath!))

        return data!
    }

    func testSendTransferSummary() {
        let expect = expectation(description: "transfer summary was correctly sent and extractions were updated")

        // 1. Upload a test document
        let testDocumentData = loadFile(withName: "Gini_invoice_example", ofType: "pdf")
        documentService.createDocument(fileName: "PartialDocument", docType: nil, type: .partial(testDocumentData), metadata: nil) { result in
            switch result {
            case let .success(createdDocument):
                let partialDocInfo = PartialDocumentInfo(document: createdDocument.links.document)
                self.documentService.createDocument(fileName: nil,
                                               docType: nil,
                                               type: .composite(CompositeDocumentInfo(partialDocuments: [partialDocInfo])),
                                               metadata: nil) { result in
                    switch result {
                    case let .success(compositeDocument):

                        // 2. Request the extractions
                        self.documentService.extractions(for: compositeDocument, cancellationToken: CancellationToken()) { result in
                            switch result {
                            case .success(let extractionResult):
                                let extractions = extractionResult.extractions

                                let fixtureExtractionsJson = self.loadFile(withName: "result_Gini_invoice_example", ofType: "json")

                                let fixtureExtractionsContainer = try! JSONDecoder().decode(ExtractionsContainer.self, from: fixtureExtractionsJson)

                                // Verify we received the correct extractions for this test
                                XCTAssertEqual(fixtureExtractionsContainer.extractions.first(where: {$0.name == "iban"})?.value, extractions.first(where: {$0.name == "iban"})?.value)
                                XCTAssertEqual(fixtureExtractionsContainer.extractions.first(where: {$0.name == "paymentRecipient"})?.value, extractions.first(where: {$0.name == "paymentRecipient"})?.value)
                                XCTAssertEqual(fixtureExtractionsContainer.extractions.first(where: {$0.name == "paymentPurpose"})?.value, extractions.first(where: {$0.name == "paymentPurpose"})?.value)
                                XCTAssertEqual(fixtureExtractionsContainer.extractions.first(where: {$0.name == "bic"})?.value, extractions.first(where: {$0.name == "bic"})?.value)
                                XCTAssertEqual(fixtureExtractionsContainer.extractions.first(where: {$0.name == "amountToPay"})?.value, extractions.first(where: {$0.name == "amountToPay"})?.value)

                                // 3. Assuming the user saw the following extractions:
                                //    amountToPay, iban, bic, paymentPurpose and paymentRecipient
                                //    Supposing the user changed the amountToPay from "995.00:EUR" to "950.00:EUR"
                                //    we need to update that extraction
                                extractions.first(where: {$0.name == "amountToPay"})?.value = "950.00:EUR"

                                //    Send feedback for the extractions the user saw
                                //    with the final (user confirmed or updated) extraction values
                                self.documentService.submitFeedback(for: compositeDocument, with: extractions) { result in
                                    switch result {
                                    case .success(_):

                                        // 4. Verify that the extractions were updated
                                        self.documentService.extractions(for: compositeDocument, cancellationToken: CancellationToken()) { result in
                                            switch result {
                                            case .success(let extractionResult):
                                                let extractionsAfterFeedback = extractionResult.extractions
                                                let fixtureExtractionsAfterFeedbackJson = self.loadFile(withName: "result_Gini_invoice_example_after_feedback", ofType: "json")
                                                let fixtureExtractionsAfterFeedbackContainer = try! JSONDecoder().decode(ExtractionsContainer.self, from: fixtureExtractionsAfterFeedbackJson)

                                                XCTAssertEqual(fixtureExtractionsAfterFeedbackContainer.extractions.first(where: {$0.name == "iban"})?.value, extractionsAfterFeedback.first(where: {$0.name == "iban"})?.value)
                                                XCTAssertEqual(fixtureExtractionsAfterFeedbackContainer.extractions.first(where: {$0.name == "paymentRecipient"})?.value, extractionsAfterFeedback.first(where: {$0.name == "paymentRecipient"})?.value)
                                                XCTAssertEqual(fixtureExtractionsAfterFeedbackContainer.extractions.first(where: {$0.name == "paymentPurpose"})?.value, extractionsAfterFeedback.first(where: {$0.name == "paymentPurpose"})?.value)
                                                XCTAssertEqual(fixtureExtractionsAfterFeedbackContainer.extractions.first(where: {$0.name == "bic"})?.value, extractionsAfterFeedback.first(where: {$0.name == "bic"})?.value)
                                                XCTAssertEqual(fixtureExtractionsAfterFeedbackContainer.extractions.first(where: {$0.name == "amountToPay"})?.value, extractionsAfterFeedback.first(where: {$0.name == "amountToPay"})?.value)
                                                expect.fulfill()
                                            case .failure(let error):
                                                XCTFail(String(describing: error))
                                            }
                                        }
                                    case .failure(let error):
                                        XCTFail(String(describing: error))
                                    }
                                }
                            case .failure(let error):
                                XCTFail(String(describing: error))
                            }
                        }
                    case .failure(let error):
                        XCTFail(String(describing: error))
                    }
                }
            case .failure(let error):
                XCTFail(String(describing: error))
            }
        }
        wait(for: [expect], timeout: 30)
    }
}
