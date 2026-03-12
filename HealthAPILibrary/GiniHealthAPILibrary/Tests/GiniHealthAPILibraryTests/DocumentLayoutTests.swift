//
//  DocumentLayoutTests.swift
//  GiniHealthAPILibraryTests
//
//  Copyright © 2019 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniHealthAPILibrary

final class DocumentLayoutTests: XCTestCase {

    lazy var documentLayoutJson = loadFile(withName: "documentLayout",
                                           ofType: "json")

    func testDocumentLayoutDecoding() {
        XCTAssertNoThrow(try JSONDecoder().decode(Document.Layout.self,
                                                  from: documentLayoutJson))
    }

}
