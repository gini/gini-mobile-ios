//
//  UploadDocumentsTests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import XCTest
import UIKit
import GiniHealthAPILibrary
import GiniHealthSDK

class UploadDocumentsTests: GiniHealthSDKIntegrationTestsBase {

    func testUploadLargeImageToGiniHealthAPI() throws {
        let expect = expectation(description: "Upload of image above 10MB to HealthAPILibrary with a local compression before")

        guard let imageData12MB = FileLoader.loadFile(withName: "invoice-12MB", ofType: "png") else {
            XCTFail("Failed to load test fixture: invoice-12MB.png is missing from test bundle")
            return
        }

        uploadDocumentAndGetExtractionFromGiniHealthAPILibrary(data: imageData12MB, expect: expect)

        wait(for: [expect], timeout: extendedTimeout)
    }

    func testFailUploadLargePDFToGiniHealthAPI() throws {
        let expect = expectation(description: "Upload of pdf above 10MB to HealthAPILibrary should fail. Local compression won't be done for this kind of file.")

        guard let pdfData13MB = FileLoader.loadFile(withName: "invoice-13MB", ofType: "pdf") else {
            XCTFail("Failed to load test fixture: invoice-13MB.pdf is missing from test bundle")
            return
        }

        uploadDocumentAndGetExtractionFromGiniHealthAPILibrary(data: pdfData13MB, expect: expect)

        wait(for: [expect], timeout: networkTimeout)
    }

    private func uploadDocumentAndGetExtractionFromGiniHealthAPILibrary(data: Data, expect: XCTestExpectation) {
        giniHealth.documentService.createDocument(fileName: nil, docType: .invoice, type: .partial(data), metadata: nil) { result in
            switch result {
            case .success(let createdDocument):
                self.giniHealth.documentService.extractions(for: createdDocument,
                                                            cancellationToken: CancellationToken()) { result in
                    switch result {
                    case let .success(extractionResult):
                        XCTAssertNotNil(extractionResult)
                        XCTAssertNotNil(extractionResult.payment)
                        guard let payment = extractionResult.payment?.first else {
                            XCTFail()
                            return
                        }
                        guard let iban = payment.first(where: { $0.name == "iban" }) else {
                            XCTFail()
                            return
                        }
                        XCTAssertNotNil(iban.value)
                        guard let recipient = payment.first(where: { $0.name == "payment_recipient" }) else {
                            XCTFail()
                            return
                        }
                        XCTAssertNotNil(recipient.value)
                        expect.fulfill()
                    case let .failure(error):
                        if data.isImage() {
                            XCTFail(String(describing: error))
                        }
                        expect.fulfill()
                    }
                }
            case .failure(let error):
                if data.isImage() {
                    XCTFail(String(describing: error))
                }
                expect.fulfill()
            }
        }
    }
}

