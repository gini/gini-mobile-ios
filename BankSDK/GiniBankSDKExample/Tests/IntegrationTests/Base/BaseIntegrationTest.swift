//
//  BaseIntegrationTest.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankAPILibrary
@testable import GiniCaptureSDK
@testable import GiniBankSDK

class BaseIntegrationTest: XCTestCase {
    lazy var giniHelper = GiniSetupHelper()
    var analysisExtractionResult: ExtractionResult?

    override func setUp() {
        giniHelper.setup()
    }
    /**
     * This method reproduces the document upload and analysis done by the Bank SDK.
     *
     * The intent of this method is to create extractions like the one your app
     * receives after a user analysed a document with the Bank SDK.
     *
     * In your production code you should not call `DocumentService` methods.
     * Interaction with the network service is handled by the Bank SDK internally.
     */
    func uploadAndAnalyzeDocument(fileName: String,
                                  delegate: GiniCaptureResultsDelegate,
                                  documentType: String = "pdf",
                                  sendTransferSummaryIfNeeded: Bool = false) {
        guard let testDocumentData = FileLoader.loadFile(withName: fileName,
                                                         ofType: documentType) else {
            XCTFail("Error loading file: `\(fileName).\(documentType)`")
            return
        }

        let builder = GiniCaptureDocumentBuilder(documentSource: .appName(name: "GiniBankSDKExample"))
        guard let captureDocument = builder.build(with: testDocumentData, 
                                                  fileName: "\(fileName).\(documentType)") else {
            XCTFail("Failed to build capture document with file: \(fileName).\(documentType)")
            return
        }

        GiniBankConfiguration.shared.documentService = giniHelper.giniCaptureSDKDocumentService

        // Upload and analyze the document
        giniHelper.giniCaptureSDKDocumentService.upload(document: captureDocument) { result in
            switch result {
                case .success(_):
                    self.handleUploadSuccess(captureDocument: captureDocument,
                                             delegate: delegate,
                                             sendTransferSummaryIfNeeded: sendTransferSummaryIfNeeded)
                case let .failure(error):
                    XCTFail(String(describing: error))
            }
        }
    }

    /**
     Handles the success of the document upload and starts the document analysis.

     - Parameters:
     - captureDocument: The uploaded document that will be analyzed.
     - delegate: The delegate to handle analysis results.
     - sendTransferSummaryIfNeeded: A Boolean flag indicating whether to send a transfer summary after analysis.
     */
    func handleUploadSuccess(captureDocument: GiniCaptureDocument,
                             delegate: GiniCaptureResultsDelegate,
                             sendTransferSummaryIfNeeded: Bool) {
        giniHelper.giniCaptureSDKDocumentService?.startAnalysis { result in
            switch result {
                case let .success(extractionResult):
                    self.handleAnalysisSuccess(extractionResult: extractionResult,
                                               delegate: delegate,
                                               sendTransferSummaryIfNeeded: sendTransferSummaryIfNeeded)
                case let .failure(error):
                    XCTFail(String(describing: error))
            }
        }
    }
    
    /**
     Handles the analysis success and processes the extracted data.

     - Parameters:
     - extractionResult: The result of the successful document analysis.
     - delegate: The delegate to handle analysis results.
     - sendTransferSummaryIfNeeded: A Boolean flag indicating whether to send a transfer summary after analysis.
     */
    func handleAnalysisSuccess(extractionResult: ExtractionResult,
                               delegate: GiniCaptureResultsDelegate,
                               sendTransferSummaryIfNeeded: Bool) {
        let extractions: [String: Extraction] = Dictionary(uniqueKeysWithValues: extractionResult.extractions.compactMap {
            guard let name = $0.name else { return nil }
            return (name, $0)
        })

        let analysisResult = AnalysisResult(extractions: extractions,
                                            lineItems: extractionResult.lineItems,
                                            images: [],
                                            document: self.giniHelper.giniCaptureSDKDocumentService?.document,
                                            candidates: [:])

        self.analysisExtractionResult = extractionResult
        delegate.giniCaptureAnalysisDidFinishWith(result: analysisResult)
        GiniBankConfiguration.shared.lineItems = extractionResult.lineItems

        if sendTransferSummaryIfNeeded {
            // Send transfer summary for the extractions the user confirmed
            GiniBankConfiguration.shared.sendTransferSummary(
                paymentRecipient: extractions["paymentRecipient"]?.value ?? "",
                paymentReference: extractions["paymentReference"]?.value ?? "",
                paymentPurpose: extractions["paymentPurpose"]?.value ?? "",
                iban: extractions["iban"]?.value ?? "",
                bic: extractions["bic"]?.value ?? "",
                amountToPay: ExtractionAmount(value: 950.00, currency: .EUR)
            )
        }
    }

    /**
     Loads and decodes a JSON fixture file into an `ExtractionsContainer` object.

     - Parameter fileName: The name of the file to load.

     - Returns: The decoded `ExtractionsContainer` object if the file was loaded and decoded successfully, or `nil` if an error occurred.
     */
    func loadFixtureExtractionsContainer(from fileName: String) -> ExtractionsContainer? {
        guard let fixtureExtractionsJson = FileLoader.loadFile(withName: fileName, ofType: "json") else {
            XCTFail("Error loading file: `\(fileName).json`")
            return nil
        }

        do {
            let fixtureExtractionsContainer = try JSONDecoder().decode(ExtractionsContainer.self, from: fixtureExtractionsJson)
            return fixtureExtractionsContainer
        } catch {
            XCTFail("Failed to decode ExtractionsContainer from file: `\(fileName).json`. Error: \(error)")
            return nil
        }
    }

    // Helper method for verifying extractions (with the decoded fixture container as input)
    func verifyExtractions(result: AnalysisResult, fixtureContainer: ExtractionsContainer) {
        XCTAssertEqual(fixtureContainer.extractions.first(where: { $0.name == "iban" })?.value,
                       result.extractions["iban"]?.value)

        verifyPaymentRecipient(result.extractions["paymentRecipient"])

        XCTAssertEqual(fixtureContainer.extractions.first(where: { $0.name == "bic" })?.value,
                       result.extractions["bic"]?.value)
        XCTAssertEqual(fixtureContainer.extractions.first(where: { $0.name == "amountToPay" })?.value,
                       result.extractions["amountToPay"]?.value)
    }

    /*
     Verifies that the `paymentRecipient` extraction is present and has a non-nil value.

     This method asserts that:
     - The `paymentRecipient` extraction exists.
     - The `paymentRecipient` extraction has a non-nil value.

     If either of these conditions is not met, the test will fail.

     - Parameter paymentRecipientExtraction: The extraction to be verified.
     */
    func verifyPaymentRecipient(_ paymentRecipientExtraction: Extraction?) {
        XCTAssertNotNil(paymentRecipientExtraction, "The paymentRecipient extraction should be present in the fixtureExtractionsContainer.")
        XCTAssertNotNil(paymentRecipientExtraction?.value, "The value of paymentRecipient extraction should not be nil.")
    }

    @discardableResult
    func verifyExtractions(result: AnalysisResult,
                           fileName: String,
                           verifyLineItemsIfNeeded: Bool = false) -> ExtractionsContainer? {
        guard let fixtureExtractionsContainer = loadFixtureExtractionsContainer(from: fileName) else {
            return nil
        }

        verifyExtractions(result: result, fixtureContainer: fixtureExtractionsContainer)
        // Optionally verify line items if needed
        if verifyLineItemsIfNeeded {
            verifyLineItems(result: result, fixtureContainer: fixtureExtractionsContainer)
        }
        return fixtureExtractionsContainer
    }

    // Specific method for verifying line items on the Return Assistent invoice
    func verifyLineItems(result: AnalysisResult, fixtureContainer: ExtractionsContainer) {
        guard let fixtureLineItems = fixtureContainer.compoundExtractions?.lineItems,
              let resultLineItems = result.lineItems,
              !fixtureLineItems.isEmpty,
              !resultLineItems.isEmpty,
              fixtureLineItems.count == resultLineItems.count else {
            XCTFail("Arrays are either empty or have different lengths")
            return
        }

        // Iterate through both arrays simultaneously if they have the same count

        // The zip function iterates over these two arrays simultaneously.
        // For each iteration, fixtureItem will represent an element from fixtureLineItems, and
        // resultItem will represent the corresponding element from resultLineItems.

        // Compare extractions by name == "baseGross" when line items have discount
        for (fixtureItem, resultItem) in zip(fixtureLineItems, resultLineItems) {
            // Find the element with name property "baseGross" in each array
            if let fixtureBaseGrossExtraction = fixtureItem.first(where: { $0.name == "baseGross" }),
               let resultBaseGrossExtraction = resultItem.first(where: { $0.name == "baseGross" }) {
                // Compare the values of baseGross extractions
                XCTAssertEqual(fixtureBaseGrossExtraction.value, 
                               resultBaseGrossExtraction.value,
                               "Values for baseGross are not equal.")
            } else {
                XCTFail("baseGross not found in one or both arrays.")
            }
        }
    }
}

