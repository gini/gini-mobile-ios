//
//  CXTransferSummaryIntegrationTest.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankAPILibrary
@testable import GiniCaptureSDK
@testable import GiniBankSDK

/**
 Integration tests for the CX payment flow.

 These tests upload a CX invoice, verify the `crossBorderPayment` compound extractions
 returned by the Gini backend, and then optionally send transfer summary feedback with
 `productTag == .cxExtractions`.

 - Note: The product tag is switched to `.cxExtractions` **after the partial document upload
   completes and before `startAnalysis()` is called** (see `handleUploadSuccess`).
   Setting it before the partial upload causes the `x-document-metadata-product-tag` header
   to be attached to that request, which the test account rejects with a 400 response.
   Setting it before `startAnalysis()` ensures the composite document POST carries
   `cxExtractions`, which routes the analysis through the CX extraction pipeline.
 */
class CXTransferSummaryIntegrationTest: BaseIntegrationTest {

    private let mockedInvoiceName = "Gini_invoice_example_cxpayment_reference"
    private let fixtureResultName = "result_Gini_invoice_example_cxpayment_reference"

    override func setUp() {
        giniHelper.setupCX()
    }

    /**
     Overrides the base upload-success handler to switch the product tag to `.cxExtractions`
     before `startAnalysis()` is called.

     The partial document upload must use the default `sepaExtractions` tag — the test
     account rejects the `cxExtractions` tag on the partial-document endpoint with a 400.
     The composite document POST (triggered by `startAnalysis()`) must carry the
     `cxExtractions` tag so that the backend routes the document through the CX extraction
     pipeline and returns `crossBorderPayment` compound extractions.
     */
    override func handleUploadSuccess(captureDocument: GiniCaptureDocument,
                                      delegate: GiniCaptureResultsDelegate) {
        GiniConfiguration.shared.productTag = .cxExtractions
        super.handleUploadSuccess(captureDocument: captureDocument, delegate: delegate)
    }

    /**
     Verifies that the backend returns `crossBorderPayment` compound extractions
     for the CX invoice and that they match the expected fixture values.
     */
    func testExtractionsForCXPayment() {
        let expect = expectation(description: "The crossBorderPayment compound extractions match the fixture JSON")
        let delegate = CaptureResultsDelegateForCXTest(testCase: self,
                                                       fixtureResultName: fixtureResultName,
                                                       expect: expect)
        uploadAndAnalyzeDocument(fileName: mockedInvoiceName,
                                 delegate: delegate)
        wait(for: [expect], timeout: 60)
    }

    /**
     Verifies that confirmed CX payment fields sent via `sendTransferSummary(extractions:)`
     are accepted by the backend under `compoundExtractions["crossBorderPayment"]`.
     */
    func testSendCXTransferSummaryFeedback() {
        let expect = expectation(description: "CX transfer summary feedback was accepted by the backend")
        let delegate = CaptureResultsDelegateForCXTest(testCase: self,
                                                       fixtureResultName: fixtureResultName,
                                                       sendFeedback: true,
                                                       expect: expect)
        uploadAndAnalyzeDocument(fileName: mockedInvoiceName,
                                 delegate: delegate)
        wait(for: [expect], timeout: 60)
    }

    // MARK: - Delegate

    class CaptureResultsDelegateForCXTest: GiniCaptureResultsDelegate {

        let testCase: CXTransferSummaryIntegrationTest
        let fixtureResultName: String
        let sendFeedback: Bool
        let expect: XCTestExpectation

        init(testCase: CXTransferSummaryIntegrationTest,
             fixtureResultName: String,
             sendFeedback: Bool = false,
             expect: XCTestExpectation) {
            self.testCase = testCase
            self.fixtureResultName = fixtureResultName
            self.sendFeedback = sendFeedback
            self.expect = expect
        }

        func giniCaptureAnalysisDidFinishWith(result: AnalysisResult) {
            guard let fixtureContainer = testCase.loadFixtureExtractionsContainer(from: fixtureResultName) else {
                return
            }

            /// Verify only `crossBorderPayment` compound extractions — flat extractions are ignored.
            testCase.verifyCrossBorderPayment(result: result, fixtureContainer: fixtureContainer)

            if sendFeedback {

                /// Build the CX fields from the crossBorderPayment compound extractions.
                let cxFields = result.crossBorderPayment?.first?.reduce(into: [String: String]()) { dict, extraction in
                    if let name = extraction.name {
                        dict[name] = extraction.value
                    }
                } ?? [:]

                GiniBankConfiguration.shared.sendTransferSummary(extractions: cxFields)
                testCase.updateAndVerifyCXTransferSummary(result: result, expect: expect)
            } else {
                expect.fulfill()
            }
        }

        func giniCaptureDidCancelAnalysis() {
            // This method will remain empty; no implementation is needed.
        }

        func giniCaptureDidEnterManually() {
            // This method will remain empty; no implementation is needed.
        }
    }
}
