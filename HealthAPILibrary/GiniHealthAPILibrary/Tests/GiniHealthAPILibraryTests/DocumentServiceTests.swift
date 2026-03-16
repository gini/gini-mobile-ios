//
//  DocumentServicesTests.swift
//  GiniHealthAPILibraryTests
//
//  Copyright © 2019 Gini GmbH. All rights reserved.
//

@testable import GiniHealthAPILibrary
import XCTest
import UIKit
final class DocumentServicesTests: DocumentServiceTestBase {

    func testPartialDocumentCreation() {
        awaitSuccess(description: "it returns a partial document") { done in
            self.defaultDocumentService.createDocument(fileName: "",
                                                       docType: nil,
                                                       type: .partial(Data(count: 1)),
                                                       metadata: nil) { result in done(result) }
        } validate: { document in
            XCTAssertEqual(document.id,
                           SessionManagerMock.partialDocumentId,
                           "document ids should match")
        }
    }

    func testPartialDocumentCreationWithImageCompression() throws {
        // Should check size of a big image
        let range = 6635000...6636000 // We need this range because on different machines, the compression is a bit bigger or smaller

        guard let imageData12MB = UIImage(named: "invoice-12MB", in: Bundle.module, compatibleWith: nil)?.pngData() else {
            throw XCTSkip("Test fixture 'invoice-12MB' is missing from test bundle")
        }
        let imageDataProcessed = defaultDocumentService.processDataIfNeeded(data: imageData12MB)

        XCTAssertTrue(range.contains(imageDataProcessed?.count ?? 0))
    }

    func testDocumentCreationWithBigPDF() {
        // Should check size of a big PDF
        let pdfData13MB = loadFile(withName: "invoice-13MB", ofType: "pdf")
        let expectedSize = pdfData13MB.count
        let imageDataProcessed = defaultDocumentService.processDataIfNeeded(data: pdfData13MB)

        XCTAssertEqual(imageDataProcessed?.count ?? 0, expectedSize)
    }

    func testCompositeDocumentCreation() {
        awaitSuccess(description: "it returns a composite document") { done in
            self.defaultDocumentService.createDocument(fileName: "",
                                                       docType: nil,
                                                       type: .composite(CompositeDocumentInfo(partialDocuments: [])),
                                                       metadata: nil) { result in done(result) }
        } validate: { document in
            XCTAssertEqual(document.id,
                           SessionManagerMock.compositeDocumentId,
                           "document ids should match")
        }
    }

    func testPartialDocumentDeletion() {
        sessionManagerMock.initializeWithV2MockedDocuments()
        let document: Document = load(fromFile: "partialDocument", type: "json")

        awaitSuccess(description: "it deletes the partial document") { done in
            self.defaultDocumentService.delete(document) { result in done(result) }
        } validate: { _ in
            XCTAssertTrue(self.sessionManagerMock.documents.isEmpty, "documents should be empty")
        }
    }

    func testCompositeDocumentDeletion() {
        sessionManagerMock.initializeWithV2MockedDocuments()
        let document: Document = load(fromFile: "compositeDocument", type: "json")

        awaitSuccess(description: "it deletes the composite document") { done in
            self.defaultDocumentService.delete(document) { result in done(result) }
        } validate: { _ in
            XCTAssertEqual(self.sessionManagerMock.documents.count, 1,
                           "there should be one aprtial document left")
        }
    }

    func testSubmitFeedback(){
        let expect = expectation(description: "feedback will be successfully sent")
        let document: Document = load(fromFile: "compositeDocument", type: "json")
        let extractionResult: ExtractionsContainer = load(fromFile: "feedbackExtractions", type: "json")
        let feedbackData = loadFile(withName: "feedbackToSend", ofType: "json")

        struct ExtractionValue: Decodable {
            let value: String
        }
        struct FeedbackPayload: Decodable {
            let extractions: [String: ExtractionValue]
        }

        let feedbackPayload: FeedbackPayload
        do {
            feedbackPayload = try JSONDecoder().decode(FeedbackPayload.self, from: feedbackData)
        } catch {
            XCTFail("Failed to parse feedbackToSend.json: \(error)")
            return
        }

        let amountToPayFromLoadedFeedbackValue = feedbackPayload.extractions["amountToPay"]?.value ?? ""
        let amountToPay = extractionResult.extractions.first { $0.name == "amountToPay" }?.value ?? ""

        guard let compoundExtractions = extractionResult.compoundExtractions,
              let lineItems = compoundExtractions["lineItems"],
              let firstLineItem = lineItems.first else {
                  XCTFail("No lineItems found in extraction results")
                  return
              }

        let filteredCompoundExtractions = ["lineItems": [firstLineItem]]
        let pay4Keys = ["amountToPay", "iban", "reference", "paymentRecipient"]

        defaultDocumentService.submitFeedback(for: document,
                                              with: extractionResult.extractions.filter { pay4Keys.contains($0.name ?? "") },
                                              and: filteredCompoundExtractions) { result in
            switch result {
            case .success:
            guard let body = self.sessionManagerMock.extractionFeedbackBody else {
                XCTFail("extractionFeedbackBody is nil")
                expect.fulfill()
                return
            }

            let bodyPayload: FeedbackPayload
            do {
                bodyPayload = try JSONDecoder().decode(FeedbackPayload.self, from: body)
            } catch {
                XCTFail("Failed to parse HTTP body extractions: \(error)")
                expect.fulfill()
                return
            }

            let amountToPayFromHttpBody = bodyPayload.extractions["amountToPay"]?.value ?? ""
            XCTAssertEqual(amountToPay, amountToPayFromHttpBody, "amount to pay values should match")
            XCTAssertEqual(amountToPay, amountToPayFromLoadedFeedbackValue, "amount to pay values should match")

            case .failure(let error):
            XCTFail("submitFeedback failed with error: \(error)")
            }
            expect.fulfill()
        }

        wait(for: [expect], timeout: 5)
}

    func testUrlStringForHighestResolutionPreview() {
        let expect = expectation(description: "it returns the preview image with the biggest resolution area less than 4000000 pixels")
        sessionManagerMock.initializeWithV2MockedDocuments()
        let pages: [Document.Page] = load(fromFile: "pages", type: "json")
        if let page = pages.first {
            let urlStringForHighestResolutionPreview = defaultDocumentService.urlStringForHighestResolutionPreview(page: page)
            print(urlStringForHighestResolutionPreview)
            XCTAssertEqual(urlStringForHighestResolutionPreview, "/documents/dcd0c7a0-8382-11ec-9fb5-a5611818595c/pages/1/1280x1810",
                           "there url strings should be equal")
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 1)
    }

}
