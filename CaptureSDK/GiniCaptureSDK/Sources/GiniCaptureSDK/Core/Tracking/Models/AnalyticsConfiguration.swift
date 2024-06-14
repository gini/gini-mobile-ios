//
//  AnalyticsConfiguration.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

/**
 Struct for analytics configuration settings
 */
public struct AnalyticsConfiguration {
    /**
     An initializer for an `AnalyticsConfiguration` structure
     
     - parameter clientID: A unique identifier for the client.
     - parameter userJourneyAnalyticsEnabled: A flag indicating whether user journey analytics is enabled.
     - parameter mixpanelToken: An optional token for Mixpanel integration.
     - parameter amplitudeApiKey: An optional API key for Amplitude integration.
     */
    public init(clientID: String,
                userJourneyAnalyticsEnabled: Bool,
                mixpanelToken: String?,
                amplitudeApiKey: String?) {
        self.clientID = clientID
        self.userJourneyAnalyticsEnabled = userJourneyAnalyticsEnabled
        self.mixpanelToken = mixpanelToken
        self.amplitudeApiKey = amplitudeApiKey
    }

    public let clientID: String
    public let userJourneyAnalyticsEnabled: Bool
    public let mixpanelToken: String?
    public let amplitudeApiKey: String?
}
