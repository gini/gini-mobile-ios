//
//  ExtractionFeedbackIntegrationTest.swift
//  GiniCaptureSDKExampleTests
//
//  Created by Nadya Karaban on 04.03.22.
//
// swiftlint:disable all

import Foundation

@testable import GiniBankAPILibrary
@testable import GiniCaptureSDK
import XCTest
class ExtractionFeedbackIntegrationTest: XCTestCase {
    let clientId = ProcessInfo.processInfo.environment["CLIENT_ID"]!
    let clientSecret = ProcessInfo.processInfo.environment["CLIENT_SECRET"]!
    var giniBankAPILib: GiniBankAPI!
    var documentService: GiniCaptureSDK.DocumentService?
    var docID = ""
    var giniBankAPIdocumentService: GiniBankAPILibrary.DefaultDocumentService!

    override func setUp() {
        giniBankAPILib = GiniBankAPI
            .Builder(client: Client(id: clientId,
                                    secret: clientSecret,
                                    domain: "capture-sdk-example"))
            .build()
        documentService = DocumentService(lib: giniBankAPILib, metadata: nil)
        giniBankAPIdocumentService = giniBankAPILib.documentService()
    }

    func loadFile(withName name: String, ofType type: String) -> Data {
        let fileURLPath: String? = Bundle.main
            .path(forResource: name, ofType: type)
        let data = try? Data(contentsOf: URL(fileURLWithPath: fileURLPath!))

        return data!
    }

    func testSendExtractionFeedback() {
        let expect = expectation(description: "feedback was correctly sent and extractions were updated")

        let testDocumentData = loadFile(withName: "Gini_invoice_example", ofType: "pdf")
        let builder = GiniCaptureDocumentBuilder(documentSource: .appName(name: "GiniCaptureSDKExample"))
        let captureDocument = builder.build(with: testDocumentData)!

        let extractions = getExtractionsFromGiniCaptureSDK()

        let fixtureExtractionsJson = loadFile(withName: "result_Gini_invoice_example", ofType: "json")

        let fixtureExtractionsContainer = try! JSONDecoder().decode(ExtractionsContainer.self, from: fixtureExtractionsJson)

        // Verify we received the correct extractions for this test
        XCTAssertEqual(fixtureExtractionsContainer.extractions.first(where: { $0.name == "iban" })?.value, extractions.first(where: { $0.name == "iban" })?.value)

        XCTAssertEqual(fixtureExtractionsContainer.extractions.first(where: { $0.name == "paymentRecipient" })?.value,
                       extractions.first(where: { $0.name == "paymentRecipient" })?.value)
        XCTAssertEqual(fixtureExtractionsContainer.extractions.first(where: { $0.name == "paymentPurpose" })?.value,
                       extractions.first(where: { $0.name == "paymentPurpose" })?.value)
        XCTAssertEqual(fixtureExtractionsContainer.extractions.first(where: { $0.name == "bic" })?.value, extractions.first(where: { $0.name == "bic" })?.value)
        XCTAssertEqual(fixtureExtractionsContainer.extractions.first(where: { $0.name == "amountToPay" })?.value, extractions.first(where: { $0.name == "amountToPay" })?.value)
        // 3. Assuming the user saw the following extractions:
        //    amountToPay, iban, bic, paymentPurpose and paymentRecipient
        //    Supposing the user changed the amountToPay from "995.00:EUR" to "950.00:EUR"
        //    we need to update that extraction
        extractions.first(where: { $0.name == "amountToPay" })?.value = "950.00:EUR"
        //    Send feedback for the extractions the user saw
        //    with the final (user confirmed or updated) extraction values

        documentService?.sendFeedback(with: extractions)

//                        4. Verify that the extractions were updated

//                        self.giniBankAPIdocumentService.extractions(for: <#T##Document#>, cancellationToken: <#T##CancellationToken#>, completion: <#T##CompletionResult<ExtractionResult>##CompletionResult<ExtractionResult>##(Result<ExtractionResult, GiniError>) -> Void#>)

        documentService?.startAnalysis(completion: { result in
            switch result {
            case let .success(extractionResult):

                let extractionsAfterFeedback = extractionResult.extractions
                print(extractionsAfterFeedback)
                let fixtureExtractionsAfterFeedbackJson = self.loadFile(withName: "result_Gini_invoice_example_after_feedback", ofType: "json")
                let fixtureExtractionsAfterFeedbackContainer = try! JSONDecoder().decode(ExtractionsContainer.self, from: fixtureExtractionsAfterFeedbackJson)
                XCTAssertEqual(fixtureExtractionsAfterFeedbackContainer.extractions.first(where: { $0.name == "iban" })?.value,
                               extractionsAfterFeedback.first(where: { $0.name == "iban" })?.value)
                XCTAssertEqual(fixtureExtractionsAfterFeedbackContainer.extractions.first(where: { $0.name == "paymentRecipient" })?.value,
                               extractionsAfterFeedback.first(where: { $0.name == "paymentRecipient" })?.value)
                XCTAssertEqual(fixtureExtractionsAfterFeedbackContainer.extractions.first(where: { $0.name == "paymentPurpose" })?.value,
                               extractionsAfterFeedback.first(where: { $0.name == "paymentPurpose" })?.value)
                XCTAssertEqual(fixtureExtractionsAfterFeedbackContainer.extractions.first(where: { $0.name == "bic" })?.value,
                               extractionsAfterFeedback.first(where: { $0.name == "bic" })?.value)
                XCTAssertEqual(fixtureExtractionsAfterFeedbackContainer.extractions.first(where: { $0.name == "amountToPay" })?.value,
                               extractionsAfterFeedback.first(where: { $0.name == "amountToPay" })?.value)
                expect.fulfill()
            case let .failure(error):
                XCTFail(String(describing: error))
            }
        })

//                    case let .failure(error):
//                        XCTFail(String(describing: error))
//                    }
        //               }
//            case let .failure(error):
//                XCTFail(String(describing: error))
//            }
    }

    wait(for: [expect], timeout: 60)
}

private func getExtractionsFromGiniCaptureSDK() -> [Extraction]? {
    let testDocumentData = loadFile(withName: "Gini_invoice_example", ofType: "pdf")
    let builder = GiniCaptureDocumentBuilder(documentSource: .appName(name: "GiniCaptureSDKExample"))
    let captureDocument = builder.build(with: testDocumentData)!
    documentService?.upload(document: captureDocument) { result in
        switch result {
        case let .success(createdDocument):
            docID = createdDocument.id
            self.documentService?.startAnalysis { result in
                switch result {
                case let .success(extractionResult):
                    print(extractionResult)
                    let extractions = extractionResult.extractions
                    return extractions
                case let .failure(error):
                    XCTFail(String(describing: error))
                }
            }
        case let .failure(error):
            XCTFail(String(describing: error))
            return []
        }
    }
}
