//
//  ClientConfigurationTests.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//
import Testing
import Foundation
@testable import GiniBankAPILibrary

@Suite("ClientConfiguration Tests")
struct ClientConfigurationTests {

    private let testClientID = "test-client"

    // MARK: - Initialization Tests

    @Test("Initialization sets all properties correctly")
    func initialization() {
        let config = ClientConfiguration(clientID: testClientID,
                                         userJourneyAnalyticsEnabled: true,
                                         skontoEnabled: true,
                                         returnAssistantEnabled: true,
                                         transactionDocsEnabled: true,
                                         instantPaymentEnabled: true,
                                         qrCodeEducationEnabled: true,
                                         eInvoiceEnabled: true,
                                         paymentHintsEnabled: true,
                                         savePhotosLocallyEnabled: true)

        #expect(config.clientID == testClientID, "Expected clientID to be \(testClientID)")
        #expect(config.userJourneyAnalyticsEnabled, "Expected userJourneyAnalyticsEnabled to be true")
        #expect(config.skontoEnabled, "Expected skontoEnabled to be true")
        #expect(config.returnAssistantEnabled, "Expected returnAssistantEnabled to be true")
        #expect(config.transactionDocsEnabled, "Expected transactionDocsEnabled to be true")
        #expect(config.instantPaymentEnabled, "Expected instantPaymentEnabled to be true")
        #expect(config.qrCodeEducationEnabled, "Expected qrCodeEducationEnabled to be true")
        #expect(config.eInvoiceEnabled, "Expected eInvoiceEnabled to be true")
        #expect(config.paymentHintsEnabled, "Expected paymentHintsEnabled to be true")
        #expect(config.savePhotosLocallyEnabled, "Expected savePhotosLocallyEnabled to be true")
    }

    @Test("Initialization with all flags disabled")
    func initializationWithDisabledFlags() {
        let config = ClientConfiguration(clientID: testClientID,
                                         userJourneyAnalyticsEnabled: false,
                                         skontoEnabled: false,
                                         returnAssistantEnabled: false,
                                         transactionDocsEnabled: false,
                                         instantPaymentEnabled: false,
                                         qrCodeEducationEnabled: false,
                                         eInvoiceEnabled: false,
                                         paymentHintsEnabled: false,
                                         savePhotosLocallyEnabled: false)

        #expect(config.clientID == testClientID, "Expected clientID to be \(testClientID)")
        #expect(!config.userJourneyAnalyticsEnabled, "Expected userJourneyAnalyticsEnabled to be false")
        #expect(!config.skontoEnabled, "Expected skontoEnabled to be false")
        #expect(!config.returnAssistantEnabled, "Expected returnAssistantEnabled to be false")
        #expect(!config.transactionDocsEnabled, "Expected transactionDocsEnabled to be false")
        #expect(!config.instantPaymentEnabled, "Expected instantPaymentEnabled to be false")
        #expect(!config.qrCodeEducationEnabled, "Expected qrCodeEducationEnabled to be false")
        #expect(!config.eInvoiceEnabled, "Expected eInvoiceEnabled to be false")
        #expect(!config.paymentHintsEnabled, "Expected paymentHintsEnabled to be false")
        #expect(!config.savePhotosLocallyEnabled, "Expected savePhotosLocallyEnabled to be false")
    }

    // MARK: - JSON Decoding Tests

    @Test("Decoding from valid JSON with all properties")
    func decodingFromValidJSON() throws {
        let data = loadFile(withName: "clientConfiguration", ofType: "json")
        let decoder = JSONDecoder()

        let config = try decoder.decode(ClientConfiguration.self, from: data)

        #expect(config.clientID == testClientID, "Expected clientID to be \(testClientID)")
        #expect(config.userJourneyAnalyticsEnabled, "Expected userJourneyAnalyticsEnabled to be true from JSON")
        #expect(config.skontoEnabled, "Expected skontoEnabled to be true from JSON")
        #expect(config.returnAssistantEnabled, "Expected returnAssistantEnabled to be true from JSON")
        #expect(!config.transactionDocsEnabled, "Expected transactionDocsEnabled to be false from JSON")
        #expect(!config.instantPaymentEnabled, "Expected instantPaymentEnabled to be false from JSON")
        #expect(!config.qrCodeEducationEnabled, "Expected qrCodeEducationEnabled to be false from JSON")
        #expect(!config.eInvoiceEnabled, "Expected eInvoiceEnabled to be false from JSON")
        #expect(!config.paymentHintsEnabled, "Expected paymentHintsEnabled to be false from JSON")
        #expect(!config.savePhotosLocallyEnabled, "Expected savePhotosLocallyEnabled to be false from JSON")
    }

    @Test("Decoding fails when missing required clientID field")
    func decodingFailsWhenMissingRequiredField() {
        let data = loadFile(withName: "clientConfigurationMissing", ofType: "json")
        let decoder = JSONDecoder()

        #expect(throws: Error.self) {
            try decoder.decode(ClientConfiguration.self, from: data)
        }
    }

    // MARK: - JSON Encoding Tests

    @Test("Encoding to JSON preserves all properties")
    func encodingToJSON() throws {
        let config = ClientConfiguration(clientID: testClientID,
                                         userJourneyAnalyticsEnabled: true,
                                         skontoEnabled: false,
                                         returnAssistantEnabled: true,
                                         transactionDocsEnabled: false,
                                         instantPaymentEnabled: true,
                                         qrCodeEducationEnabled: false,
                                         eInvoiceEnabled: true,
                                         paymentHintsEnabled: false,
                                         savePhotosLocallyEnabled: true)
        let encoder = JSONEncoder()

        let data = try encoder.encode(config)
        let decodedConfig = try JSONDecoder().decode(ClientConfiguration.self, from: data)

        #expect(decodedConfig.clientID == config.clientID,
                "Expected clientID to be preserved after encoding/decoding")
        #expect(decodedConfig.userJourneyAnalyticsEnabled == config.userJourneyAnalyticsEnabled,
                "Expected userJourneyAnalyticsEnabled to be preserved")
        #expect(decodedConfig.skontoEnabled == config.skontoEnabled,
                "Expected skontoEnabled to be preserved")
        #expect(decodedConfig.returnAssistantEnabled == config.returnAssistantEnabled,
                "Expected returnAssistantEnabled to be preserved")
        #expect(decodedConfig.transactionDocsEnabled == config.transactionDocsEnabled,
                "Expected transactionDocsEnabled to be preserved")
        #expect(decodedConfig.instantPaymentEnabled == config.instantPaymentEnabled,
                "Expected instantPaymentEnabled to be preserved")
        #expect(decodedConfig.qrCodeEducationEnabled == config.qrCodeEducationEnabled,
                "Expected qrCodeEducationEnabled to be preserved")
        #expect(decodedConfig.eInvoiceEnabled == config.eInvoiceEnabled,
                "Expected eInvoiceEnabled to be preserved")
        #expect(decodedConfig.paymentHintsEnabled == config.paymentHintsEnabled,
                "Expected paymentHintsEnabled to be preserved")
        #expect(decodedConfig.savePhotosLocallyEnabled == config.savePhotosLocallyEnabled,
                "Expected savePhotosLocallyEnabled to be preserved")
    }

    // MARK: - Property Combinations Tests

    @Test("Mixed enabled and disabled flags work correctly")
    func mixedFlagConfiguration() {
        let config = ClientConfiguration(clientID: testClientID,
                                         userJourneyAnalyticsEnabled: true,
                                         skontoEnabled: false,
                                         returnAssistantEnabled: true,
                                         transactionDocsEnabled: false,
                                         instantPaymentEnabled: false,
                                         qrCodeEducationEnabled: true,
                                         eInvoiceEnabled: false,
                                         paymentHintsEnabled: true,
                                         savePhotosLocallyEnabled: false)

        #expect(config.userJourneyAnalyticsEnabled, "Expected userJourneyAnalyticsEnabled to be true")
        #expect(!config.skontoEnabled, "Expected skontoEnabled to be false")
        #expect(config.returnAssistantEnabled, "Expected returnAssistantEnabled to be true")
        #expect(!config.transactionDocsEnabled, "Expected transactionDocsEnabled to be false")
        #expect(!config.instantPaymentEnabled, "Expected instantPaymentEnabled to be false")
        #expect(config.qrCodeEducationEnabled, "Expected qrCodeEducationEnabled to be true")
        #expect(!config.eInvoiceEnabled, "Expected eInvoiceEnabled to be false")
        #expect(config.paymentHintsEnabled, "Expected paymentHintsEnabled to be true")
        #expect(!config.savePhotosLocallyEnabled, "Expected savePhotosLocallyEnabled to be false")
    }
}
