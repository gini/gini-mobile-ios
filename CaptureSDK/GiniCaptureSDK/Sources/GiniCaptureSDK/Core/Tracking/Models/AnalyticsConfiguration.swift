//
//  AnalyticsConfiguration.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation

public struct AnalyticsConfiguration {
    public let clientID: String
    public let userJourneyAnalyticsEnabled: Bool
    public let mixpanelToken: String?
    public let amplitudeApiKey: String?
    
    public init(clientID: String, userJourneyAnalyticsEnabled: Bool, mixpanelToken: String?, amplitudeApiKey: String?) {
        self.clientID = clientID
        self.userJourneyAnalyticsEnabled = userJourneyAnalyticsEnabled
        self.mixpanelToken = mixpanelToken
        self.amplitudeApiKey = amplitudeApiKey
    }
}
