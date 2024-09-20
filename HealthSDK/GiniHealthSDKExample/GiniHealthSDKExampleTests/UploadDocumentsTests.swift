//
//  UploadDocumentsTests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import XCTest
import UIKit
import GiniHealthAPILibrary
import GiniHealthSDK

class UploadDocumentsTests: XCTestCase {
    lazy var giniHelper = GiniSetupHelper()

    override func setUp() {
        giniHelper.setup()
    }

    func testUploadLargeImageToGiniHealthAPI() {
        let expect = expectation(description: "Upload of image above 10MB to HealthAPILibrary with a local compression before")

        guard let imageData12MB = FileLoader.loadFile(withName: "invoice-12MB", ofType: "png") else { return }

        self.uploadDocumentAndGetExtractionFromGiniHealthAPILibrary(data: imageData12MB, expect: expect)

        wait(for: [expect], timeout: 60)
    }

    func testFailUploadLargePDFToGiniHealthAPI() {
        let expect = expectation(description: "Upload of pdf above 10MB to HealthAPILibrary should fail. Local compression won't be done for this kind of file.")

        guard let pdfData13MB = FileLoader.loadFile(withName: "invoice-13MB", ofType: "pdf") else { return }

        self.uploadDocumentAndGetExtractionFromGiniHealthAPILibrary(data: pdfData13MB, expect: expect)

        wait(for: [expect], timeout: 60)
    }

    private func uploadDocumentAndGetExtractionFromGiniHealthAPILibrary(data: Data, expect: XCTestExpectation) {
        giniHelper.giniHealthAPIDocumentService.createDocument(fileName: nil, docType: .invoice, type: .partial(data), metadata: nil) { result in
            switch result {
            case .success(let createdDocument):
                self.giniHelper.giniHealthAPIDocumentService?.extractions(for: createdDocument,
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

