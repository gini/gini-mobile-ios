//
//  AnalyticsSessionManager.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

internal class AnalyticsSessionManager {
    static let shared = AnalyticsSessionManager()

    var sessionId: Int64?
    private(set) var eventId: Int64 = 0

    private init() {
        // Generate a new session identifier
        sessionId = Date.berlinTimestamp()
    }

    func incrementEventId() -> Int64 {
        eventId += 1
        return eventId
    }

    func resetSession() {
        sessionId = nil
        eventId = 0
    }
}
