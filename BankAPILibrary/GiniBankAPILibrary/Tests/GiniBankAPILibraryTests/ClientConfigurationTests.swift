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
    private let testClientID = "test-client"

    func testInitialization() {
        let config = ClientConfiguration(clientID: testClientID,
                                         userJourneyAnalyticsEnabled: true,
                                         skontoEnabled: true,
                                         returnAssistantEnabled: true,
                                         transactionDocsEnabled: true,
                                         instantPaymentEnabled: true,
                                         qrCodeEducationEnabled: true,
                                         eInvoiceEnabled: true,
                                         paymentHintsEnabled: true)

        XCTAssertEqual(config.clientID, testClientID)
        XCTAssertTrue(config.userJourneyAnalyticsEnabled)
        XCTAssertTrue(config.skontoEnabled)
        XCTAssertTrue(config.returnAssistantEnabled)
        XCTAssertTrue(config.transactionDocsEnabled)
        XCTAssertTrue(config.instantPaymentEnabled)
        XCTAssertTrue(config.qrCodeEducationEnabled)
        XCTAssertTrue(config.eInvoiceEnabled)
        XCTAssertTrue(config.paymentHintsEnabled)
    }

    func testDecodingFromValidJSON() throws {
        let data = clientConfigurationJson
        let decoder = JSONDecoder()
        let config = try decoder.decode(ClientConfiguration.self, from: data)

        XCTAssertEqual(config.clientID, testClientID)
        XCTAssertTrue(config.userJourneyAnalyticsEnabled)
        XCTAssertTrue(config.skontoEnabled)
        XCTAssertTrue(config.returnAssistantEnabled)
        XCTAssertFalse(config.transactionDocsEnabled)
        XCTAssertFalse(config.instantPaymentEnabled)
        XCTAssertFalse(config.qrCodeEducationEnabled)
        XCTAssertFalse(config.eInvoiceEnabled)
        XCTAssertTrue(config.paymentHintsEnabled)
    }

    func testDecodingFailsWhenMissingRequiredField() {
        XCTAssertThrowsError(try JSONDecoder().decode(ClientConfiguration.self,
                                                      from: clientConfigurationMissingJson)) { error in
            print("Expected decoding error: \(error)")
        }
    }
}
