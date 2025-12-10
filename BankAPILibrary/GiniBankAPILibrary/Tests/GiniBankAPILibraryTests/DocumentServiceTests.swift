//
//  DocumentServicesTests.swift
//  GiniBankAPI-Unit-Tests
//
//  Created by Enrique del Pozo Gómez on 3/26/19.
//

@testable import GiniBankAPILibrary
import XCTest
import UIKit
final class DocumentServicesTests: XCTestCase {
    var sessionManagerMock: SessionManagerMock!
    var defaultDocumentService: DefaultDocumentService!

    override func setUp() {
        sessionManagerMock = SessionManagerMock()
        defaultDocumentService = DefaultDocumentService(sessionManager: sessionManagerMock)
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

    func testSubmitFeedback() {
        // Setup test expectation and load test data
        let expect = expectation(description: "feedback will be successfully sent")
        let document: Document = loadDocument(fileName: "compositeDocument", type: "json")
        let extractionResult = loadExtractionResults(fileName: "feedbackExtractions", type: "json")

        // Initialize variable to store the expected amount from feedback file
        var amountToPayFromLoadedFeedbackValue = ""
        let feedbackData = loadFile(withName: "feedbackToSend", ofType: "json")

        guard let json = try? JSONSerialization.jsonObject(with: feedbackData, options: .mutableContainers) else {
            return
        }

        // Extract amount to pay from the feedback test data
        if let dictionary = json as? [String: [Extraction]],
           let extractions = dictionary["extractions"] {
            let amountToPayFromLoadedFeedback = extractions.first {
                $0.name == "amountToPay"
            }
            amountToPayFromLoadedFeedbackValue = amountToPayFromLoadedFeedback?.value ?? ""
        }

        // Extract amount to pay from the extraction result that will be submitted
        let amountToPayExtraction = extractionResult.extractions.first {
            $0.name == "amountToPay"
        }
        let amountToPay = amountToPayExtraction?.value ?? ""

        // Submit the feedback and verify the results
        submitFeedbackWithCompoundExtractions(document: document,
                                              extractionResult: extractionResult,
                                              amountToPay: amountToPay,
                                              amountToPayFromLoadedFeedback: amountToPayFromLoadedFeedbackValue,
                                              expectation: expect)
    }

    func testLogErrorEvent() {
        let expect = expectation(description: "it logs the error event")
        
        let errorEvent = ErrorEvent(deviceModel: UIDevice.current.model,
                                    osName: UIDevice.current.systemName,
                                    osVersion: UIDevice.current.systemVersion,
                                    captureSdkVersion: "Not available",
                                    apiLibVersion: "3.9.0",
                                    description: "Error logging test",
                                    documentId: "1234",
                                    originalRequestId: "5678")

        defaultDocumentService.log(errorEvent: errorEvent) { result in
            switch result {
            case .success:
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                if let body = self.sessionManagerMock.logErrorEventBody,
                   let decoded = try? decoder.decode(ErrorEvent.self, from: body) {
                    XCTAssertEqual(errorEvent, decoded)
                    expect.fulfill()
                }
            case .failure:
                break
            }
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
              let lineItems = compoundExtractions.lineItems,
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

    func verifySuccessfulSubmission(amountToPay: String,
                                    amountToPayFromLoadedFeedback: String,
                                    expectation: XCTestExpectation) {
        DispatchQueue.main.async {
            guard let httpBody = self.sessionManagerMock.extractionFeedbackBody,
                  let json = try? JSONSerialization.jsonObject(with: httpBody, options: .mutableContainers) as? [String: [Extraction]],
                  let extractions = json["extractions"],
                  let amountToPayFromHttpBody = extractions.first(where: { $0.name == "amountToPay" })?.value else {
                XCTFail("json data malformed or missing amount")
                expectation.fulfill()
                return
            }

            XCTAssertEqual(amountToPay,
                           amountToPayFromHttpBody,
                           "amount to pay values should match")
            XCTAssertEqual(amountToPay,
                           amountToPayFromLoadedFeedback,
                           "amount to pay values should match")

            expectation.fulfill()
        }
    }
}
