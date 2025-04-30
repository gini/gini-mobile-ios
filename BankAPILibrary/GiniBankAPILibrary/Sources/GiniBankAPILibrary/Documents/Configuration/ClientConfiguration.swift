//
//  ClientConfiguration.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation

/**
 A struct representing configuration settings.
 
 This struct holds various configuration options that can be used to customize the behavior and features.

 Note: This configuration is intended for internal use with Gini SDKs only.
 */
public struct ClientConfiguration: Codable {

    public let clientID: String
    public let userJourneyAnalyticsEnabled: Bool
    public let skontoEnabled: Bool
    public let returnAssistantEnabled: Bool
    public let transactionDocsEnabled: Bool
    public let instantPaymentEnabled: Bool
    public let qrCodeEducationEnabled: Bool

    /**
     Creates a new `ClientConfiguration` instance.

     - Parameters:
        - clientID: A unique identifier for the client.
        - userJourneyAnalyticsEnabled: A flag indicating whether user journey analytics is enabled.
        - skontoEnabled: A flag indicating whether Skonto is enabled.
        - returnAssistantEnabled: A flag indicating whether the return assistant feature is enabled.
        - transactionDocsEnabled: A flag indicating whether TransactionDocs feature is enabled.
        - instantPaymentEnabled: A flag indicating whether Instant Payment feature is enabled.
        - qrCodeEducationEnabled: A flag indicating whether QR code education is enabled.
     */
    public init(clientID: String,
                userJourneyAnalyticsEnabled: Bool,
                skontoEnabled: Bool,
                returnAssistantEnabled: Bool,
                transactionDocsEnabled: Bool,
                instantPaymentEnabled: Bool,
                qrCodeEducationEnabled: Bool) {
        self.clientID = clientID
        self.userJourneyAnalyticsEnabled = userJourneyAnalyticsEnabled
        self.skontoEnabled = skontoEnabled
        self.returnAssistantEnabled = returnAssistantEnabled
        self.transactionDocsEnabled = transactionDocsEnabled
        self.instantPaymentEnabled = instantPaymentEnabled
        self.qrCodeEducationEnabled = qrCodeEducationEnabled
    }
}
