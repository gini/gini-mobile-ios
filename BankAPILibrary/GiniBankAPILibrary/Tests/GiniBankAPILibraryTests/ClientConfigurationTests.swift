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
                                         savePhotosLocallyEnabled: true,
                                         alreadyPaidHintEnabled: true,
                                         paymentDueHintEnabled: true,
                                         creditNoteHintEnabled: true,
                                         paymentScheduleHintEnabled: true,
                                         unsupportedQRCodeWarningEnabled: true)

        #expect(config.clientID == testClientID, "Expected clientID to be \(testClientID)")
        #expect(config.userJourneyAnalyticsEnabled, "Expected userJourneyAnalyticsEnabled to be true")
        #expect(config.skontoEnabled, "Expected skontoEnabled to be true")
        #expect(config.returnAssistantEnabled, "Expected returnAssistantEnabled to be true")
        #expect(config.transactionDocsEnabled, "Expected transactionDocsEnabled to be true")
        #expect(config.instantPaymentEnabled, "Expected instantPaymentEnabled to be true")
        #expect(config.qrCodeEducationEnabled, "Expected qrCodeEducationEnabled to be true")
        #expect(config.eInvoiceEnabled, "Expected eInvoiceEnabled to be true")
        #expect(config.alreadyPaidHintEnabled, "Expected alreadyPaidHintEnabled to be true")
        #expect(config.savePhotosLocallyEnabled, "Expected savePhotosLocallyEnabled to be true")
        #expect(config.paymentDueHintEnabled, "Expected paymentDueHintEnabled to be true")
        #expect(config.creditNoteHintEnabled, "Expected creditNoteHintEnabled to be true")
        #expect(config.paymentScheduleHintEnabled, "Expected paymentScheduleHintEnabled to be true")
        #expect(config.unsupportedQRCodeWarningEnabled, "Expected unsupportedQRCodeWarningEnabled to be true")
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
                                         savePhotosLocallyEnabled: false,
                                         alreadyPaidHintEnabled: false,
                                         paymentDueHintEnabled: false,
                                         creditNoteHintEnabled: false,
                                         paymentScheduleHintEnabled: false,
                                         unsupportedQRCodeWarningEnabled: false)

        #expect(config.clientID == testClientID, "Expected clientID to be \(testClientID)")
        #expect(!config.userJourneyAnalyticsEnabled, "Expected userJourneyAnalyticsEnabled to be false")
        #expect(!config.skontoEnabled, "Expected skontoEnabled to be false")
        #expect(!config.returnAssistantEnabled, "Expected returnAssistantEnabled to be false")
        #expect(!config.transactionDocsEnabled, "Expected transactionDocsEnabled to be false")
        #expect(!config.instantPaymentEnabled, "Expected instantPaymentEnabled to be false")
        #expect(!config.qrCodeEducationEnabled, "Expected qrCodeEducationEnabled to be false")
        #expect(!config.eInvoiceEnabled, "Expected eInvoiceEnabled to be false")
        #expect(!config.alreadyPaidHintEnabled, "Expected alreadyPaidHintEnabled to be false")
        #expect(!config.savePhotosLocallyEnabled, "Expected savePhotosLocallyEnabled to be false")
        #expect(!config.paymentDueHintEnabled, "Expected paymentDueHintEnabled to be false")
        #expect(!config.creditNoteHintEnabled, "Expected creditNoteHintEnabled to be false")
        #expect(!config.paymentScheduleHintEnabled, "Expected paymentScheduleHintEnabled to be false")
        #expect(!config.unsupportedQRCodeWarningEnabled, "Expected unsupportedQRCodeWarningEnabled to be false")
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
        #expect(!config.alreadyPaidHintEnabled, "Expected alreadyPaidHintEnabled to be false from JSON")
        #expect(!config.savePhotosLocallyEnabled, "Expected savePhotosLocallyEnabled to be false from JSON")
        #expect(!config.paymentDueHintEnabled, "Expected paymentDueHintEnabled to be false from JSON")
        #expect(config.creditNoteHintEnabled, "Expected creditNoteHintEnabled to be true from JSON")
        #expect(config.paymentScheduleHintEnabled, "Expected paymentScheduleHintEnabled to be true from JSON")
        #expect(!config.unsupportedQRCodeWarningEnabled, "Expected unsupportedQRCodeWarningEnabled to be false from JSON")
    }

    @Test("paymentScheduleHintEnabled decodes from JSON payload")
    func paymentScheduleHintEnabledDecodesFromJSON() throws {
        let data = loadFile(withName: "clientConfiguration", ofType: "json")

        let config = try JSONDecoder().decode(ClientConfiguration.self, from: data)
        let reencoded = try JSONEncoder().encode(config)
        let roundTripped = try JSONDecoder().decode(ClientConfiguration.self, from: reencoded)

        #expect(config.paymentScheduleHintEnabled, "Expected paymentScheduleHintEnabled to decode as true")
        #expect(roundTripped.paymentScheduleHintEnabled == config.paymentScheduleHintEnabled,
                "Expected paymentScheduleHintEnabled to survive an encode/decode round trip")
    }

    @Test("Decoding fails when missing required clientID field")
    func decodingFailsWhenMissingRequiredField() {
        let data = loadFile(withName: "clientConfigurationMissing", ofType: "json")
        let decoder = JSONDecoder()

        #expect(throws: Error.self) {
            try decoder.decode(ClientConfiguration.self, from: data)
        }
    }

    /**
     Pins the current synthesized-`Codable` behavior: every feature flag is a
     non-optional `Bool` without a default, so a payload that omits
     `creditNoteHintEnabled` fails to decode entirely instead of falling back
     to a default value. This is a known limitation of the current model —
     if it ever starts decoding successfully, the model's decoding strategy
     changed and this test (and its callers' assumptions) must be revisited.
     */
    @Test("Decoding fails when the creditNoteHintEnabled key is absent from JSON")
    func decodingFailsWhenCreditNoteHintEnabledKeyIsAbsent() {
        let data = loadFile(withName: "clientConfigurationMissingCreditNoteHint", ofType: "json")
        let decoder = JSONDecoder()

        let error = #expect(throws: DecodingError.self) {
            try decoder.decode(ClientConfiguration.self, from: data)
        }

        guard case .keyNotFound(let missingKey, _)? = error else {
            Issue.record("Expected DecodingError.keyNotFound for `creditNoteHintEnabled`, got \(String(describing: error))")
            return
        }
        #expect(missingKey.stringValue == "creditNoteHintEnabled",
                "Expected the missing key to be `creditNoteHintEnabled`, got `\(missingKey.stringValue)`")
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
                                         savePhotosLocallyEnabled: true,
                                         alreadyPaidHintEnabled: true,
                                         paymentDueHintEnabled: true,
                                         creditNoteHintEnabled: true,
                                         paymentScheduleHintEnabled: true,
                                         unsupportedQRCodeWarningEnabled: true)

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
        #expect(decodedConfig.savePhotosLocallyEnabled == config.savePhotosLocallyEnabled,
                "Expected savePhotosLocallyEnabled to be preserved")
        #expect(decodedConfig.alreadyPaidHintEnabled == config.alreadyPaidHintEnabled,
                "Expected alreadyPaidHintEnabled to be preserved")
        #expect(decodedConfig.paymentDueHintEnabled == config.paymentDueHintEnabled,
                "Expected paymentDueHintEnabled to be preserved")
        #expect(decodedConfig.creditNoteHintEnabled == config.creditNoteHintEnabled,
                "Expected creditNoteHintEnabled to be preserved")
        #expect(decodedConfig.paymentScheduleHintEnabled == config.paymentScheduleHintEnabled,
                "Expected paymentScheduleHintEnabled to be preserved")
        #expect(decodedConfig.unsupportedQRCodeWarningEnabled == config.unsupportedQRCodeWarningEnabled,
                "Expected unsupportedQRCodeWarningEnabled to be preserved")
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
                                         savePhotosLocallyEnabled: false,
                                         alreadyPaidHintEnabled: true,
                                         paymentDueHintEnabled: false,
                                         creditNoteHintEnabled: true,
                                         paymentScheduleHintEnabled: false,
                                         unsupportedQRCodeWarningEnabled: true)

        #expect(config.userJourneyAnalyticsEnabled, "Expected userJourneyAnalyticsEnabled to be true")
        #expect(!config.skontoEnabled, "Expected skontoEnabled to be false")
        #expect(config.returnAssistantEnabled, "Expected returnAssistantEnabled to be true")
        #expect(!config.transactionDocsEnabled, "Expected transactionDocsEnabled to be false")
        #expect(!config.instantPaymentEnabled, "Expected instantPaymentEnabled to be false")
        #expect(config.qrCodeEducationEnabled, "Expected qrCodeEducationEnabled to be true")
        #expect(!config.eInvoiceEnabled, "Expected eInvoiceEnabled to be false")
        #expect(config.alreadyPaidHintEnabled, "Expected alreadyPaidHintEnabled to be true")
        #expect(!config.savePhotosLocallyEnabled, "Expected savePhotosLocallyEnabled to be false")
        #expect(!config.paymentDueHintEnabled, "Expected paymentDueHintEnabled to be false")
        #expect(config.creditNoteHintEnabled, "Expected creditNoteHintEnabled to be true")
        #expect(!config.paymentScheduleHintEnabled, "Expected paymentScheduleHintEnabled to be false")
        #expect(config.unsupportedQRCodeWarningEnabled, "Expected unsupportedQRCodeWarningEnabled to be true")
    }
}
