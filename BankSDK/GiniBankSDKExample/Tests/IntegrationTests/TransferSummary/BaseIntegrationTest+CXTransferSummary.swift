//
//  BaseIntegrationTest+CXTransferSummary.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankAPILibrary
@testable import GiniCaptureSDK
@testable import GiniBankSDK

extension BaseIntegrationTest {

    /**
     Verifies the `crossBorderPayment` compound extractions from the analysis result
     against the expected values in the fixture JSON.

     Only the `crossBorderPayment` compound extractions are inspected; flat extractions
     are intentionally ignored for CX documents.

     - Parameters:
       - result: The `AnalysisResult` containing the extracted data.
       - fixtureContainer: The `ExtractionsContainer` decoded from the expected fixture JSON.
     */
    func verifyCrossBorderPayment(result: AnalysisResult, fixtureContainer: ExtractionsContainer) {
        guard let extractedGroups = result.crossBorderPayment,
              !extractedGroups.isEmpty else {
            XCTFail("crossBorderPayment must be present and non-empty in the analysis result")
            return
        }

        guard let fixtureGroups = fixtureContainer.compoundExtractions?.crossBorderPayment,
              !fixtureGroups.isEmpty else {
            XCTFail("crossBorderPayment must be present and non-empty in the fixture JSON")
            return
        }

        XCTAssertEqual(extractedGroups.count,
                       fixtureGroups.count,
                       "Number of crossBorderPayment groups must match the fixture")

        guard let extractedGroup = extractedGroups.first,
              let fixtureGroup = fixtureGroups.first else {
            XCTFail("First crossBorderPayment group must exist in both result and fixture")
            return
        }

        /**
         Helper that finds an extraction by name from a flat `[Extraction]` array.
         */
        func value(for name: String, in group: [Extraction]) -> String? {
            group.first(where: { $0.name == name })?.value.lowercased()
        }

        let fieldsToVerify = ["creditorName",
                              "instructedAmount",
                              "currency",
                              "creditorCountry",
                              "creditorAccountNumber"]

        for field in fieldsToVerify {
            let extractedValue = value(for: field, in: extractedGroup)
            let fixtureValue   = value(for: field, in: fixtureGroup)
            XCTAssertEqual(extractedValue, fixtureValue,
                           "crossBorderPayment field '\(field)' must match the fixture")
        }
    }

    /**
     Waits for the backend to process the CX feedback, then verifies the document
     is still accessible — confirming the `crossBorderPayment` compound extractions
     were accepted without error.

     - Parameters:
       - result: The analysis result containing the document reference.
       - expect: The expectation to fulfill on success.
     */
    func updateAndVerifyCXTransferSummary(result: AnalysisResult, expect: XCTestExpectation) {
        guard let document = result.document else {
            XCTFail("Document must be present to verify CX transfer summary feedback")
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.getUpdatedExtractionsFromGiniBankSDK(for: document) { updatedResult in
                switch updatedResult {
                case .success:
                    /// Backend accepted the `crossBorderPayment` feedback — document is still accessible.
                    GiniBankConfiguration.shared.cleanup()
                    XCTAssertNil(GiniBankConfiguration.shared.documentService)
                    expect.fulfill()
                case let .failure(error):
                    XCTFail("CX transfer summary feedback was rejected by the backend: \(error)")
                }
            }
        }
    }
}
