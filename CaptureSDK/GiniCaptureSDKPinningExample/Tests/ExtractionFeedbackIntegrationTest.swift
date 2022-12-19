//
//  ExtractionFeedbackIntegrationTest.swift
//  GiniCaptureSDKExampleTests
//
//  Created by Nadya Karaban on 04.03.22.
//
// swiftlint:disable all

import Foundation

@testable import GiniBankAPILibrary
@testable import GiniBankAPILibraryPinning
@testable import GiniCaptureSDK
@testable import GiniCaptureSDKPinning
@testable import TrustKit

import XCTest
class ExtractionFeedbackIntegrationTest: XCTestCase {
    let clientId = ProcessInfo.processInfo.environment["CLIENT_ID"]!
    let clientSecret = ProcessInfo.processInfo.environment["CLIENT_SECRET"]!
    var giniBankAPILib: GiniBankAPI!
    var giniCaptureSDKDocumentService: GiniCaptureSDK.DocumentService!
    var giniBankAPIDocumentService: GiniBankAPILibrary.DefaultDocumentService!
    var feedbackSendingGroup: DispatchGroup!
    
    override func setUp() {
        let yourPublicPinningConfig = [
            kTSKPinnedDomains: [
            "pay-api.gini.net": [
                kTSKPublicKeyHashes: [
                // old *.gini.net public key
                "cNzbGowA+LNeQ681yMm8ulHxXiGojHE8qAjI+M7bIxU=",
                // new *.gini.net public key, active from around June 2020
                "zEVdOCzXU8euGVuMJYPr3DUU/d1CaKevtr0dW0XzZNo="
            ]],
            "user.gini.net": [
                kTSKPublicKeyHashes: [
                // old *.gini.net public key
                "cNzbGowA+LNeQ681yMm8ulHxXiGojHE8qAjI+M7bIxU=",
                // new *.gini.net public key, active from around June 2020
                "zEVdOCzXU8euGVuMJYPr3DUU/d1CaKevtr0dW0XzZNo="
            ]],
        ]] as [String: Any]
        let client = Client(id: clientId,
                            secret: clientSecret,
                            domain: "capture-sdk-example")
        giniBankAPILib = GiniBankAPI
            .Builder(client: client, pinningConfig: yourPublicPinningConfig).build()
        
        giniCaptureSDKDocumentService = DocumentService(lib: giniBankAPILib, metadata: nil)
        
        giniBankAPIDocumentService = giniBankAPILib.documentService()
        
        feedbackSendingGroup = DispatchGroup()
    }

    func loadFile(withName name: String, ofType type: String) -> Data {
        let fileURLPath: String? = Bundle.main
            .path(forResource: name, ofType: type)
        let data = try? Data(contentsOf: URL(fileURLWithPath: fileURLPath!))

        return data!
    }
    
    func testSendExtractionFeedback() {
        let expect = expectation(description: "feedback was correctly sent and extractions were updated")
        
        // 1a. Getting the extractions for the uploaded document.
        // (subsequent steps are in CaptureResultsDelegateForExtractionsFeedbackTest)
        self.getExtractionsFromGiniCaptureSDK(delegate: CaptureResultsDelegateForExtractionsFeedbackTest(integrationTest: self, expect: expect))
        
        wait(for: [expect], timeout: 65)
    }
    
    /**
     * This GiniCaptureResultsDelegate implementation shows you how you can send feedback for the extractions you receive.
     */
    class CaptureResultsDelegateForExtractionsFeedbackTest: GiniCaptureResultsDelegate {
        
        let integrationTest: ExtractionFeedbackIntegrationTest
        let expect: XCTestExpectation
        
        init(integrationTest: ExtractionFeedbackIntegrationTest, expect: XCTestExpectation) {
            self.integrationTest = integrationTest
            self.expect = expect
        }
        
        func giniCaptureAnalysisDidFinishWith(result: AnalysisResult) {
            // 1b. Received the extractions for the uploaded document
            let fixtureExtractionsJson = self.integrationTest.loadFile(withName: "result_Gini_invoice_example", ofType: "json")
            
            let fixtureExtractionsContainer = try! JSONDecoder().decode(ExtractionsContainer.self, from: fixtureExtractionsJson)
            
            // 2. Verify we received the correct extractions for this test
            XCTAssertEqual(fixtureExtractionsContainer.extractions.first(where: { $0.name == "iban" })?.value,
                           result.extractions["iban"]?.value)
            XCTAssertEqual(fixtureExtractionsContainer.extractions.first(where: { $0.name == "paymentRecipient" })?.value,
                           result.extractions["paymentRecipient"]?.value)
            XCTAssertEqual(fixtureExtractionsContainer.extractions.first(where: { $0.name == "paymentPurpose" })?.value,
                           result.extractions["paymentPurpose"]?.value)
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
                // 4. Send feedback for the extractions the user saw
                //    with the final (user confirmed or updated) extraction values
                
                self.integrationTest.feedbackSendingGroup.notify(queue: DispatchQueue.main) {
                    // 5. Verify that the extractions were updated
                    self.integrationTest.getUpdatedExtractionsFromGiniCaptureSDK(for: result.document!) { result in
                        switch result {
                        case let .success(extractionResult):
                            let extractionsAfterFeedback = extractionResult.extractions
                            let fixtureExtractionsAfterFeedbackJson = self.integrationTest.loadFile(withName: "result_Gini_invoice_example_after_feedback", ofType: "json")
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
                            
                            self.expect.fulfill()
                        case let .failure(error):
                            XCTFail(String(describing: error))
                        }
                    }
                }
            }
        }

        func giniCaptureDidEnterManually() {
        }
        
        func giniCaptureAnalysisDidFinishWithoutResults(_ showingNoResultsScreen: Bool) {
        }
        
        func giniCaptureDidCancelAnalysis() {
        }
    }
        
    /**
      * This method reproduces the document upload and analysis done by the Capture SDK.
      *
      * The intent of this method is to create extractions like the one your app
      * receives after a user analysed a document with the Capture SDK.
      *
      * In your production code you should not call `DocumentService` methods.
      * Interaction with the network service is handled by the Capture SDK internally.
      */
    private func getExtractionsFromGiniCaptureSDK(delegate: GiniCaptureResultsDelegate) {
        let testDocumentData = self.loadFile(withName: "Gini_invoice_example", ofType: "pdf")
        let builder = GiniCaptureDocumentBuilder(documentSource: .appName(name: "GiniCaptureSDKExample"))
        let captureDocument = builder.build(with: testDocumentData)!

        GiniConfiguration.shared.documentService = giniCaptureSDKDocumentService

        // Upload a test document
        giniCaptureSDKDocumentService.upload(document: captureDocument) { result in
            switch result {
            case .success(_):
                // Analyze the uploaded test document
                self.giniCaptureSDKDocumentService?.startAnalysis { result in
                    switch result {
                    case let .success(extractionResult):
                        let extractions: [String: Extraction] = Dictionary(uniqueKeysWithValues: extractionResult.extractions.compactMap {
                            guard let name = $0.name else { return nil }
                            
                            return (name, $0)
                        })
                        
                        let analysisResult = AnalysisResult(extractions: extractions,
                                                            lineItems: extractionResult.lineItems,
                                                            images: [],
                                                            document: self.giniCaptureSDKDocumentService?.document)

                        delegate.giniCaptureAnalysisDidFinishWith(result: analysisResult)
                        GiniConfiguration.shared.cleanup(paymentRecipient: extractions["paymentRecipient"]?.value ?? "",
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
      * This method reproduces the getting extractions for the already known document by the Capture SDK.
      * In your production code you should not call  any`GiniBankAPILibrary` methods.
      * Interaction with the network service is handled by the Capture SDK internally.
      */
    private func getUpdatedExtractionsFromGiniCaptureSDK(for document: Document, completion: @escaping AnalysisCompletion) {
        self.giniBankAPIDocumentService.extractions(for: document,
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
