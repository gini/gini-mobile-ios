//
//  ClientConfigurationTests.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankSDK
@testable import GiniBankAPILibrary

class ClientConfigurationTests: BaseIntegrationTest {
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
            }
        }

        wait(for: [expect], timeout: 30.0)
    }

    func testFetchingConfigurationFailsWithInvalidDomain() {
        // Setup a misconfigured domain to induce failure
        let sessionManager: SessionManager = giniHelper.giniBankAPIDocumentService.sessionManager as! SessionManager
        let invalidAPIDomain = APIDomain.custom(domain: "invalid.domain", path: nil, tokenSource: nil)
        let invalidDomainService = ClientConfigurationService(sessionManager: sessionManager,
                                                              apiDomain: invalidAPIDomain)

        let expect = expectation(description: "Should fail to fetch configuration with an invalid domain")

        invalidDomainService.fetchConfigurations { result in
            switch result {
                case .success:
                    XCTFail("Expected fetch to fail with invalid domain, but succeeded")
                case .failure(let error):
                    print("Received expected error: \(error)")
                    expect.fulfill()
            }
        }

        wait(for: [expect], timeout: 30.0)
    }

    func testFetchedConfigurationHasExpectedProperties() {
        let expect = expectation(description: "Configuration should have all required fields populated")

        giniHelper.giniBankConfigurationService.fetchConfigurations { result in
            switch result {
            case .success(let configuration):
                self.assertRequiredFields(in: configuration)
                expect.fulfill()
            case .failure(let error):
                XCTFail("Failed to fetch configuration: \(error.localizedDescription)")
            }
        }

        wait(for: [expect], timeout: 30.0)
    }

    func testFetchingConfigurationFails() {
        let mockService = MockFailingConfigurationService()
        let expect = expectation(description: "Should fail to fetch configuration")

        mockService.fetchConfigurations { result in
            switch result {
            case .success(_):
                XCTFail("Expected fetch to fail, but succeeded")
            case .failure(let error):
                XCTAssertNotNil(error, "Expected an error on failure")
                expect.fulfill()
            }
        }

        wait(for: [expect], timeout: 30.0)
    }

    // MARK: - Helper

    private func assertRequiredFields(in configuration: ClientConfiguration) {
        XCTAssertFalse(configuration.clientID.isEmpty, "clientID should not be empty")
        XCTAssertNotNil(configuration.userJourneyAnalyticsEnabled, "userJourneyAnalyticsEnabled should be present")
        XCTAssertNotNil(configuration.skontoEnabled, "skontoEnabled should be present")
        XCTAssertNotNil(configuration.returnAssistantEnabled, "returnAssistantEnabled should be present")
        XCTAssertNotNil(configuration.transactionDocsEnabled, "transactionDocsEnabled should be present")
        XCTAssertNotNil(configuration.instantPaymentEnabled, "instantPaymentEnabled should be present")
        XCTAssertNotNil(configuration.qrCodeEducationEnabled, "qrCodeEducationEnabled should be present")
        XCTAssertNotNil(configuration.eInvoiceEnabled, "eInvoiceEnabled should be present")
        XCTAssertNotNil(configuration.alreadyPaidHintEnabled, "alreadyPaidHintEnabled should be present")
        XCTAssertNotNil(configuration.savePhotosLocallyEnabled, "savePhotosLocallyEnabled should be present")
    }
}
