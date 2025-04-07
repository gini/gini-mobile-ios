//
//  GiniBankConfigurationsTests.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankSDK

class GiniBankConfigurationsTests: BaseIntegrationTest {
    override func setUp() {
        giniHelper.setup()
    }
    
    func testFetchingConfigurationSucceeds() {
        let expect = expectation(description: "Should successfully fetch a non-nil configuration")

        giniHelper.giniBankConfigurationService.fetchConfigurations { result in
            switch result {
            case .success(let configuration):
                XCTAssertNotNil(configuration, "Expected a valid configuration, but received nil.")
                expect.fulfill()
            case .failure(let error):
                XCTFail("Expected successful configuration fetch, but failed with error: \(error)")
                expect.fulfill()
            }
        }

        wait(for: [expect], timeout: 30.0)
    }
}
