import XCTest
@testable import GiniHealthSDK
@testable import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK
@testable import GiniUtilites

final class GiniHealthTests: XCTestCase {
    
    var giniHealthAPI: GiniHealthAPI!
    var giniHealth: GiniHealth!
    private let versionAPI = 4

    override func setUp() {
        let sessionManagerMock = MockSessionManager()
        let documentService = DefaultDocumentService(sessionManager: sessionManagerMock, apiVersion: versionAPI)
        let paymentService = PaymentService(sessionManager: sessionManagerMock, apiVersion: versionAPI)
        giniHealthAPI = GiniHealthAPI(documentService: documentService, paymentService: paymentService)
        giniHealth = GiniHealth(giniApiLib: giniHealthAPI)
    }

    override func tearDown() {
        giniHealth = nil
        super.tearDown()
    }
    
    func testSetConfiguration() throws {
        // Given
        let configuration = GiniHealthConfiguration()
        
        // When
        giniHealth.setConfiguration(configuration)
        
        // Then
        XCTAssertEqual(GiniHealthConfiguration.shared, configuration)
    }
    
    func testFetchBankingApps_Success() {
        // Given
        let expectedProviders: [GiniHealthSDK.PaymentProvider]? = loadProviders(fileName: "providers")

        // When
        let expectation = self.expectation(description: "Fetching banking apps")
        var receivedProviders: [GiniHealthSDK.PaymentProvider]?
        giniHealth.fetchBankingApps { result in
            switch result {
            case .success(let providers):
                receivedProviders = providers
            case .failure(_):
                receivedProviders = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
        
        // Then
        XCTAssertNotNil(receivedProviders)
        XCTAssertEqual(receivedProviders?.count, expectedProviders?.count)
        XCTAssertEqual(receivedProviders, expectedProviders)
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
    
    func testDocumentIsNotPayable_Success() {
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

    func testCheckIfDocumentIsPayable_Success() {
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

    func testCheckIfDocumentIsNotPayable_Success() {
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

    func testCheckIfDocumentIsPayable_Failure() {
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

    func testCheckIfDocumentContainMultipleInvoices_Success() {
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

    func testCheckIfDocumentDontContainMultipleInvoices_Success() {
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

    func testCheckIfDocumentContainMultipleInvoices_Failure() {
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

    func testPollDocument_Success() {
        // Given
        let healthDocument: GiniHealthAPILibrary.Document = GiniHealthSDKTests.load(fromFile: "document1")!
        let expectedDocument: GiniHealthSDK.Document? = GiniHealthSDK.Document(healthDocument: healthDocument)

        // When
        let expectation = self.expectation(description: "Polling document")
        var receivedDocument: GiniHealthSDK.Document?
        giniHealth.pollDocument(docId: MockSessionManager.payableDocumentID) { result in
            switch result {
            case .success(let document):
                receivedDocument = document
            case .failure(_):
                receivedDocument = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertNotNil(receivedDocument)
        XCTAssertEqual(receivedDocument, expectedDocument)
    }
    
    func testPollDocument_Failure() {
        // When
        let expectation = self.expectation(description: "Polling failure document")
        var receivedDocument: GiniHealthSDK.Document?
        giniHealth.pollDocument(docId: MockSessionManager.missingDocumentID) { result in
            switch result {
            case .success(let document):
                receivedDocument = document
            case .failure(_):
                receivedDocument = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertNil(receivedDocument)
    }
    
    func testGetExtractions_Success() {
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
    
    func testGetExtractions_Failure() {
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
    
    func testCreatePaymentRequest_Success() {
        // Given
        let expectedPaymentRequestID = MockSessionManager.paymentRequestId

        // When
        let expectation = self.expectation(description: "Creating payment request")
        var receivedRequestId: String?
        let paymentInfo = PaymentInfo(recipient: "Uno Flüchtlingshilfe", iban: "DE78370501980020008850", bic: "COLSDE33", amount: "1.00:EUR", purpose: "ReNr 12345", paymentUniversalLink: "ginipay-test://paymentRequester", paymentProviderId: "b09ef70a-490f-11eb-952e-9bc6f4646c57")
        giniHealth.createPaymentRequest(paymentInfo: paymentInfo, completion: { result in
            switch result {
            case .success(let requestId):
                receivedRequestId = requestId
            case .failure(_):
                receivedRequestId = nil
            }
            expectation.fulfill()
        })
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertNotNil(receivedRequestId)
        XCTAssertEqual(receivedRequestId, expectedPaymentRequestID)
    }
    
    func testOpenLink_Success() {
        let mockUIApplication = MockUIApplication(canOpen: true)
        let urlOpener = URLOpener(mockUIApplication)
        let waitForWebsiteOpen = expectation(description: "Link was opened")

        giniHealth.openPaymentProviderApp(requestID: "123", universalLink: "ginipay-bank://", urlOpener: urlOpener, completion: { open in
            waitForWebsiteOpen.fulfill()
            XCTAssert(open == true, "testOpenLink - FAILED to open link")
        })

        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testOpenLink_Failure() {
        let mockUIApplication = MockUIApplication(canOpen: false)
        let urlOpener = URLOpener(mockUIApplication)
        let waitForWebsiteOpen = expectation(description: "Link was not opened")

        giniHealth.openPaymentProviderApp(requestID: "123", universalLink: "ginipay-bank://", urlOpener: urlOpener, completion: { open in
            waitForWebsiteOpen.fulfill()
            XCTAssert(open == false, "testOpenLink - MANAGED to open link")
        })

        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testSetDocumentForReview_Success() {
        // Given
        let fileName = "extractionsWithPayment"
        let expectedExtractionContainer: GiniHealthSDK.ExtractionsContainer? = GiniHealthSDKTests.load(fromFile: fileName)
        guard let expectedExtractionContainer else {
            XCTFail("Error loading file: `\(fileName).json`")
            return
        }
        let expectedExtractions: [GiniHealthSDK.Extraction] = ExtractionResult(extractionsContainer: expectedExtractionContainer).payment?.first ?? []

        // When
        let expectation = self.expectation(description: "Setting document for review")
        var receivedExtractions: [GiniHealthSDK.Extraction]?
        giniHealth.setDocumentForReview(documentId: MockSessionManager.extractionsWithPaymentDocumentID) { result in
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
    
    func testFetchDataForReview_Success() {
        // Given
        let fileName = "extractionsWithPayment"
        let expectedExtractionContainer: GiniHealthSDK.ExtractionsContainer? = GiniHealthSDKTests.load(fromFile: fileName)
        guard let expectedExtractionContainer else {
            XCTFail("Error loading file: `\(fileName).json`")
            return
        }
        let expectedExtractions: [GiniHealthSDK.Extraction] = ExtractionResult(extractionsContainer: expectedExtractionContainer).payment?.first ?? []
        let documentFileName = "document4"

        let healthDocument: GiniHealthAPILibrary.Document = GiniHealthSDKTests.load(fromFile: documentFileName)!
        let expectedDocument: GiniHealthSDK.Document? = GiniHealthSDK.Document(healthDocument: healthDocument)

        guard let expectedDocument else {
            XCTFail("Error loading file: `\(documentFileName).json`")
            return
        }
        let expectedDatForReview = DataForReview(document: expectedDocument, extractions: expectedExtractions)

        // When
        let expectation = self.expectation(description: "Fetching data for review")
        var receivedDataForReview: DataForReview?
        giniHealth.fetchDataForReview(documentId: MockSessionManager.extractionsWithPaymentDocumentID) { result in
            switch result {
            case .success(let dataForReview):
                receivedDataForReview = dataForReview
            case .failure(_):
                receivedDataForReview = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertNotNil(receivedDataForReview)
        XCTAssertEqual(receivedDataForReview?.document, expectedDatForReview.document)
        XCTAssertEqual(receivedDataForReview?.extractions.count, expectedDatForReview.extractions.count)
    }
    
    func testFetchDataForReview_Failure() {
        // When
        let expectation = self.expectation(description: "Failure fetching data for review")
        var receivedError: GiniHealthError?
        giniHealth.fetchDataForReview(documentId: MockSessionManager.missingDocumentID) { result in
            switch result {
            case .success(_):
                receivedError = nil
            case .failure(let error):
                receivedError = error
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertNotNil(receivedError)
    }

    func testGetAllExtractions_Success() {
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

    func testGetAlllExtractions_Failure() {
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

    func testGetDoctorsNameExtractions_Success() {
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
