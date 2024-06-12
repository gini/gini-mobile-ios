//
//  Configuration.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation

/**
 Struct for configuration settings
 */
public struct Configuration: Decodable {
    /**
     An initializer for a `Configuration` structure

     - parameter clientID: A unique identifier for the client.
     - parameter userJourneyAnalyticsEnabled: A flag indicating whether user journey analytics is enabled.
     - parameter mixpanelToken: An optional token for Mixpanel integration.
     - parameter amplitudeApiKey: An optional API key for Amplitude integration.
     - parameter skontoEnabled: A flag indicating whether Skonto is enabled.
     - parameter returnAssistantEnabled: A flag indicating whether the return assistant feature is enabled.
     */
    public init(clientID: String,
                userJourneyAnalyticsEnabled: Bool,
                mixpanelToken: String? = nil,
                amplitudeApiKey: String? = nil,
                skontoEnabled: Bool,
                returnAssistantEnabled: Bool) {
        self.clientID = clientID
        self.userJourneyAnalyticsEnabled = userJourneyAnalyticsEnabled
        self.mixpanelToken = mixpanelToken
        self.amplitudeApiKey = amplitudeApiKey
        self.skontoEnabled = skontoEnabled
        self.returnAssistantEnabled = returnAssistantEnabled
    }
    
    public let clientID: String
    public let userJourneyAnalyticsEnabled: Bool
    public let mixpanelToken: String?
    public let amplitudeApiKey: String?
    public let skontoEnabled: Bool
    public let returnAssistantEnabled: Bool
}
