import XCTest
@testable import GiniHealthSDK
@testable import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK
@testable import GiniUtilites

final class GiniHealthExtractionsHandlingTests: XCTestCase {

    var giniHealthAPI: GiniHealthAPI!
    var giniHealth: GiniHealth!
    private let versionAPI = 4

    override func setUp() {
        let sessionManagerMock = MockSessionManager()
        let documentService = DefaultDocumentService(sessionManager: sessionManagerMock, apiVersion: versionAPI)
        let paymentService = PaymentService(sessionManager: sessionManagerMock, apiVersion: versionAPI)
        let clientConfigurationService = ClientConfigurationService(sessionManager: sessionManagerMock, apiVersion: versionAPI)
        GiniHealthConfiguration.shared.clientConfiguration = nil
        giniHealthAPI = GiniHealthAPI(documentService: documentService,
                                      paymentService: paymentService,
                                      clientConfigurationService: clientConfigurationService)
        giniHealth = GiniHealth(giniApiLib: giniHealthAPI)
    }

    override func tearDown() {
        giniHealthAPI = nil
        giniHealth = nil
        super.tearDown()
    }

    func testDocumentIsPayable() {
        // When
        let fileName = "extractionResultWithIBAN"
        let extractions: GiniHealthSDK.ExtractionsContainer? = GiniHealthSDKTests.load(fromFile: fileName)
        guard let extractions else {
            XCTFail("Error loading file: `\(fileName).json`")
            return
        }
        let extractionsResult = ExtractionResult(extractionsContainer: extractions)
        let isPayable = extractionsResult.extractions.first(where: { $0.name == ExtractionType.paymentState.rawValue })?.value == GiniHealthSDK.PaymentState.payable.rawValue
        // Then
        XCTAssertEqual(isPayable, true)
    }
    
    func testDocumentIsNotPayableSuccess() {
        // When
        let fileName = "extractionResultWithoutIBAN"
        let extractions: GiniHealthSDK.ExtractionsContainer? = GiniHealthSDKTests.load(fromFile: fileName)
        guard let extractions else {
            XCTFail("Error loading file: `\(fileName).json`")
            return
        }
        let extractionsResult = ExtractionResult(extractionsContainer: extractions)
        let isPayable = extractionsResult.extractions.first(where: { $0.name == ExtractionType.paymentState.rawValue })?.value == GiniHealthSDK.PaymentState.payable.rawValue
        // Then
        XCTAssertEqual(isPayable, false)
    }

    func testCheckIfDocumentIsPayableSuccess() {
        // Given
        let fileName = "extractionResultWithIBAN"
        let expectedExtractions: GiniHealthSDK.ExtractionsContainer? = GiniHealthSDKTests.load(fromFile: fileName)
        guard let expectedExtractions else {
            XCTFail("Error loading file: `\(fileName).json`")
            return
        }
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
        XCTAssertEqual(expectedIsPayable, isDocumentPayable)
    }

    func testCheckIfDocumentIsNotPayableSuccess() {
        // Given
        let fileName = "extractionResultWithIBAN"
        let expectedExtractions: GiniHealthSDK.ExtractionsContainer? = GiniHealthSDKTests.load(fromFile: fileName)
        guard let expectedExtractions else {
            XCTFail("Error loading file: `\(fileName).json`")
            return
        }
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
        XCTAssertEqual(expectedIsPayable, isDocumentPayable)
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
        XCTAssertNil(isDocumentPayable)
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
        XCTAssertEqual(true, hasMultipleInvoices)
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
        XCTAssertEqual(false, hasMultipleInvoices)
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
        XCTAssertNil(hasMultipleInvoices)
    }
    
    func testGetExtractionsSuccess() {
        // Given
        let fileName = "extractionsWithPayment"
        let expectedExtractionContainer: GiniHealthSDK.ExtractionsContainer? = GiniHealthSDKTests.load(fromFile: fileName)
        guard let expectedExtractionContainer else {
            XCTFail("Error loading file: `\(fileName).json`")
            return
        }
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
        XCTAssertNotNil(receivedExtractions)
        XCTAssertEqual(receivedExtractions?.count, expectedExtractions.count)
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
        XCTAssertNil(receivedExtractions)
    }

    func testGetAllExtractionsSuccess() {
        // Given
        let fileName = "test_doctorsname"
        let expectedExtractionContainer: GiniHealthSDK.ExtractionsContainer? = GiniHealthSDKTests.load(fromFile: fileName)
        guard let expectedExtractionContainer else {
            XCTFail("Error loading file: `\(fileName).json`")
            return
        }
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
        XCTAssertNotNil(receivedExtractions)
        XCTAssertEqual(receivedExtractions?.count, expectedExtractions.count)
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
        XCTAssertNil(receivedExtractions)
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
        XCTAssertNotNil(receivedDoctorExtraction)
        XCTAssertEqual(receivedDoctorExtraction?.value, expectedDoctorName)
    }
}
