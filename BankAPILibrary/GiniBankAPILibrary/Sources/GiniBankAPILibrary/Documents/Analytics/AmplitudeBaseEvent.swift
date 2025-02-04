//
//  AmplitudeBaseEvent.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

/// The `AmplitudeBaseEvent` struct represents an event with various properties and implements encoding for serialization.
public struct AmplitudeBaseEvent: Encodable, Equatable {
    var eventType: String
    var eventProperties: [String: Any]?
    var userProperties: [String: Any]?
    var eventOptions: AmplitudeEventOptions

    public enum CodingKeys: String, CodingKey {
        case eventType = "event_type"
        case eventProperties = "event_properties"
        case userProperties = "user_properties"
        case userId = "user_id"
        case deviceId = "device_id"
        case timestamp = "time"
        case eventId = "event_id"
        case sessionId = "session_id"
        case insertId = "insert_id"
        case appVersion = "app_version"
        case platform
        case osName = "os_name"
        case osVersion = "os_version"
        case deviceBrand = "device_brand"
        case deviceModel = "device_model"
        case country
        case city
        case language
        case ip
    }

    /// Initializes a new instance of the `AmplitudeBaseEvent` struct.
    public init(eventType: String,
                eventProperties: [String: Any]? = nil,
                userProperties: [String: Any]? = nil,
                eventOptions: AmplitudeEventOptions) {
        self.eventType = eventType
        self.eventProperties = eventProperties
        self.userProperties = userProperties
        self.eventOptions = eventOptions
    }

    /// Encodes the event into the provided encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    /// - Throws: An error if any values are invalid for the given encoder's format.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(eventType, forKey: .eventType)
        try container.encodeIfPresent(eventProperties, forKey: .eventProperties)
        try container.encodeIfPresent(userProperties, forKey: .userProperties)
        try container.encodeIfPresent(eventOptions.userId, forKey: .userId)
        try container.encodeIfPresent(eventOptions.deviceId, forKey: .deviceId)
        try container.encodeIfPresent(eventOptions.time, forKey: .timestamp)
        try container.encodeIfPresent(eventOptions.eventId, forKey: .eventId)
        try container.encodeIfPresent(eventOptions.sessionId, forKey: .sessionId)
        try container.encodeIfPresent(eventOptions.platform, forKey: .platform)
        try container.encodeIfPresent(eventOptions.osName, forKey: .osName)
        try container.encodeIfPresent(eventOptions.osVersion, forKey: .osVersion)
        try container.encodeIfPresent(eventOptions.deviceBrand, forKey: .deviceBrand)
        try container.encodeIfPresent(eventOptions.deviceModel, forKey: .deviceModel)
        try container.encodeIfPresent(eventOptions.language, forKey: .language)
        try container.encodeIfPresent(eventOptions.ip, forKey: .ip)
    }

    public static func == (lhs: AmplitudeBaseEvent, rhs: AmplitudeBaseEvent) -> Bool {
        return lhs.eventType == rhs.eventType && lhs.eventOptions.eventId == rhs.eventOptions.eventId
    }
}
