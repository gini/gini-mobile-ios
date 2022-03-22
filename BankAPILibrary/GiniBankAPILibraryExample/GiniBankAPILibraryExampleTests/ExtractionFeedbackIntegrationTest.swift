//
//  ExtractionFeedbackIntegrationTest.swift
//  GiniBankAPILibraryExampleTests
//
//  Created by Nadya Karaban on 04.03.22.
//

import Foundation

import XCTest
@testable import GiniBankAPILibrary

class ExtractionFeedbackIntegrationTest: XCTestCase {
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
    
    func testSendExtractionFeedback() {

        let expect = expectation(description: "it logs the error event")

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
                        self.documentService.extractions(for: compositeDocument, cancellationToken: CancellationToken()) { result in
                            switch result {
                            case .success(let extractionResult):
                                let extractions = extractionResult.extractions
                                
                                let fixtureJsonExtractionsJson = self.loadFile(withName: "result_Gini_invoice_example", ofType: "json")

                                let fixtureExtractionsContainer = try! JSONDecoder().decode(ExtractionsContainer.self, from: fixtureJsonExtractionsJson)

                                print(fixtureExtractionsContainer.extractions)
                                XCTAssertEqual(fixtureExtractionsContainer.extractions, extractions)
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
        wait(for: [expect], timeout: 15)
    }
}
