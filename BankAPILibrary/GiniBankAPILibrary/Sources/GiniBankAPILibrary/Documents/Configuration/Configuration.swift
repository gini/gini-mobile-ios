//
//  Configuration.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation

// TODO: [PP-352] Check CodingKeys when backend will be finished
public struct Configuration: Decodable {
    public let clientID: String
    public let userJourneyAnalyticsEnabled: Bool
    public let mixpanelToken: String
    public let skontoEnabled: Bool
}
