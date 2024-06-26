//
//  BaseEvent.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

class BaseEvent: EventOptions, Codable {
    var eventType: String
    var eventProperties: [String: Any?]?
    var userProperties: [String: Any?]?

    enum CodingKeys: String, CodingKey {
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

    init(userId: String? = nil,
         deviceId: String? = nil,
         timestamp: Int64? = nil,
         eventId: Int64? = nil,
         sessionId: Int64? = nil,
         insertId: String? = nil,
         appVersion: String? = nil,
         platform: String? = nil,
         osName: String? = nil,
         osVersion: String? = nil,
         deviceBrand: String? = nil,
         deviceModel: String? = nil,
         country: String? = nil,
         city: String? = nil,
         language: String? = nil,
         ip: String? = nil,
         eventType: String,
         eventProperties: [String: Any?]? = nil,
         userProperties: [String: Any?]? = nil) {
        self.eventType = eventType
        self.eventProperties = eventProperties
        self.userProperties = userProperties
        super.init(userId: userId,
                   deviceId: deviceId,
                   time: timestamp,
                   sessionId: sessionId,
                   platform: platform,
                   osVersion: osVersion,
                   osName: osName,
                   language: language,
                   ip: ip,
                   insertId: insertId,
                   eventId: eventId,
                   deviceModel: deviceModel,
                   deviceBrand: deviceBrand,
                   country: country,
                   city: city,
                   appVersion: appVersion)
    }

    func isValid() -> Bool {
        return userId != nil || deviceId != nil
    }

    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        eventType = try values.decode(String.self, forKey: .eventType)
        eventProperties = try values.decodeIfPresent([String: Any].self, forKey: .eventProperties)
        userProperties = try values.decodeIfPresent([String: Any].self, forKey: .userProperties)
        super.init()
        userId = try values.decodeIfPresent(String.self, forKey: .userId)
        deviceId = try values.decodeIfPresent(String.self, forKey: .deviceId)
        time = try values.decodeIfPresent(Int64.self, forKey: .timestamp)
        eventId = try values.decodeIfPresent(Int64.self, forKey: .eventId)
        sessionId = try values.decodeIfPresent(Int64.self, forKey: .sessionId)
        insertId = try values.decodeIfPresent(String.self, forKey: .insertId)
        appVersion = try values.decodeIfPresent(String.self, forKey: .appVersion)
        platform = try values.decodeIfPresent(String.self, forKey: .platform)
        osName = try values.decodeIfPresent(String.self, forKey: .osName)
        osVersion = try values.decodeIfPresent(String.self, forKey: .osVersion)
        deviceBrand = try values.decodeIfPresent(String.self, forKey: .deviceBrand)
        deviceModel = try values.decodeIfPresent(String.self, forKey: .deviceModel)
        country = try values.decodeIfPresent(String.self, forKey: .country)
        city = try values.decodeIfPresent(String.self, forKey: .city)
        language = try values.decodeIfPresent(String.self, forKey: .language)
        ip = try values.decodeIfPresent(String.self, forKey: .ip)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(eventType, forKey: .eventType)
        try container.encodeIfPresent(eventProperties, forKey: .eventProperties)
        try container.encodeIfPresent(userProperties, forKey: .userProperties)
        try container.encodeIfPresent(userId, forKey: .userId)
        try container.encodeIfPresent(deviceId, forKey: .deviceId)
        try container.encodeIfPresent(time, forKey: .timestamp)
        try container.encodeIfPresent(eventId, forKey: .eventId)
        try container.encodeIfPresent(sessionId, forKey: .sessionId)
        try container.encodeIfPresent(insertId, forKey: .insertId)
        try container.encodeIfPresent(appVersion, forKey: .appVersion)
        try container.encodeIfPresent(platform, forKey: .platform)
        try container.encodeIfPresent(osName, forKey: .osName)
        try container.encodeIfPresent(osVersion, forKey: .osVersion)
        try container.encodeIfPresent(deviceBrand, forKey: .deviceBrand)
        try container.encodeIfPresent(deviceModel, forKey: .deviceModel)
        try container.encodeIfPresent(country, forKey: .country)
        try container.encodeIfPresent(city, forKey: .city)
        try container.encodeIfPresent(language, forKey: .language)
        try container.encodeIfPresent(ip, forKey: .ip)
    }
}
