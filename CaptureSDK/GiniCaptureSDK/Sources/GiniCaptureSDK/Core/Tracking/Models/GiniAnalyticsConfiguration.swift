//
//  GiniAnalyticsConfiguration.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

/**
 Struct for analytics configuration settings
 */
public struct GiniAnalyticsConfiguration {
    /**
     An initializer for an `GiniAnalyticsConfiguration` structure
     
     - parameter clientID: A unique identifier for the client.
     - parameter userJourneyAnalyticsEnabled: A flag indicating whether user journey analytics is enabled.
     */
    public init(clientID: String,
                userJourneyAnalyticsEnabled: Bool) {
        self.clientID = clientID
        self.userJourneyAnalyticsEnabled = userJourneyAnalyticsEnabled
    }

    public let clientID: String
    public let userJourneyAnalyticsEnabled: Bool
}
