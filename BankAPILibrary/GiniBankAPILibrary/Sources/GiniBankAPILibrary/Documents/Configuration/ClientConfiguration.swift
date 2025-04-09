//
//  ClientConfiguration.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation

/**
 A struct representing configuration settings.
 
 This struct holds various configuration options that can be used to customize the behavior and features.
 */
public struct ClientConfiguration: Codable {
    /**
     Creates a new `ClientConfiguration` instance.

     - parameter clientID: A unique identifier for the client.
     - parameter userJourneyAnalyticsEnabled: A flag indicating whether user journey analytics is enabled.
     - parameter skontoEnabled: A flag indicating whether Skonto is enabled.
     - parameter returnAssistantEnabled: A flag indicating whether the return assistant feature is enabled.
     - parameter transactionDocsEnabled: A flag indicating whether TransactionDocs feature is enabled.
     - parameter instantPayment: A flag indicating whether Instant Payment feature is enabled.
     */
    public init(clientID: String,
                userJourneyAnalyticsEnabled: Bool,
                skontoEnabled: Bool,
                returnAssistantEnabled: Bool,
                transactionDocsEnabled: Bool,
                instantPayment: Bool) {
        self.clientID = clientID
        self.userJourneyAnalyticsEnabled = userJourneyAnalyticsEnabled
        self.skontoEnabled = skontoEnabled
        self.returnAssistantEnabled = returnAssistantEnabled
        self.transactionDocsEnabled = transactionDocsEnabled
        self.instantPayment = instantPayment
    }
    
    public let clientID: String
    public let userJourneyAnalyticsEnabled: Bool
    public let skontoEnabled: Bool
    public let returnAssistantEnabled: Bool
    public let transactionDocsEnabled: Bool
    // TODO: Rename `instantPayment` to `instantPaymentEnabled` once the backend uses the new name
    public let instantPayment: Bool
}
