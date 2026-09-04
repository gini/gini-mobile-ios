//
//  ExtractionsFeedbackTests.swift
//  GiniBankAPI-Unit-Tests
//
//  Copyright © 2019 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankAPILibrary

final class ExtractionsFeedbackTests: XCTestCase {

    lazy var feedbackJson = loadFile(withName: "feedback", ofType: "json")
    lazy var extractionsJson = loadFile(withName: "extractions", ofType: "json")

    func testExtractionsFeedbackEncoding() {
        let extractionsContainer = try? JSONDecoder().decode(ExtractionsContainer.self, from: extractionsJson)
        XCTAssertNoThrow(try JSONEncoder().encode(ExtractionsFeedback(feedback: extractionsContainer!.extractions)),
                         "error thrown while encoding feedback")
    }
}
