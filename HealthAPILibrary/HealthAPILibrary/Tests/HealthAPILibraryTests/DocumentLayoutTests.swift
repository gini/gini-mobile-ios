//
//  DocumentLayoutTests.swift
//  GiniPayApiLib-Unit-Tests
//
//  Created by Enrique del Pozo Gómez on 3/21/19.
//

import XCTest
@testable import GiniPayApiLib

final class DocumentLayoutTests: XCTestCase {

    lazy var documentLayoutJson = loadFile(withName: "documentLayout", ofType: "json")
    
    func testDocumentLayoutDecoding() {
        XCTAssertNoThrow(try JSONDecoder().decode(Document.Layout.self, from: documentLayoutJson))
    }

}
