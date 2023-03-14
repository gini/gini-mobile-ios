//
//  ExtractionsContainerTest.swift
//  GiniBankAPI-Unit-Tests
//
//  Created by Enrique del Pozo Gómez on 3/20/19.
//

import XCTest
@testable import GiniBankAPILibrary

final class ExtractionsContainerTest: XCTestCase {
    
    lazy var extractionsContainerJson = loadFile(withName: "extractionsContainer", ofType: "json")
    lazy var extractionsWOCandidatesJson = loadFile(withName: "extractionsContainerWOCandidates", ofType: "json")
    
    func testExtractionsContainerDecodingDoesNotThrow() {
        XCTAssertNoThrow(try JSONDecoder().decode(ExtractionsContainer.self, from: extractionsContainerJson),
                         "extractions container should be decoded")
    }
    
    func testExtractionsContainerWOCandidatesDecodingDoesNotThrow() {
        XCTAssertNoThrow(try JSONDecoder().decode(ExtractionsContainer.self, from: extractionsWOCandidatesJson),
                         "extractions container without candidates should be decoded")
    }
    
    func testExtractionsContainerDecoding() throws {
        
        let container = try JSONDecoder().decode(ExtractionsContainer.self, from: extractionsContainerJson)
        
        XCTAssertEqual(container.extractions.count, 2)
        
        let extraction = Extraction(box: Extraction.Box(height: 9.0,
                                                        left: 521.48,
                                                        page: 1,
                                                        top: 459.11,
                                                        width: 27.519999999999982),
                                    candidates: "amounts",
                                    entity: "amount",
                                    value: "123.93:EUR",
                                    name: "amountToPay")
        
        XCTAssertTrue(container.extractions.contains(extraction))
        
        let lineItemExtraction = Extraction(box: Extraction.Box(height: 9.0,
                                                                left: 72.0,
                                                                page: 1,
                                                                top: 347.11,
                                                                width: 5.0),
                                            candidates: nil,
                                            entity: "number",
                                            value: "1",
                                            name: "quantity")
        
        XCTAssertEqual(container.compoundExtractions!.count, 1)
        XCTAssertEqual(container.compoundExtractions!["lineItems"]!.count, 3)
        XCTAssertEqual(container.compoundExtractions!["lineItems"]!.first!.count, 4)
        XCTAssertTrue(container.compoundExtractions!["lineItems"]!.first!.contains(lineItemExtraction))
        
        let candidate = Extraction.Candidate(box: Extraction.Box(height: 9.0,
                                                                 left: 521.48,
                                                                 page: 1,
                                                                 top: 459.11,
                                                                 width: 27.519999999999982),
                                             entity: "amount",
                                             value: "123.93:EUR")
        
        XCTAssertEqual(container.candidates.count, 2)
        XCTAssertEqual(container.candidates["amounts"]!.first, candidate)
        
        let returnReason = ReturnReason(id: "r1", localizedLabels: ["de" : "Anderes Aussehen als angeboten"])
        
        XCTAssertEqual(container.returnReasons!.count, 4)
        XCTAssertTrue(container.returnReasons!.contains(returnReason))
        
    }
}
