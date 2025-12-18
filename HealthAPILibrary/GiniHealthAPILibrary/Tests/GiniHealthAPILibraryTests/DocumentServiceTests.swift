//
//  DocumentServicesTests.swift
//  GiniHealthAPI-Unit-Tests
//
//  Created by Enrique del Pozo Gómez on 3/26/19.
//

@testable import GiniHealthAPILibrary
import XCTest
import UIKit
final class DocumentServicesTests: XCTestCase {
    var sessionManagerMock: SessionManagerMock!
    var defaultDocumentService: DefaultDocumentService!
    let versionAPI = 4

    override func setUp() {
        sessionManagerMock = SessionManagerMock()
        defaultDocumentService = DefaultDocumentService(sessionManager: sessionManagerMock, apiVersion: versionAPI)
    }

    func testPartialDocumentCreation() {
        let expect = expectation(description: "it returns a partial document")

        defaultDocumentService.createDocument(fileName: "",
                                              docType: nil,
                                              type: .partial(Data(count: 1)),
                                              metadata: nil) { result in
            switch result {
            case let .success(document):
                XCTAssertEqual(document.id,
                               SessionManagerMock.partialDocumentId,
                               "document ids should match")
                expect.fulfill()
            case .failure:
                break
            }
        }

        wait(for: [expect], timeout: 1)
    }

    func testPartialDocumentCreationWithImageCompression() {
        // Should check size of a big image
        let range = 6635000...6636000 // We need this range because on different machines, the compression is a bit bigger or smaller

        guard let imageData12MB = UIImage(named: "invoice-12MB", in: Bundle.module, compatibleWith: nil)?.pngData() else { return }
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
        let expect = expectation(description: "it returns a composite document")

        defaultDocumentService.createDocument(fileName: "",
                                              docType: nil,
                                              type: .composite(CompositeDocumentInfo(partialDocuments: [])),
                                              metadata: nil) { result in
            switch result {
            case let .success(document):
                XCTAssertEqual(document.id,
                               SessionManagerMock.compositeDocumentId,
                               "document ids should match")
                expect.fulfill()
            case .failure:
                break
            }
        }

        wait(for: [expect], timeout: 1)
    }

    func testPartialDocumentDeletion() {
        let expect = expectation(description: "it deletes the partial document")
        sessionManagerMock.initializeWithV2MockedDocuments()
        let document: Document = loadDocument(fileName: "partialDocument", type: "json")

        defaultDocumentService.delete(document) { result in
            switch result {
            case .success:
                XCTAssertTrue(self.sessionManagerMock.documents.isEmpty, "documents should be empty")
                expect.fulfill()
            case .failure:
                break
            }
        }

        wait(for: [expect], timeout: 1)
    }

    func testCompositeDocumentDeletion() {
        let expect = expectation(description: "it deletes the composite document")
        sessionManagerMock.initializeWithV2MockedDocuments()
        let document: Document = loadDocument(fileName: "compositeDocument", type: "json")

        defaultDocumentService.delete(document) { result in
            switch result {
            case .success:
                XCTAssertEqual(self.sessionManagerMock.documents.count, 1,
                               "there should be one aprtial document left")
                expect.fulfill()
            case .failure:
                break
            }
        }

        wait(for: [expect], timeout: 1)
    }

    func loadDocument(fileName: String, type: String) -> Document {
        let jsonData = loadFile(withName: fileName, ofType: type)

        return (try? JSONDecoder().decode(Document.self, from: jsonData))!
    }

    func loadExtractionResults(fileName: String, type: String) -> ExtractionsContainer {
        let jsonData = loadFile(withName: fileName, ofType: type)

        return (try? JSONDecoder().decode(ExtractionsContainer.self, from: jsonData))!
    }
    
    func loadPages(fileName: String, type: String) -> [Document.Page] {
        let jsonData = loadFile(withName: fileName, ofType: type)

        return (try? JSONDecoder().decode([Document.Page].self, from: jsonData))!
    }

    func testSubmitFeedback() {
        let expect = expectation(description: "feedback will be successfully sent")
        let document: Document = loadDocument(fileName: "compositeDocument", type: "json")
        let extractionResult = loadExtractionResults(fileName: "feedbackExtractions", type: "json")
        var amountToPayFromLoadedFeedbackValue = ""
        let feedbackData = loadFile(withName: "feedbackToSend", ofType: "json")

        guard let json = try? JSONSerialization.jsonObject(with: feedbackData, options: .mutableContainers) else {
            return
        }

        if let dictionary = json as? [String: [Extraction]],
           let extractions = dictionary["extractions"] {
            let amountToPayFromLoadedFeedback = extractions.first {
                $0.name == "amountToPay"
            }
            amountToPayFromLoadedFeedbackValue = amountToPayFromLoadedFeedback?.value ?? ""
        }

        let amountToPayExtraction = extractionResult.extractions.first {
            $0.name == "amountToPay"
        }
        let amountToPay = amountToPayExtraction?.value ?? ""

        submitFeedbackWithCompoundExtractions(document: document,
                                              extractionResult: extractionResult,
                                              amountToPay: amountToPay,
                                              amountToPayFromLoadedFeedback: amountToPayFromLoadedFeedbackValue,
                                              expectation: expect)
    }
    
    func testUrlStringForHighestResolutionPreview() {
        let expect = expectation(description: "it returns the preview image with the biggest resolution area less than 4000000 pixels")
        sessionManagerMock.initializeWithV2MockedDocuments()
        let pages: [Document.Page] = loadPages(fileName: "pages", type: "json")
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

private extension DocumentServicesTests {

    func submitFeedbackWithCompoundExtractions(document: Document,
                                               extractionResult: ExtractionsContainer,
                                               amountToPay: String,
                                               amountToPayFromLoadedFeedback: String,
                                               expectation: XCTestExpectation) {
        guard let compoundExtractions = extractionResult.compoundExtractions,
              let lineItems = compoundExtractions["lineItems"] ,
              let firstLineItem = lineItems.first else {
            XCTFail("Missing compound extractions or line items")
            return
        }

        let filteredCompoundExtractions = ["lineItems": [firstLineItem]]
        let pay4Keys = ["amountToPay", "iban", "reference", "paymentRecipient"]
        let filteredExtractions = extractionResult.extractions.filter { extraction in
            pay4Keys.contains(extraction.name ?? "")
        }

        defaultDocumentService.submitFeedback(for: document,
                                              with: filteredExtractions,
                                              and: filteredCompoundExtractions) { result in
            switch result {
                case .success:
                    self.verifySuccessfulSubmission(amountToPay: amountToPay,
                                                    amountToPayFromLoadedFeedback: amountToPayFromLoadedFeedback,
                                                    expectation: expectation)
                case .failure:
                    break
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    private func verifySuccessfulSubmission(amountToPay: String,
                                            amountToPayFromLoadedFeedback: String,
                                            expectation: XCTestExpectation) {
        DispatchQueue.main.async {
            guard let httpBody = self.sessionManagerMock.extractionFeedbackBody,
                  let dictionary = try? JSONSerialization.jsonObject(with: httpBody, options: .mutableContainers) as? [String: [Extraction]],
                  let extractions = dictionary["extractions"] else {
                print("json data malformed")
                expectation.fulfill()
                return
            }

            let amountToPayFromHttpBodyExtraction = extractions.first {
                $0.name == "amountToPay"
            }

            XCTAssertEqual(amountToPay,
                           amountToPayFromHttpBodyExtraction?.value ?? "",
                           "amout to pay values should match")
            XCTAssertEqual(amountToPay,
                           amountToPayFromLoadedFeedback,
                           "amout to pay values should match")

            expectation.fulfill()
        }
    }
}
