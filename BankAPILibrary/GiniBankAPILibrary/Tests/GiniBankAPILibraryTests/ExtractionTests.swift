//
//  ExtractionTests.swift
//  GiniExampleTests
//
//  Copyright © 2018 Gini. All rights reserved.
//

import XCTest
@testable import GiniBankAPILibrary

class ExtractionTests: XCTestCase {

    lazy var validExtraction: Extraction = {
        let jsonData: Data = loadFile(withName: "extraction", ofType: "json")
        let giniExtraction = try? JSONDecoder().decode(Extraction.self, from: jsonData)
        return giniExtraction!
    }()
    
    let requiredParametersJSON: Data = """
            {
              "entity": "amount",
              "value": "24.99:EUR",
              "name": "amountToPay"
            }
    """.data(using: .utf8)!
    
    let invalidJSON: Data = """
            {
              "entity": "amount"
            }
    """.data(using: .utf8)!
    
    func testEntity() {
        XCTAssertEqual(validExtraction.entity, "amount")
    }
    
    func testValue() {
        XCTAssertEqual(validExtraction.value, "24.99:EUR")
    }
    
    func testName() {
        XCTAssertEqual(validExtraction.name, "amountToPay")
    }
    
    func testBox() {
        XCTAssertNotNil(validExtraction.box, "extraction bound box should not be nil")
        XCTAssertEqual(validExtraction.box?.height, 9.0, "extraction bounding box height should match")
        XCTAssertEqual(validExtraction.box?.left, 516.0, "extraction bounding box left should match")
        XCTAssertEqual(validExtraction.box?.page, 1, "extraction bounding box page should match")
        XCTAssertEqual(validExtraction.box?.top, 588.0, "extraction bounding box top should match")
        XCTAssertEqual(validExtraction.box?.width, 42.0, "extraction bounding box width should match")
    }
    
    func testCandidatesReference() {
        XCTAssertEqual(validExtraction.candidates, "amounts")
    }
    
    func testRequiredParametersExtractionDecoding() {
        let extraction = try? JSONDecoder().decode(Extraction.self, from: requiredParametersJSON)

        XCTAssertNotNil(extraction, "extraction should not be nil")
    }
    
    func testInvalidExtractionDecoding() {
        let extraction = try? JSONDecoder().decode(Extraction.self, from: invalidJSON)
        
        XCTAssertNil(extraction, "extraction should be nil")
    }
    
}
