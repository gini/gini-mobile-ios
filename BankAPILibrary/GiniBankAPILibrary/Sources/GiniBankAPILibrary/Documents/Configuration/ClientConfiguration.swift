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
     */
    public init(clientID: String,
                userJourneyAnalyticsEnabled: Bool,
                skontoEnabled: Bool,
                returnAssistantEnabled: Bool,
                transactionDocsEnabled: Bool) {
        self.clientID = clientID
        self.userJourneyAnalyticsEnabled = userJourneyAnalyticsEnabled
        self.skontoEnabled = skontoEnabled
        self.returnAssistantEnabled = returnAssistantEnabled
        self.transactionDocsEnabled = transactionDocsEnabled
    }
    
    public let clientID: String
    public let userJourneyAnalyticsEnabled: Bool
    public let skontoEnabled: Bool
    public let returnAssistantEnabled: Bool
    public let transactionDocsEnabled: Bool
}
