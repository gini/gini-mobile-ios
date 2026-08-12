//
//  DocumentServiceTestBase.swift
//  GiniHealthAPILibraryTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniHealthAPILibrary

class DocumentServiceTestBase: XCTestCase {
    var sessionManagerMock: SessionManagerMock!
    var defaultDocumentService: DefaultDocumentService!

    override func setUp() {
        super.setUp()
        sessionManagerMock = SessionManagerMock()
        defaultDocumentService = DefaultDocumentService(sessionManager: sessionManagerMock,
                                                        apiVersion: 5)
    }

    override func tearDown() {
        defaultDocumentService = nil
        sessionManagerMock = nil
        super.tearDown()
    }

    func awaitSuccess<T>(description: String,
                         timeout: TimeInterval = 1,
                         _ action: (@escaping (Result<T, GiniError>) -> Void) -> Void,
                         validate: @escaping (T) -> Void) {
        let exp = expectation(description: description)
        action { result in
            switch result {
            case .success(let value):
                validate(value)
            case .failure(let error):
                XCTFail("Unexpected failure: \(error)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: timeout)
    }

    /// Decodes a JSON fixture from the test bundle. Named `loadJSON` to avoid
    /// shadowing `NSObject.load()` inside XCTestCase subclasses.
    func loadJSON<T: Decodable>(fromFile named: String, type fileType: String = "json") throws -> T {
        try JSONDecoder().decode(T.self, from: loadFile(withName: named, ofType: fileType))
    }
}
