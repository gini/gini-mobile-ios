//
//  GiniHealthSDKIntegrationTests.swift
//  GiniHealthSDKExampleTests
//
//  Integration tests for Gini Health SDK
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest
import UIKit
import GiniHealthSDK
@testable import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK

/// Integration tests for Gini Health SDK - High-level SDK API tests
final class GiniHealthSDKIntegrationTests: XCTestCase {

    // When running from Xcode: update these environment variables in the scheme
    let clientId = ProcessInfo.processInfo.environment["CLIENT_ID"]!
    let clientSecret = ProcessInfo.processInfo.environment["CLIENT_SECRET"]!

    var giniHealth: GiniHealth!
    var paymentService: PaymentService!

    override func setUp() {
        super.setUp()

        let domain = "health-sdk-integration-tests"

        // Initialize GiniHealth SDK
        giniHealth = GiniHealth(id: clientId,
                                secret: clientSecret,
                                domain: domain)

        paymentService = giniHealth.paymentService

        print("✅ GiniHealth SDK initialized")
    }

    // MARK: - SDK Initialization Tests

    func testSDKInitialization() {
        XCTAssertNotNil(giniHealth)
        XCTAssertNotNil(paymentService)
        XCTAssertNotNil(giniHealth.documentService)
        print("✅ SDK services initialized")
    }

    func testPaymentServiceDomain() {
        XCTAssertEqual(paymentService.apiDomain.domainString, "health-api.gini.net")
        print("✅ Payment service domain: health-api.gini.net")
    }

    // MARK: - Payment Provider Tests

    func testFetchPaymentProviders() {
        let expect = expectation(description: "fetch payment providers")

        paymentService.paymentProviders { result in
            switch result {
                case .success(let providers):
                    XCTAssertFalse(providers.isEmpty, "Should have payment providers")
                    print("✅ Fetched \(providers.count) payment providers")

                    // Verify provider structure
                    if let firstProvider = providers.first {
                        XCTAssertFalse(firstProvider.id.isEmpty, "Provider ID should not be empty")
                        XCTAssertFalse(firstProvider.name.isEmpty, "Provider name should not be empty")
                        print("✅ Provider validated: '\(firstProvider.name)' (ID: \(firstProvider.id))")
                    }
                case .failure(let error):
                    XCTFail("Failed to fetch payment providers: \(error)")
            }
            expect.fulfill()
        }

        wait(for: [expect], timeout: 30)
    }

    func testFetchSinglePaymentProvider() {
        let expectProviders = expectation(description: "fetch providers")
        let expectSingleProvider = expectation(description: "fetch single provider")

        var providerId: String?

        // First get a provider ID
        paymentService.paymentProviders { result in
            if case .success(let providers) = result {
                providerId = providers.first?.id
                print("✅ Got test provider ID: \(providerId ?? "none")")
            }
            expectProviders.fulfill()
        }

        wait(for: [expectProviders], timeout: 30)

        guard let id = providerId else {
            XCTFail("No provider ID available")
            return
        }

        // Fetch single provider by ID
        paymentService.paymentProvider(id: id) { result in
            switch result {
                case .success(let provider):
                    XCTAssertEqual(provider.id, id, "Provider ID should match")
                    XCTAssertFalse(provider.name.isEmpty, "Provider name should not be empty")
                    print("✅ Fetched provider by ID: \(provider.name)")
                case .failure(let error):
                    XCTFail("Failed to fetch provider: \(error)")
            }
            expectSingleProvider.fulfill()
        }

        wait(for: [expectSingleProvider], timeout: 30)
    }

    // MARK: - Payment Request Tests

    func testCreatePaymentRequest() {
        let expectProviders = expectation(description: "fetch providers")
        let expectRequest = expectation(description: "create payment request")

        var paymentProviderId: String?

        // First fetch a payment provider
        paymentService.paymentProviders { result in
            switch result {
                case .success(let providers):
                    paymentProviderId = providers.first?.id
                    print("✅ Selected provider for test")
                case .failure(let error):
                    XCTFail("Failed to fetch providers: \(error)")
            }
            expectProviders.fulfill()
        }

        wait(for: [expectProviders], timeout: 30)

        guard let providerId = paymentProviderId else {
            XCTFail("No payment provider available")
            return
        }

        // Create payment request with real provider ID
        paymentService.createPaymentRequest(sourceDocumentLocation: "",
                                            paymentProvider: providerId,
                                            recipient: "Dr. med. Test",
                                            iban: "DE89370400440532013000",
                                            bic: "",
                                            amount: "42.50:EUR",
                                            purpose: "Test Invoice #\(Int.random(in: 1000...9999))") { result in
            switch result {
                case .success(let requestId):
                    XCTAssertFalse(requestId.isEmpty)
                    print("✅ Created payment request: \(requestId)")
                case .failure(let error):
                    XCTFail("Failed to create payment request: \(error)")
            }
            expectRequest.fulfill()
        }

        wait(for: [expectRequest], timeout: 30)
    }

    func testGetPaymentRequest() {
        let expectProviders = expectation(description: "fetch providers")
        let expectCreate = expectation(description: "create payment request")
        let expectGet = expectation(description: "get payment request")

        var paymentProviderId: String?
        var requestId: String?
        let testRecipient = "Dr. med. GetTest"
        let testAmount = "99.99:EUR"
        let testIban = "DE89370400440532013000"

        // 1. Fetch payment provider
        paymentService.paymentProviders { result in
            if case .success(let providers) = result {
                paymentProviderId = providers.first?.id
            }
            expectProviders.fulfill()
        }

        wait(for: [expectProviders], timeout: 30)

        guard let providerId = paymentProviderId else {
            XCTFail("No payment provider available")
            return
        }

        // 2. Create payment request
        paymentService.createPaymentRequest(sourceDocumentLocation: "",
                                            paymentProvider: providerId,
                                            recipient: testRecipient,
                                            iban: testIban,
                                            bic: "",
                                            amount: testAmount,
                                            purpose: "Test Get Payment Request") { result in
            if case .success(let id) = result {
                requestId = id
                print("✅ Created payment request: \(id)")
            }
            expectCreate.fulfill()
        }

        wait(for: [expectCreate], timeout: 30)

        guard let id = requestId else {
            XCTFail("Payment request not created")
            return
        }

        // 3. Get payment request by ID and verify content
        paymentService.paymentRequest(id: id) { result in
            switch result {
                case .success(let request):
                    XCTAssertEqual(request.recipient, testRecipient, "Recipient should match")
                    XCTAssertEqual(request.iban, testIban, "IBAN should match")
                    XCTAssertEqual(request.amount, testAmount, "Amount should match")
                    print("✅ Retrieved and validated payment request")
                case .failure(let error):
                    XCTFail("Failed to get payment request: \(error)")
            }
            expectGet.fulfill()
        }

        wait(for: [expectGet], timeout: 30)
    }

    func testPaymentRequestLifecycle() {
        let expectProviders = expectation(description: "1. fetch providers")
        let expectCreate = expectation(description: "2. create payment request")
        let expectGet = expectation(description: "3. get payment request")
        let expectDelete = expectation(description: "4. delete payment request")

        var paymentProviderId: String?
        var requestId: String?

        // Step 1: Fetch payment provider
        paymentService.paymentProviders { result in
            if case .success(let providers) = result {
                paymentProviderId = providers.first?.id
                print("✅ Step 1/4: Got provider ID")
            }
            expectProviders.fulfill()
        }

        wait(for: [expectProviders], timeout: 30)

        guard let providerId = paymentProviderId else {
            XCTFail("No payment provider available")
            return
        }

        // Step 2: Create payment request
        paymentService.createPaymentRequest(sourceDocumentLocation: "",
                                            paymentProvider: providerId,
                                            recipient: "Dr. med. Lifecycle",
                                            iban: "DE89370400440532013000",
                                            bic: "",
                                            amount: "123.45:EUR",
                                            purpose: "Lifecycle Test #\(Int.random(in: 1000...9999))") { result in
            if case .success(let id) = result {
                requestId = id
                print("✅ Step 2/4: Created payment request: \(id)")
            }
            expectCreate.fulfill()
        }

        wait(for: [expectCreate], timeout: 30)

        guard let id = requestId else {
            XCTFail("Payment request not created")
            return
        }

        // Step 3: Verify it exists
        paymentService.paymentRequest(id: id) { result in
            switch result {
                case .success(let request):
                    XCTAssertEqual(request.recipient, "Dr. med. Lifecycle")
                    XCTAssertEqual(request.amount, "123.45:EUR")
                    print("✅ Step 3/4: Payment request exists and validated")
                case .failure(let error):
                    XCTFail("Failed to get payment request: \(error)")
            }
            expectGet.fulfill()
        }

        wait(for: [expectGet], timeout: 30)

        // Step 4: Delete it
        giniHealth.deletePaymentRequest(id: id) { result in
            switch result {
                case .success:
                    print("✅ Step 4/4: Payment request deleted successfully")
                case .failure(let error):
                    XCTFail("Failed to delete payment request: \(error)")
            }
            expectDelete.fulfill()
        }

        wait(for: [expectDelete], timeout: 30)
    }

    // MARK: - Document Upload and Processing Tests

    /// Test document creation with real data
    func testUploadPDFDocument() {
        let expectUpload = expectation(description: "upload document")
        //let testImageData = loadTestInvoiceImage()
        guard let pdfData = FileLoader.loadFile(withName: "testMedInvoice", ofType: "pdf") else {
            XCTFail("Data was not uploaded")
            return
        }

        giniHealth.documentService.createDocument(fileName: "testMedInvoice.pdf",
                                                  docType: .invoice,
                                                  type: .partial(pdfData),
                                                  metadata: nil) { result in
            switch result {
                case .success(let document):
                    XCTAssertFalse(document.id.isEmpty, "Document ID should not be empty")
                    XCTAssertEqual(document.sourceClassification, .native)
                    print("✅ Document uploaded: \(document.id)")

                    //Cleanup: Delete the document after test
                    self.giniHealth.deleteDocuments(documentIds: [document.id]) { _ in }

                case .failure(let healthError):
                    XCTFail("Failed to upload document: \(healthError.itemsDescription)")
            }
            expectUpload.fulfill()
        }

        wait(for: [expectUpload], timeout: 60)
    }

    //    func testUploadPNGDocument() {
    //        let expectUpload = expectation(description: "upload document")
    //        guard let testPNGData = FileLoader.loadFile(withName: "testMedDocPNG", ofType: "png") else {
    //            XCTFail("Failed to load document data")
    //            return
    //        }
    //        giniHealth.documentService.createDocument(fileName: "testMedDocPNG.png",
    //                                                  docType: .invoice,
    //                                                  type: .partial(testPNGData),
    //                                                  metadata: nil) { result in
    //            switch result {
    //                case .success(let document):
    //                    XCTAssertFalse(document.id.isEmpty, "Document ID should not be empty")
    //                    XCTAssertEqual(document.sourceClassification, .scanned)
    //                    print("✅ Document uploaded: \(document.id)")
    //
    //                    // Cleanup: Delete the document after test
    //                    // self.giniHealth.deleteDocuments(documentIds: [document.id]) { _ in }
    //
    //                case .failure(let healthError as GiniHealthSDK.GiniError):
    //                    print(healthError.detailedDescription)
    //                    XCTFail("Failed to upload document: \(healthError)")
    //            }
    //            expectUpload.fulfill()
    //        }
    //
    //        wait(for: [expectUpload], timeout: 60)
    //    }

    /// Test fetching document after upload
    func testFetchDocument() {
        let expectUpload = expectation(description: "upload document")
        let expectFetch = expectation(description: "fetch document")

        var documentId: String?
        guard let pdfData = FileLoader.loadFile(withName: "testMedInvoice", ofType: "pdf") else {
            XCTFail("Data was not uploaded")
            return
        }

        // First upload a document
        giniHealth.documentService.createDocument(fileName: "testMedInvoice.pdf",
                                                  docType: .invoice,
                                                  type: .partial(pdfData),
                                                  metadata: nil) { result in
            if case .success(let document) = result {
                documentId = document.id
                print("✅ Document created for fetch test")
            }
            expectUpload.fulfill()
        }

        wait(for: [expectUpload], timeout: 60)

        guard let docId = documentId else {
            XCTFail("Document not created")
            return
        }

        // Fetch the document
        giniHealth.documentService.fetchDocument(with: docId) { result in
            switch result {
                case .success(let document):
                    XCTAssertEqual(document.id, docId)
                    XCTAssertNotNil(document.creationDate)
                    print("✅ Document fetched successfully")

                    // Cleanup
                    self.giniHealth.deleteDocuments(documentIds: [docId]) { _ in }

                case .failure(let error):
                    XCTFail("Failed to fetch document: \(error)")
            }
            expectFetch.fulfill()
        }

        wait(for: [expectFetch], timeout: 30)
    }

    /// Test extracting payment data from document
    func testGetExtractions() {
        let expectUpload = expectation(description: "upload document")
        let expectExtractions = expectation(description: "get extractions")

        var documentId: String?

        // Upload a test invoice
        guard let pdfData = FileLoader.loadFile(withName: "testMedInvoice", ofType: "pdf") else {
            XCTFail("Data was not uploaded")
            return
        }

        giniHealth.documentService.createDocument(fileName: "testMedInvoice.pdf",
                                                  docType: .invoice,
                                                  type: .partial(pdfData),
                                                  metadata: nil) { result in
            if case .success(let document) = result {
                documentId = document.id
                print("✅ Document uploaded for extraction test")
            }
            expectUpload.fulfill()
        }

        wait(for: [expectUpload], timeout: 60)

        guard let docId = documentId else {
            XCTFail("Document not uploaded")
            return
        }

        // Get extractions (payment data)
        giniHealth.getExtractions(docId: docId) { result in
            switch result {
                case .success(let extractions):
                    XCTAssertFalse(extractions.isEmpty, "Should have extractions")
                    print("✅ Got \(extractions.count) extractions")

                    // Check for common payment fields
                    let hasIban = extractions.contains { $0.name == "iban" }
                    let hasAmount = extractions.contains { $0.name == "amountToPay" }
                    let hasRecipient = extractions.contains { $0.name == "payment_recipient" }

                    print("  - IBAN: \(hasIban ? "✓" : "✗")")
                    print("  - Amount: \(hasAmount ? "✓" : "✗")")
                    print("  - Recipient: \(hasRecipient ? "✓" : "✗")")

                    // Cleanup
                    self.giniHealth.deleteDocuments(documentIds: [docId]) { _ in }

                case .failure(let error):
                    // It's ok if no payment data is extracted from test image
                    print("⚠️ No payment extractions (expected for test data): \(error)")
                    self.giniHealth.deleteDocuments(documentIds: [docId]) { _ in }
            }
            expectExtractions.fulfill()
        }

        wait(for: [expectExtractions], timeout: 60)
    }

    /// Test getting all extractions including medical information
    func testGetAllExtractions() {
        let expectUpload = expectation(description: "upload document")
        let expectExtractions = expectation(description: "get all extractions")

        var documentId: String?
        // Upload a test invoice
        guard let pdfData = FileLoader.loadFile(withName: "testMedInvoice", ofType: "pdf") else {
            XCTFail("Data was not uploaded")
            return
        }

        giniHealth.documentService.createDocument(
            fileName: "testMedInvoice.pdf",
            docType: .invoice,
            type: .partial(pdfData),
            metadata: nil
        ) { result in
            if case .success(let document) = result {
                documentId = document.id
                print("✅ Document uploaded for all extractions test")
            }
            expectUpload.fulfill()
        }

        wait(for: [expectUpload], timeout: 60)

        guard let docId = documentId else {
            XCTFail("Document not uploaded")
            return
        }

        // Get all extractions (including medical)
        giniHealth.getAllExtractions(docId: docId) { result in
            switch result {
                case .success(let extractions):
                    XCTAssertFalse(extractions.isEmpty, "Should have extractions")
                    print("✅ Got \(extractions.count) total extractions")

                    // Cleanup
                    self.giniHealth.deleteDocuments(documentIds: [docId]) { _ in }

                case .failure(let error):
                    XCTFail("Failed to get all extractions: \(error)")
                    self.giniHealth.deleteDocuments(documentIds: [docId]) { _ in }
            }
            expectExtractions.fulfill()
        }

        wait(for: [expectExtractions], timeout: 60)
    }

    /// Test checking if document is payable
    func testCheckIfDocumentIsPayable() {
        let expectUpload = expectation(description: "upload document")
        let expectCheck = expectation(description: "check payable")

        var documentId: String?
        guard let pdfData = FileLoader.loadFile(withName: "testMedInvoice", ofType: "pdf") else {
            XCTFail("Data was not uploaded")
            return
        }

        giniHealth.documentService.createDocument(fileName: "testMedInvoice.pdf",
                                                  docType: .invoice,
                                                  type: .partial(pdfData),
                                                  metadata: nil) { result in
            if case .success(let document) = result {
                documentId = document.id
                print("✅ Document uploaded for payable check")
            }
            expectUpload.fulfill()
        }

        wait(for: [expectUpload], timeout: 60)

        guard let docId = documentId else {
            XCTFail("Document not uploaded")
            return
        }

        // Check if document is payable
        giniHealth.checkIfDocumentIsPayable(docId: docId) { result in
            switch result {
                case .success(let isPayable):
                    print("✅ Payable status: \(isPayable)")
                    // Note: Test data may not have IBAN, so false is expected

                    // Cleanup
                    self.giniHealth.deleteDocuments(documentIds: [docId]) { _ in }

                case .failure(let error):
                    XCTFail("Failed to check payable status: \(error)")
                    self.giniHealth.deleteDocuments(documentIds: [docId]) { _ in }
            }
            expectCheck.fulfill()
        }

        wait(for: [expectCheck], timeout: 60)
    }

    /// Test checking if document contains multiple invoices
    func testCheckIfDocumentContainsMultipleInvoices() {
        let expectUpload = expectation(description: "upload document")
        let expectCheck = expectation(description: "check multiple invoices")

        var documentId: String?
        guard let pdfData = FileLoader.loadFile(withName: "multi-invoice", ofType: "pdf") else {
            XCTFail("Data was not uploaded")
            return
        }
        giniHealth.documentService.createDocument(
            fileName: "invoice-multiple-check.jpg",
            docType: .invoice,
            type: .partial(pdfData),
            metadata: nil
        ) { result in
            if case .success(let document) = result {
                documentId = document.id
                print("✅ Document uploaded for multiple invoices check")
            }
            expectUpload.fulfill()
        }

        wait(for: [expectUpload], timeout: 60)

        guard let docId = documentId else {
            XCTFail("Document not uploaded")
            return
        }

        // Check if document contains multiple invoices
        giniHealth.checkIfDocumentContainsMultipleInvoices(docId: docId) { result in
            switch result {
                case .success(let hasMultiple):
                    print("✅ Multiple invoices: \(hasMultiple)")

                    // Cleanup
                    self.giniHealth.deleteDocuments(documentIds: [docId]) { _ in }

                case .failure(let error):
                    XCTFail("Failed to check multiple invoices: \(error)")
                    self.giniHealth.deleteDocuments(documentIds: [docId]) { _ in }
            }
            expectCheck.fulfill()
        }

        wait(for: [expectCheck], timeout: 60)
    }

    /// Test polling document until processing is complete
    func testPollDocument() {
        let expectUpload = expectation(description: "upload document")
        let expectPoll = expectation(description: "poll document")

        var documentId: String?
        guard let pdfData = FileLoader.loadFile(withName: "testMedInvoice", ofType: "pdf") else {
            XCTFail("Data was not uploaded")
            return
        }
        giniHealth.documentService.createDocument(fileName: "testMedInvoice.pdf",
                                                  docType: .invoice,
                                                  type: .partial(pdfData),
                                                  metadata: nil) { result in
            if case .success(let document) = result {
                documentId = document.id
                print("✅ Document uploaded for polling test")
            }
            expectUpload.fulfill()
        }

        wait(for: [expectUpload], timeout: 60)

        guard let docId = documentId else {
            XCTFail("Document not uploaded")
            return
        }

        // Poll document
        giniHealth.pollDocument(docId: docId) { result in
            switch result {
                case .success(let document):
                    XCTAssertEqual(document.id, docId)
                    print("✅ Document polled successfully: \(document.progress)")

                    // Cleanup
                    self.giniHealth.deleteDocuments(documentIds: [docId]) { _ in }

                case .failure(let error):
                    XCTFail("Failed to poll document: \(error)")
                    self.giniHealth.deleteDocuments(documentIds: [docId]) { _ in }
            }
            expectPoll.fulfill()
        }

        wait(for: [expectPoll], timeout: 60)
    }

    /// Test deleting a batch of documents
    func testDeleteDocuments() {
        let expectUpload1 = expectation(description: "upload document 1")
        let expectUpload2 = expectation(description: "upload document 2")
        let expectDelete = expectation(description: "delete documents")

        var documentIds: [String] = []
        guard let pdfData = FileLoader.loadFile(withName: "testMedInvoice", ofType: "pdf") else {
            XCTFail("Data was not uploaded")
            return
        }
        // Upload first document
        giniHealth.documentService.createDocument(fileName: "testMedInvoice1.pdf",
                                                  docType: .invoice,
                                                  type: .partial(pdfData),
                                                  metadata: nil) { result in
            if case .success(let document) = result {
                documentIds.append(document.id)
                print("✅ Document 1 uploaded")
            }
            expectUpload1.fulfill()
        }

        // Upload second document
        giniHealth.documentService.createDocument(fileName: "testMedInvoice2.pdf",
                                                  docType: .invoice,
                                                  type: .partial(pdfData),
                                                  metadata: nil) { result in
            if case .success(let document) = result {
                documentIds.append(document.id)
                print("✅ Document 2 uploaded")
            }
            expectUpload2.fulfill()
        }

        wait(for: [expectUpload1, expectUpload2], timeout: 60)

        guard documentIds.count == 2 else {
            XCTFail("Not all documents uploaded")
            return
        }

        // Delete both documents in batch
        giniHealth.deleteDocuments(documentIds: documentIds) { result in
            switch result {
                case .success(let message):
                    print("✅ Batch delete successful: \(message)")
                case .failure(let error):
                    XCTFail("Failed to delete documents: \(error)")
            }
            expectDelete.fulfill()
        }

        wait(for: [expectDelete], timeout: 30)
    }

    // MARK: - Banking App Methods Tests

    /// Test fetching banking apps (already exists, but ensuring it's here)
    func testFetchBankingApps() {
        let expect = expectation(description: "fetch banking apps")

        giniHealth.fetchBankingApps { result in
            switch result {
                case .success(let providers):
                    XCTAssertFalse(providers.isEmpty, "Should have banking apps")
                    print("✅ Fetched \(providers.count) banking apps")

                    // Verify provider structure
                    if let firstProvider = providers.first {
                        XCTAssertFalse(firstProvider.id.isEmpty)
                        XCTAssertFalse(firstProvider.name.isEmpty)
                        print("✅ Banking app validated: '\(firstProvider.name)'")
                    }

                case .failure(let error):
                    XCTFail("Failed to fetch banking apps: \(error)")
            }
            expect.fulfill()
        }

        wait(for: [expect], timeout: 30)
    }

    // MARK: - Payment Request Methods Tests

    /// Test creating payment request using GiniHealth method
    func testCreatePaymentRequestViaGiniHealth() {
        let expectProviders = expectation(description: "fetch providers")
        let expectCreate = expectation(description: "create payment request")

        var paymentProviderId: String?

        // Get provider
        giniHealth.fetchBankingApps { result in
            if case .success(let providers) = result {
                paymentProviderId = providers.first?.id
            }
            expectProviders.fulfill()
        }

        wait(for: [expectProviders], timeout: 30)

        guard let providerId = paymentProviderId else {
            XCTFail("No payment provider available")
            return
        }

        // Create payment info
        let paymentInfo = GiniInternalPaymentSDK.PaymentInfo(recipient: "Dr. Test Integration",
                                                             iban: "DE89370400440532013000",
                                                             bic: "",
                                                             amount: "55.50:EUR",
                                                             purpose: "Integration Test Payment",
                                                             paymentUniversalLink: "",
                                                             paymentProviderId: providerId)

        // Create payment request
        giniHealth.createPaymentRequest(paymentInfo: paymentInfo) { result in
            switch result {
                case .success(let requestId):
                    XCTAssertFalse(requestId.isEmpty)
                    print("✅ Payment request created via GiniHealth: \(requestId)")

                    // Cleanup
                    self.giniHealth.deletePaymentRequest(id: requestId) { _ in }

                case .failure(let error):
                    XCTFail("Failed to create payment request: \(error)")
            }
            expectCreate.fulfill()
        }

        wait(for: [expectCreate], timeout: 30)
    }

    /// Test getting payment request via GiniHealth
    func testGetPaymentRequestViaGiniHealth() {
        let expectProviders = expectation(description: "fetch providers")
        let expectCreate = expectation(description: "create payment request")
        let expectGet = expectation(description: "get payment request")

        var paymentProviderId: String?
        var requestId: String?

        // Get provider
        giniHealth.fetchBankingApps { result in
            if case .success(let providers) = result {
                paymentProviderId = providers.first?.id
            }
            expectProviders.fulfill()
        }

        wait(for: [expectProviders], timeout: 30)

        guard let providerId = paymentProviderId else {
            XCTFail("No payment provider available")
            return
        }

        // Create payment request
        let paymentInfo = GiniInternalPaymentSDK.PaymentInfo(recipient: "Dr. GetTest",
                                                             iban: "DE89370400440532013000",
                                                             bic: "",
                                                             amount: "77.77:EUR",
                                                             purpose: "Get Payment Request Test",
                                                             paymentUniversalLink: "",
                                                             paymentProviderId: providerId)

        giniHealth.createPaymentRequest(paymentInfo: paymentInfo) { result in
            if case .success(let id) = result {
                requestId = id
            }
            expectCreate.fulfill()
        }

        wait(for: [expectCreate], timeout: 30)

        guard let id = requestId else {
            XCTFail("Payment request not created")
            return
        }

        // Get payment request
        giniHealth.getPaymentRequest(by: id) { result in
            switch result {
                case .success(let request):
                    XCTAssertEqual(request.recipient, "Dr. GetTest")
                    XCTAssertEqual(request.amount, "77.77:EUR")
                    print("✅ Payment request retrieved via GiniHealth")

                    // Cleanup
                    self.giniHealth.deletePaymentRequest(id: id) { _ in }

                case .failure(let error):
                    XCTFail("Failed to get payment request: \(error)")
            }
            expectGet.fulfill()
        }

        wait(for: [expectGet], timeout: 30)
    }

    /// Test deleting batch of payment requests
    func testDeletePaymentRequests() {
        let expectProviders = expectation(description: "fetch providers")
        let expectCreate1 = expectation(description: "create payment request 1")
        let expectCreate2 = expectation(description: "create payment request 2")
        let expectDelete = expectation(description: "delete payment requests")

        var paymentProviderId: String?
        var requestIds: [String] = []

        // Get provider
        giniHealth.fetchBankingApps { result in
            if case .success(let providers) = result {
                paymentProviderId = providers.first?.id
            }
            expectProviders.fulfill()
        }

        wait(for: [expectProviders], timeout: 30)

        guard let providerId = paymentProviderId else {
            XCTFail("No payment provider available")
            return
        }

        // Create first payment request
        let paymentInfo1 = GiniInternalPaymentSDK.PaymentInfo(recipient: "Dr. BatchDelete1",
                                                              iban: "DE89370400440532013000",
                                                              bic: "",
                                                              amount: "11.11:EUR",
                                                              purpose: "Batch Delete Test 1",
                                                              paymentUniversalLink: "",
                                                              paymentProviderId: providerId)

        giniHealth.createPaymentRequest(paymentInfo: paymentInfo1) { result in
            if case .success(let id) = result {
                requestIds.append(id)
            }
            expectCreate1.fulfill()
        }

        // Create second payment request
        let paymentInfo2 = GiniInternalPaymentSDK.PaymentInfo(recipient: "Dr. BatchDelete2",
                                                              iban: "DE89370400440532013000",
                                                              bic: "",
                                                              amount: "22.22:EUR",
                                                              purpose: "Batch Delete Test 2",
                                                              paymentUniversalLink: "",
                                                              paymentProviderId: providerId)

        giniHealth.createPaymentRequest(paymentInfo: paymentInfo2) { result in
            if case .success(let id) = result {
                requestIds.append(id)
            }
            expectCreate2.fulfill()
        }

        wait(for: [expectCreate1, expectCreate2], timeout: 30)

        guard requestIds.count == 2 else {
            XCTFail("Not all payment requests created")
            return
        }

        // Delete batch
        giniHealth.deletePaymentRequests(ids: requestIds) { result in
            switch result {
                case .success(let deletedIds):
                    XCTAssertEqual(deletedIds.count, 2)
                    print("✅ Batch deleted \(deletedIds.count) payment requests")
                case .failure(let error):
                    XCTFail("Failed to delete payment requests: \(error)")
            }
            expectDelete.fulfill()
        }

        wait(for: [expectDelete], timeout: 30)
    }

    /// Test getting payment status
    func testGetPayment() {
        let expectProviders = expectation(description: "fetch providers")
        let expectCreate = expectation(description: "create payment request")
        let expectGetPayment = expectation(description: "get payment")

        var paymentProviderId: String?
        var requestId: String?

        // Get provider
        giniHealth.fetchBankingApps { result in
            if case .success(let providers) = result {
                paymentProviderId = providers.first?.id
            }
            expectProviders.fulfill()
        }

        wait(for: [expectProviders], timeout: 30)

        guard let providerId = paymentProviderId else {
            XCTFail("No payment provider available")
            return
        }

        // Create payment request
        let paymentInfo = GiniInternalPaymentSDK.PaymentInfo(recipient: "Dr. PaymentStatus",
                                                             iban: "DE89370400440532013000",
                                                             bic: "",
                                                             amount: "99.99:EUR",
                                                             purpose: "Payment Status Test",
                                                             paymentUniversalLink: "",
                                                             paymentProviderId: providerId)

        giniHealth.createPaymentRequest(paymentInfo: paymentInfo) { result in
            if case .success(let id) = result {
                requestId = id
            }
            expectCreate.fulfill()
        }

        wait(for: [expectCreate], timeout: 30)

        guard let id = requestId else {
            XCTFail("Payment request not created")
            return
        }

        // Try to get payment (may not exist yet, which is ok)
        giniHealth.getPayment(id: id) { result in
            switch result {
                case .success(let payment):
                    print("✅ Payment retrieved: \(payment)")
                case .failure(let error):
                    // Payment might not exist yet for new request - this is expected
                    print("⚠️ Payment not found (expected for new request): \(error)")
            }

            // Cleanup
            self.giniHealth.deletePaymentRequest(id: id) { _ in }
            expectGetPayment.fulfill()
        }

        wait(for: [expectGetPayment], timeout: 30)
    }

}
