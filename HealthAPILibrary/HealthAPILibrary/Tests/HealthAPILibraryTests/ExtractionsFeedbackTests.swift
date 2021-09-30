//
//  ExtractionsFeedbackTests.swift
//  GiniPayApiLib-Unit-Tests
//
//  Created by Enrique del Pozo Gómez on 3/22/19.
//

import XCTest
@testable import GiniPayApiLib

final class ExtractionsFeedbackTests: XCTestCase {

    lazy var feedbackJson = loadFile(withName: "feedback", ofType: "json")
    lazy var extractionsJson = loadFile(withName: "extractions", ofType: "json")

    func testExtractionsFeedbackEncoding() {
        let extractionsContainer = try? JSONDecoder().decode(ExtractionsContainer.self, from: extractionsJson)
        XCTAssertNoThrow(try JSONEncoder().encode(ExtractionsFeedback(feedback: extractionsContainer!.extractions)),
                         "error thrown while encoding feedback")
    }
}
