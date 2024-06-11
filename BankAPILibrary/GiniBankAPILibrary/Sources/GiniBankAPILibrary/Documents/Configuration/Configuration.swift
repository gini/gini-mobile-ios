//
//  Configuration.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation

public struct Configuration: Decodable {
    public let clientID: String
    public let userJourneyAnalyticsEnabled: Bool
    public let mixpanelToken: String?
    public let amplitudeApiKey: String?
    public let skontoEnabled: Bool
    public let returnAssistantEnabled: Bool
}
