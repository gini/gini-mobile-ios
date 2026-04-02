import XCTest
@testable import GiniHealthSDK
@testable import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK
@testable import GiniUtilites

final class GiniHealthExtractionsHandlingTests: GiniHealthTestCase {

    // MARK: - Helper

    private func loadExtractionsContainer(fromFile fileName: String) throws -> GiniHealthSDK.ExtractionsContainer {
        try XCTUnwrap(GiniHealthSDKTests.load(fromFile: fileName) as GiniHealthSDK.ExtractionsContainer?,
                      "Error loading file: `\(fileName).json`")
    }

    func testDocumentIsPayable() throws {
        let extractions = try loadExtractionsContainer(fromFile: "extractionResultWithIBAN")
        let extractionsResult = ExtractionResult(extractionsContainer: extractions)
        let isPayable = extractionsResult.extractions.first(where: { $0.name == ExtractionType.paymentState.rawValue })?.value == GiniHealthSDK.PaymentState.payable.rawValue
        // Then
        XCTAssertEqual(isPayable, true, "Document should be payable when IBAN is present")
    }
    
    func testDocumentIsNotPayableSuccess() throws {
        let extractions = try loadExtractionsContainer(fromFile: "extractionResultWithoutIBAN")
        let extractionsResult = ExtractionResult(extractionsContainer: extractions)
        let isPayable = extractionsResult.extractions.first(where: { $0.name == ExtractionType.paymentState.rawValue })?.value == GiniHealthSDK.PaymentState.payable.rawValue
        // Then
        XCTAssertEqual(isPayable, false, "Document should not be payable when IBAN is absent")
    }

    func testCheckIfDocumentIsPayableSuccess() throws {
        let expectedExtractions = try loadExtractionsContainer(fromFile: "extractionResultWithIBAN")
        let expectedExtractionsResult = GiniHealthSDK.ExtractionResult(extractionsContainer: expectedExtractions)
        let expectedIsPayable = expectedExtractionsResult.extractions.first(where: { $0.name == "iban" })?.value.isNotEmpty

        // When
        let expectation = self.expectation(description: "Checking if document is payable")
        var isDocumentPayable: Bool?
        giniHealth.checkIfDocumentIsPayable(docId: MockSessionManager.payableDocumentID) { result in
            switch result {
            case .success(let isPayable):
                isDocumentPayable = isPayable
            case .failure(_):
                isDocumentPayable = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertEqual(expectedIsPayable, isDocumentPayable, "Payable status should match the expected value based on IBAN presence")
    }

    func testCheckIfDocumentIsNotPayableSuccess() throws {
        let expectedExtractions = try loadExtractionsContainer(fromFile: "extractionResultWithIBAN")
        let expectedExtractionsResult = ExtractionResult(extractionsContainer: expectedExtractions)
        let expectedIsPayable = expectedExtractionsResult.extractions.first(where: { $0.name == "iban" })?.value.isEmpty

        // When
        let expectation = self.expectation(description: "Checking if document is not payable")
        var isDocumentPayable: Bool?
        giniHealth.checkIfDocumentIsPayable(docId: MockSessionManager.notPayableDocumentID) { result in
            switch result {
            case .success(let isPayable):
                isDocumentPayable = isPayable
            case .failure(_):
                isDocumentPayable = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertEqual(expectedIsPayable, isDocumentPayable, "Payable status should match the expected value when IBAN is absent")
    }

    func testCheckIfDocumentIsPayableFailure() {
        // When
        let expectation = self.expectation(description: "Checking if request fails")
        var isDocumentPayable: Bool?
        giniHealth.checkIfDocumentIsPayable(docId: MockSessionManager.failurePayableDocumentID) { result in
            switch result {
            case .success(let isPayable):
                isDocumentPayable = isPayable
            case .failure(_):
                isDocumentPayable = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertNil(isDocumentPayable, "Payable status should be nil when the request fails")
    }

    func testCheckIfDocumentContainMultipleInvoicesSuccess() {
        // When
        let expectation = self.expectation(description: "Checking if document contains multiple invoices")
        var hasMultipleInvoices: Bool?
        giniHealth.checkIfDocumentContainsMultipleInvoices(docId: MockSessionManager.notPayableDocumentID) { result in
            switch result {
            case .success(let containsMultipleDocs):
                hasMultipleInvoices = containsMultipleDocs
            case .failure(_):
                hasMultipleInvoices = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)

        // Then
        XCTAssertEqual(true, hasMultipleInvoices, "Document should contain multiple invoices")
    }

    func testCheckIfDocumentDontContainMultipleInvoicesSuccess() {
        // When
        let expectation = self.expectation(description: "Checking if document don't contain multiple invoices")
        var hasMultipleInvoices: Bool?
        giniHealth.checkIfDocumentContainsMultipleInvoices(docId: MockSessionManager.payableDocumentID) { result in
            switch result {
            case .success(let containsMultipleDocs):
                    hasMultipleInvoices = containsMultipleDocs
            case .failure(_):
                    hasMultipleInvoices = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertEqual(false, hasMultipleInvoices, "Document should not contain multiple invoices")
    }

    func testCheckIfDocumentContainMultipleInvoicesFailure() {
        // When
        let expectation = self.expectation(description: "Checking if request fails")
        var hasMultipleInvoices: Bool?
        giniHealth.checkIfDocumentContainsMultipleInvoices(docId: MockSessionManager.failurePayableDocumentID) { result in
            switch result {
            case .success(let containsMultipleDocs):
                hasMultipleInvoices = containsMultipleDocs
            case .failure(_):
                hasMultipleInvoices = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertNil(hasMultipleInvoices, "Multiple invoices check should be nil when the request fails")
    }
    
    func testGetExtractionsSuccess() throws {
        let expectedExtractionContainer = try loadExtractionsContainer(fromFile: "extractionsWithPayment")
        let expectedExtractions: [GiniHealthSDK.Extraction] = ExtractionResult(extractionsContainer: expectedExtractionContainer).payment?.first ?? []

        // When
        let expectation = self.expectation(description: "Getting extractions")
        var receivedExtractions: [GiniHealthSDK.Extraction]?
        giniHealth.getExtractions(docId: MockSessionManager.extractionsWithPaymentDocumentID) { result in
            switch result {
            case .success(let extractions):
                receivedExtractions = extractions
            case .failure(_):
                receivedExtractions = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertNotNil(receivedExtractions, "Received extractions should not be nil")
        XCTAssertEqual(receivedExtractions?.count, expectedExtractions.count, "Received extractions count should match expected count")
    }
    
    func testGetExtractionsFailure() {
        // When
        let expectation = self.expectation(description: "Extraction failure")
        var receivedExtractions: [GiniHealthSDK.Extraction]?
        giniHealth.getExtractions(docId: MockSessionManager.failurePayableDocumentID) { result in
            switch result {
            case .success(let extractions):
                receivedExtractions = extractions
            case .failure(_):
                receivedExtractions = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertNil(receivedExtractions, "Extractions should be nil when the request fails")
    }

    func testGetAllExtractionsSuccess() throws {
        let expectedExtractionContainer = try loadExtractionsContainer(fromFile: "test_doctorsname")
        let expectedExtractions: [GiniHealthSDK.Extraction] = ExtractionResult(extractionsContainer: expectedExtractionContainer).extractions

        // When
        let expectation = self.expectation(description: "Getting all extractions")
        var receivedExtractions: [GiniHealthSDK.Extraction]?
        giniHealth.getAllExtractions(docId: MockSessionManager.doctorsNameDocumentID) { result in
            switch result {
            case .success(let extractions):
                receivedExtractions = extractions
            case .failure(_):
                receivedExtractions = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertNotNil(receivedExtractions, "Received extractions should not be nil")
        XCTAssertEqual(receivedExtractions?.count, expectedExtractions.count, "Received extractions count should match expected count")
    }

    func testGetAllExtractionsFailure() {
        // When
        let expectation = self.expectation(description: "Extraction failure")
        var receivedExtractions: [GiniHealthSDK.Extraction]?
        giniHealth.getAllExtractions(docId: MockSessionManager.failurePayableDocumentID) { result in
            switch result {
            case .success(let extractions):
                receivedExtractions = extractions
            case .failure(_):
                receivedExtractions = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertNil(receivedExtractions, "Extractions should be nil when the request fails")
    }

    func testGetDoctorsNameExtractionsSuccess() {
        // Given
        let expectedDoctorName = "DR. SOMMER TEAM"

        // When
        let expectation = self.expectation(description: "Getting doctor name extractions")
        var receivedDoctorExtraction: GiniHealthSDK.Extraction?
        giniHealth.getAllExtractions(docId: MockSessionManager.doctorsNameDocumentID) { result in
            switch result {
            case .success(let extractions):
                receivedDoctorExtraction = extractions.first(where: { $0.name == ExtractionType.doctorName.rawValue })
            case .failure(_):
                receivedDoctorExtraction = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertNotNil(receivedDoctorExtraction, "Doctor name extraction should not be nil")
        XCTAssertEqual(receivedDoctorExtraction?.value, expectedDoctorName, "Doctor name extraction value should match expected name")
    }
}
