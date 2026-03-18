//
//  GiniHealthTestCase.swift
//  GiniHealthSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniHealthSDK
@testable import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK
@testable import GiniUtilites

/// Base class for GiniHealth unit tests.
///
/// Provides shared `giniHealth` / `giniHealthAPI` instances wired to a
/// `MockSessionManager`, and a `waitForResult` helper that bridges
/// callback-based APIs into a synchronous test flow.
class GiniHealthTestCase: XCTestCase {

    var giniHealthAPI: GiniHealthAPI!
    var giniHealth: GiniHealth!

    private let versionAPI = 5
    let timeout: TimeInterval = 2

    override func setUp() {
        super.setUp()
        let sessionManagerMock = MockSessionManager()
        let documentService = DefaultDocumentService(sessionManager: sessionManagerMock,
                                                     apiVersion: versionAPI)
        let paymentService = PaymentService(sessionManager: sessionManagerMock,
                                            apiVersion: versionAPI)
        let clientConfigurationService = ClientConfigurationService(sessionManager: sessionManagerMock,
                                                                    apiVersion: versionAPI)
        GiniHealthConfiguration.shared.clientConfiguration = nil
        giniHealthAPI = GiniHealthAPI(documentService: documentService,
                                      paymentService: paymentService,
                                      clientConfigurationService: clientConfigurationService)
        giniHealth = GiniHealth(giniApiLib: giniHealthAPI)
    }

    override func tearDown() {
        giniHealthAPI = nil
        giniHealth = nil
        super.tearDown()
    }

    /// Waits synchronously for an asynchronous operation and returns its `Result`.
    ///
    /// Creates an expectation, invokes `action` with a completion handler, and blocks
    /// until the completion fires or `timeout` is reached. Use `XCTUnwrap` at call
    /// sites when the result is required:
    /// ```swift
    /// let result = try XCTUnwrap(waitForResult {
    ///     giniHealth.pollDocument(docId: id, completion: $0)
    /// })
    /// ```
    @discardableResult
    func waitForResult<T, E: Error>(_ action: (@escaping (Result<T, E>) -> Void) -> Void) -> Result<T, E>? {
        let expectation = expectation(description: "Awaiting async result")
        var capturedResult: Result<T, E>?

        action {
            capturedResult = $0
            expectation.fulfill()
        }

        waitForExpectations(timeout: timeout)
        return capturedResult
    }
}
