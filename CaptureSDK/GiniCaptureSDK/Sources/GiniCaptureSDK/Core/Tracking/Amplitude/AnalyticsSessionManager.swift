//
//  AnalyticsSessionManager.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

class AnalyticsSessionManager {
    static let shared = AnalyticsSessionManager()

    var sessionId: Int64
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
        sessionId = Date.berlinTimestamp()
        eventId = 0
    }
}
