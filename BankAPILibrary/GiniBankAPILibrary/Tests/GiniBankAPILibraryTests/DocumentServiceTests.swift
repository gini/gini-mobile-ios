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
        let expect = expectation(description: "feedback will be successfully sent")
        let document: Document = loadDocument(fileName: "compositeDocument", type: "json")
        let extractionResult = loadExtractionResults(fileName: "feedbackExtractions", type: "json")
        var amountToPayFromLoadedFeedbackValue = ""
        let feedbackData =
            loadFile(withName: "feedbackToSend", ofType: "json")
        if let json = try? JSONSerialization.jsonObject(with: feedbackData, options: .mutableContainers) {
            if let dictionary = json as? [String: [Extraction]] {
                if let extractions = dictionary["extractions"] {
                    let amountToPayFromLoadedFeedback = extractions.first {
                        $0.name == "amountToPay"
                    }
                    amountToPayFromLoadedFeedbackValue = amountToPayFromLoadedFeedback?.value ?? ""
                }
            }
            let amountToPayExtraction = extractionResult.extractions.first {
                $0.name == "amountToPay"
            }
            let amountToPay = amountToPayExtraction?.value ?? ""

            if let compoundExtractions = extractionResult.compoundExtractions {
                if let lineItems = compoundExtractions.lineItems {
                    let filteredCompoundExtractions = ["lineItems": [lineItems.first!]]

                    let pay4Keys = ["amountToPay", "iban", "reference", "paymentRecipient"]

                    defaultDocumentService.submitFeedback(for: document, with: extractionResult.extractions.filter { extraction in
                        pay4Keys.contains(extraction.name ?? "")
                    },
                    and: filteredCompoundExtractions) { result in
                        switch result {
                        case .success:
                            DispatchQueue.main.async {
                                if let jsonFromFeedbackHttpBody = try? JSONSerialization.jsonObject(with: self.sessionManagerMock.extractionFeedbackBody!, options: .mutableContainers) {
                                    if let dictionary = jsonFromFeedbackHttpBody as? [String: [Extraction]] {
                                        if let extractions = dictionary["extractions"] {
                                            let amountToPayFromHttpBodyExtraction = extractions.first {
                                                $0.name == "amountToPay"
                                            }

                                            XCTAssertEqual(amountToPay,
                                                           amountToPayFromHttpBodyExtraction?.value ?? "",
                                                           "amout to pay values should match")
                                            XCTAssertEqual(amountToPay,
                                                           amountToPayFromLoadedFeedbackValue,
                                                           "amout to pay values should match")
                                        }
                                    } else {
                                        print("json data malformed")
                                    }
                                }
                                expect.fulfill()
                            }
                        case .failure:
                            break
                        }
                        self.wait(for: [expect], timeout: 1)
                    }
                }
            }
        }
    }
    
    func testLogErrorEvent() {
        let expect = expectation(description: "it logs the error event")
        
        let errorEvent = ErrorEvent(deviceModel: UIDevice.current.model,
                                    osName: UIDevice.current.systemName,
                                    osVersion: UIDevice.current.systemVersion,
                                    captureSdkVersion: "Not available",
                                    apiLibVersion: "3.3.0",
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
