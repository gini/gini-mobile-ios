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

//    func testUploadLargeImageToGiniHealthAPI() {
//        let expect = expectation(description: "Upload of image above 10MB to HealthAPILibrary with a local compression before")
//
//        guard let imageData12MB = FileLoader.loadFile(withName: "invoice-12MB", ofType: "png") else { return }
//
//        self.uploadDocumentAndGetExtractionFromGiniHealthAPILibrary(data: imageData12MB, expect: expect)
//
//        wait(for: [expect], timeout: 60)
//    }

    func testFailUploadLargePDFToGiniHealthAPI() {
        let expect = expectation(description: "Upload of pdf above 10MB to HealthAPILibrary should fail. Local compression won't be done for this kind of file.")

        guard let pdfData13MB = FileLoader.loadFile(withName: "invoice-13MB", ofType: "pdf") else { return }

        self.uploadDocumentAndGetExtractionFromGiniHealthAPILibrary(data: pdfData13MB, expect: expect)

        wait(for: [expect], timeout: 30)
    }

    private func uploadDocumentAndGetExtractionFromGiniHealthAPILibrary(data: Data, expect: XCTestExpectation) {
        giniHelper.giniHealthAPIDocumentService.createDocument(fileName: nil,
                                                               docType: .invoice,
                                                               type: .partial(data),
                                                               metadata: nil) { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let createdDocument):
                    self.fetchAndValidateExtractions(for: createdDocument, expect: expect)
                case .failure(let error):
                    self.handleDocumentCreationFailure(error: error, data: data, expect: expect)
            }
        }
    }

    private func fetchAndValidateExtractions(for document: GiniHealthAPILibrary.Document, expect: XCTestExpectation) {
        giniHelper.giniHealthAPIDocumentService?.extractions(for: document,
                                                             cancellationToken: CancellationToken()) { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let extractionResult):
                    self.validateExtractionResult(extractionResult, expect: expect)
                case .failure(let error):
                    XCTFail(String(describing: error))
                    expect.fulfill()
            }
        }
    }

    private func validateExtractionResult(_ extractionResult: GiniHealthAPILibrary.ExtractionResult, expect: XCTestExpectation) {
        XCTAssertNotNil(extractionResult)
        XCTAssertNotNil(extractionResult.payment)

        guard let payment = extractionResult.payment?.first else {
            XCTFail("Payment information not found")
            expect.fulfill()
            return
        }

        validatePaymentFields(payment, expect: expect)
    }

    private func validatePaymentFields(_ payment: [GiniHealthAPILibrary.Extraction], expect: XCTestExpectation) {
        guard let iban = payment.first(where: { $0.name == "iban" }) else {
            XCTFail("IBAN not found in payment")
            expect.fulfill()
            return
        }
        XCTAssertNotNil(iban.value, "IBAN value should not be nil")

        guard let recipient = payment.first(where: { $0.name == "payment_recipient" }) else {
            XCTFail("Payment recipient not found")
            expect.fulfill()
            return
        }
        XCTAssertNotNil(recipient.value, "Recipient value should not be nil")

        expect.fulfill()
    }

    private func handleDocumentCreationFailure(error: Error, data: Data, expect: XCTestExpectation) {
        if data.isImage() {
            XCTFail(String(describing: error))
        }
        expect.fulfill()
    }
}

