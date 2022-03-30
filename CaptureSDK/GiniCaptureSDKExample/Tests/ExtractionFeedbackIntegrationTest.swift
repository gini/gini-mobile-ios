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
    var giniBankAPIdocumentService: GiniBankAPILibrary.DefaultDocumentService!
    var uploadedDocument: Document?
    var sendFeedbackBlock: (([String: Extraction]) -> Void) = {_ in }
    var docId = ""
    override func setUp() {
        giniBankAPILib = GiniBankAPI
            .Builder(client: Client(id: clientId,
                                    secret: clientSecret,
                                    domain: "capture-sdk-example"))
            .build()
        documentService = DocumentService(lib: giniBankAPILib, metadata: nil)
        giniBankAPIdocumentService = giniBankAPILib.documentService()
        sendFeedbackBlock = { [self] updatedExtractions in
            let extractions = updatedExtractions.map {$0.1}
            documentService?.sendFeedback(with: extractions)
        }
    }

    func loadFile(withName name: String, ofType type: String) -> Data {
        let fileURLPath: String? = Bundle.main
            .path(forResource: name, ofType: type)
        let data = try? Data(contentsOf: URL(fileURLWithPath: fileURLPath!))

        return data!
    }

    func testSendExtractionFeedback() {
        let expect = expectation(description: "feedback was correctly sent and extractions were updated")

        var extractions: [Extraction] = []
        
        // 1. Getting the extractions for the uploaded document.
        self.getExtractionsFromGiniCaptureSDK { result in
            switch result {
            case let .success(extractionResult):
                DispatchQueue.main.async {
                    extractions.append(contentsOf: extractionResult.extractions)
                    let fixtureExtractionsJson = self.loadFile(withName: "result_Gini_invoice_example", ofType: "json")

                    let fixtureExtractionsContainer = try! JSONDecoder().decode(ExtractionsContainer.self, from: fixtureExtractionsJson)

                    // 2. Verify we received the correct extractions for this test
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
                    if extractions.first(where: { $0.name == "amountToPay" }) != nil {
                        
                        let extractionsForResult: [String: Extraction] = Dictionary(uniqueKeysWithValues: extractionResult.extractions.compactMap {
                            guard let name = $0.name else { return nil }
                            return (name, $0)
                        })
                        
                        // 4. Send feedback for the extractions the user saw
                        //    with the final (user confirmed or updated) extraction values
                        
                       self.sendFeedbackBlock(extractionsForResult)

                        // 5. Verify that the extractions were updated
                        self.getUpdatedExtractionsFromGiniCaptureSDK { result in
                            switch result {
                            case let .success(extractionResult):
                                DispatchQueue.main.async {
                                    let extractionsAfterFeedback = extractionResult.extractions
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
                                }

                            case let .failure(error):
                                XCTFail(String(describing: error))
                            }
                        }
                    }
                }
            case let .failure(error):
                XCTFail(String(describing: error))
            }
        }
        wait(for: [expect], timeout: 60)
    }
    
    /**
      * This method reproduces the document upload and analysis done by the Capture SDK.
      *
      * The intent of this method is to create an extractions like the one your app
      * receives after a user analysed a document with the Capture SDK.
      *
      * In your production code you should not call `DocumentService` methods.
      * Interaction with the network service is handled by the Capture SDK internally.
      */
    private func getExtractionsFromGiniCaptureSDK(completion: @escaping AnalysisCompletion) {
        let testDocumentData = loadFile(withName: "Gini_invoice_example", ofType: "pdf")
        let builder = GiniCaptureDocumentBuilder(documentSource: .appName(name: "GiniCaptureSDKExample"))
        let captureDocument = builder.build(with: testDocumentData)!
        
        // Upload a test document
        documentService?.upload(document: captureDocument) { result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case let .success(createdDocument):
                    self?.uploadedDocument = createdDocument
                    print(createdDocument)
                    
                    // Analyze the uploaded test document
                    self?.documentService?.startAnalysis { result in
                        switch result {
                        case let .success(extractionResult):
                            self?.uploadedDocument = self?.documentService?.document
                            completion(.success(extractionResult))
                        case let .failure(error):
                            completion(.failure(error))
                        }
                    }
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }

    /**
      * This method reproduces the getting extractions for the already known document by the Capture SDK.
      * In your production code you should not call  any`GiniBankAPILibrary` methods.
      * Interaction with the network service is handled by the Capture SDK internally.
      */
    private func getUpdatedExtractionsFromGiniCaptureSDK(completion: @escaping AnalysisCompletion){
        self.giniBankAPIdocumentService.extractions(for: (self.uploadedDocument)!,
                           cancellationToken: CancellationToken()) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(extractionResult):
                    completion(.success(extractionResult))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }
}
