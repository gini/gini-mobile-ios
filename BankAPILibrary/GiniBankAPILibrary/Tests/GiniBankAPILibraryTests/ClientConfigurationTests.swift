//
//  ClientConfigurationTests.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankAPILibrary

final class ClientConfigurationTests: XCTestCase {

    lazy var clientConfigurationJson = loadFile(withName: "clientConfiguration", ofType: "json")
    lazy var clientConfigurationMissingJson = loadFile(withName: "clientConfigurationMissing", ofType: "json")

    func testInitialization() {
        let config = ClientConfiguration(clientID: "test-client",
                                         userJourneyAnalyticsEnabled: true,
                                         skontoEnabled: true,
                                         returnAssistantEnabled: true,
                                         transactionDocsEnabled: true,
                                         instantPayment: true)

        XCTAssertEqual(config.clientID, "test-client")
        XCTAssertTrue(config.userJourneyAnalyticsEnabled)
        XCTAssertTrue(config.skontoEnabled)
        XCTAssertTrue(config.returnAssistantEnabled)
        XCTAssertTrue(config.transactionDocsEnabled)
        XCTAssertTrue(config.instantPayment)
    }

    func testDecodingFromValidJSON() throws {
        let data = clientConfigurationJson
        let decoder = JSONDecoder()
        let config = try decoder.decode(ClientConfiguration.self, from: data)

        XCTAssertEqual(config.clientID, "test-client")
        XCTAssertTrue(config.userJourneyAnalyticsEnabled)
        XCTAssertTrue(config.skontoEnabled)
        XCTAssertTrue(config.returnAssistantEnabled)
        XCTAssertFalse(config.transactionDocsEnabled)
        XCTAssertFalse(config.instantPayment)
    }

    func testDecodingFailsWhenMissingRequiredField() {
        XCTAssertThrowsError(try JSONDecoder().decode(ClientConfiguration.self, from: clientConfigurationMissingJson)) { error in
            print("Expected decoding error: \(error)")
        }
    }
}
