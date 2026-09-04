//
//  GiniHealthSDKPaymentProviderTests.swift
//  GiniHealthSDKExampleTests
//
//  Payment Provider integration tests
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest
import GiniHealthSDK
@testable import GiniHealthAPILibrary

/// Tests for payment provider operations
final class GiniHealthSDKPaymentProviderTests: GiniHealthSDKIntegrationTestsBase {

    // MARK: - Payment Provider Tests

    func testFetchPaymentProviders() throws {
        let expect = expectation(description: "fetch payment providers")

        paymentService.paymentProviders { result in
            switch result {
            case .success(let providers):
                XCTAssertFalse(providers.isEmpty, "Should have payment providers")

                // Verify provider structure
                if let firstProvider = providers.first {
                    XCTAssertFalse(firstProvider.id.isEmpty, "Provider ID should not be empty")
                    XCTAssertFalse(firstProvider.name.isEmpty, "Provider name should not be empty")
                }
            case .failure(let error):
                XCTFail("Failed to fetch payment providers: \(error)")
            }
            expect.fulfill()
        }

        wait(for: [expect], timeout: networkTimeout)
    }

    func testFetchSinglePaymentProvider() throws {
        let expectProviders = expectation(description: "fetch providers")
        let expectSingleProvider = expectation(description: "fetch single provider")

        var providerId: String?

        // First get a provider ID
        paymentService.paymentProviders { result in
            if case .success(let providers) = result {
                providerId = providers.first?.id
            }
            expectProviders.fulfill()
        }

        wait(for: [expectProviders], timeout: networkTimeout)

        guard let id = providerId else {
            XCTFail("No provider ID available")
            return
        }

        // Fetch single provider by ID
        paymentService.paymentProvider(id: id) { result in
            switch result {
            case .success(let provider):
                XCTAssertEqual(provider.id, id, "Provider ID should match")
                XCTAssertFalse(provider.name.isEmpty, "Provider name should not be empty")
            case .failure(let error):
                XCTFail("Failed to fetch provider: \(error)")
            }
            expectSingleProvider.fulfill()
        }

        wait(for: [expectSingleProvider], timeout: networkTimeout)
    }
}
