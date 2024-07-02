//
//  EventOptions.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

/// The `EventOptions` struct holds common properties for events.
struct EventOptions {
    var userId: String?
    var time: Int64?
    var sessionId: Int64?
    var platform: String?
    var osVersion: String?
    var osName: String?
    var language: String?
    var ip: String?
    var eventId: Int64?
    var deviceModel: String?
    var deviceId: String?
    var deviceBrand: String?
    var appVersion: String?

    /// Initializes a new instance of the `EventOptions` struct.
    init(userId: String? = nil,
         deviceId: String? = nil,
         time: Int64? = nil,
         sessionId: Int64? = nil,
         platform: String? = nil,
         osVersion: String? = nil,
         osName: String? = nil,
         language: String? = nil,
         ip: String? = nil,
         eventId: Int64? = nil,
         deviceModel: String? = nil,
         deviceBrand: String? = nil,
         appVersion: String? = nil) {
        self.userId = userId
        self.deviceId = deviceId
        self.time = time
        self.sessionId = sessionId
        self.platform = platform
        self.osVersion = osVersion
        self.osName = osName
        self.language = language
        self.ip = ip
        self.eventId = eventId
        self.deviceModel = deviceModel
        self.deviceBrand = deviceBrand
        self.appVersion = appVersion
    }
}
