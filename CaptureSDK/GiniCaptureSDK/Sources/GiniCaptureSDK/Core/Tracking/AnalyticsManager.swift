//
//  AnalyticsManager.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

public class AnalyticsManager {
    private static var amplitudeService: AmplitudeService? {
        didSet {
            handleAnalyticsSDKsInit()
        }
    }
    private static var userProperties: [AnalyticsUserProperty: AnalyticsPropertyValue] = [:]
    private static var amplitudeSuperPropertiesToTrack: [String: String] = [:]
    private static var amplitudeUserPropertiesToTrack: [String: String] = [:]
    private static var superProperties: [AnalyticsSuperProperty: AnalyticsPropertyValue] = [:]
    private static var sessionId: Int64 = 0

    public static func initializeAnalytics(with configuration: AnalyticsConfiguration) {
        guard configuration.userJourneyAnalyticsEnabled,
              GiniTrackingPermissionManager.shared.trackingAuthorized() else { return }
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? ""
        superProperties[.giniClientID] = configuration.clientID
        initializeAmplitude(with: deviceID, apiKey: configuration.amplitudeApiKey)

        AnalyticsManager.track(event: .sdkOpened, screenName: nil)
        sessionId = AnalyticsSessionManager.shared.sessionId
    }

    public static func cleanManager() {
        userProperties = [:]
        superProperties = [:]
        sessionId = 0
    }

    // MARK: Initialization

    private static func initializeAmplitude(with deviceID: String, apiKey: String?) {
        guard let apiKey else { return }
        amplitudeService = AmplitudeService(apiKey: apiKey)
    }

    private static func handleAnalyticsSDKsInit() {
        guard amplitudeService != nil else { return }
        registerSuperProperties(superProperties)
        trackUserProperties(userProperties)
        trackAccessibilityUserPropertiesAtInitialization()
    }

    // MARK: - Track screen shown
    public static func trackScreenShown(screenName: AnalyticsScreen,
                                        properties: [AnalyticsProperty] = []) {
        track(event: AnalyticsEvent.screenShown,
              screenName: screenName,
              properties: properties)
    }

    static func trackScreenShown(screenNameString: String,
                                 properties: [AnalyticsProperty] = []) {
        track(event: AnalyticsEvent.screenShown,
              screenNameString: screenNameString,
              properties: properties)
    }

    // MARK: - Track event on screen
    public static func track(event: AnalyticsEvent,
                             screenName: AnalyticsScreen? = nil,
                             properties: [AnalyticsProperty] = []) {
        track(event: event,
              screenNameString: screenName?.rawValue,
              properties: properties)
    }

    static func track(event: AnalyticsEvent,
                      screenNameString: String? = nil,
                      properties: [AnalyticsProperty] = []) {
        if amplitudeService != nil {
            var eventProperties = properties.reduce(into: [String: String]()) {
                $0[$1.key.rawValue] = convertPropertyValueToString($1.value.analyticsPropertyValue())
            }
            if let screenName = screenNameString {
                eventProperties[AnalyticsPropertyKey.screenName.rawValue] = screenName
            }
            amplitudeTrackEvent(event: event, eventProperties: eventProperties)
        }
    }

    private static func logAmplitudeEvent(userID: String,
                                          eventType: String,
                                          eventProperties: [String: Any],
                                          options: EventOptions? = nil) {
        let event = BaseEvent(eventType: eventType)
        event.eventProperties = eventProperties
        event.userProperties = mapProperties(userProperties)
        let iosSystem = IOSSystem()
        let eventId = AnalyticsSessionManager.shared.incrementEventId()
        let eventOptions = EventOptions(userId: userID,
                                        deviceId: iosSystem.identifierForVendor,
                                        time: Date.berlinTimestamp(),
                                        sessionId: sessionId,
                                        platform: iosSystem.platform,
                                        osVersion: iosSystem.osVersion,
                                        osName: iosSystem.osName,
                                        language: iosSystem.systemLanguage,
                                        ip: "$remote",
                                        insertId: UUID().uuidString,
                                        eventId: eventId,
                                        deviceModel: iosSystem.model,
                                        deviceBrand: iosSystem.manufacturer,
                                        country: "",
                                        city: "",
                                        appVersion: GiniCapture.versionString)
        event.mergeEventOptions(eventOptions: eventOptions)
        amplitudeService?.trackEvent(event)
    }

    private static func amplitudeTrackEvent(event: AnalyticsEvent, eventProperties: [String: Any]) {
        let amplitudeProperties = eventProperties.merging(amplitudeSuperPropertiesToTrack) { (_, new) in new }
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? ""
        logAmplitudeEvent(userID: deviceID, eventType: event.rawValue, eventProperties: amplitudeProperties)
    }

    public static func trackUserProperties(_ properties: [AnalyticsUserProperty: AnalyticsPropertyValue]) {
        handleProperties(properties, propertyStore: &userProperties) {
            amplitudeUserPropertiesToTrack = $0
        }
    }

    public static func registerSuperProperties(_ properties: [AnalyticsSuperProperty: AnalyticsPropertyValue]) {
        handleProperties(properties, propertyStore: &superProperties) {
            amplitudeSuperPropertiesToTrack = $0
        }
    }

    private static func trackAccessibilityUserPropertiesAtInitialization() {
        let accessibilityProperties: [AnalyticsUserProperty: AnalyticsPropertyValue] = [
            .voiceOverEnabled: UIAccessibility.isVoiceOverRunning,
            .guidedAccessEnabled: UIAccessibility.isGuidedAccessEnabled,
            .boldTextEnabled: UIAccessibility.isBoldTextEnabled,
            .grayscaleEnabled: UIAccessibility.isGrayscaleEnabled,
            .speakSelectionEnabled: UIAccessibility.isSpeakSelectionEnabled,
            .speakScreenEnabled: UIAccessibility.isSpeakScreenEnabled,
            .assistiveTouchEnabled: UIAccessibility.isAssistiveTouchRunning
        ]
        trackUserProperties(accessibilityProperties)
    }

    // MARK: - Helper methods
    private static func boolToString(from original: Bool) -> String {
        return original ? "yes" : "no"
    }

    private static func arrayToString(from original: [String]) -> String {
        return "[\(original.map { "\"\($0)\"" }.joined(separator: ", "))]"
    }

    private static func convertPropertyValueToString(_ value: AnalyticsPropertyValue) -> String {
        switch value {
            case let value as Bool:
                return boolToString(from: value)
            case let value as String:
                return value
            case let value as Int:
                return "\(value)"
            case let value as [String]:
                return arrayToString(from: value)
            default:
                return ""
        }
    }

    private static func handleProperties<T: RawRepresentable>(_ properties: [T: AnalyticsPropertyValue],
                                                              propertyStore: inout [T: AnalyticsPropertyValue],
                                                              propertiesHandler: ([String: String]) -> Void)
    where T.RawValue == String {
        if amplitudeService != nil {
            let propertiesToTrack = mapProperties(properties)
            propertiesHandler(propertiesToTrack)
        } else {
            propertyStore.merge(properties) { (_, new) in new }
        }
    }

    private static func mapProperties<T: RawRepresentable>(_ properties: [T: AnalyticsPropertyValue]) -> [String: String]
    where T.RawValue == String {
        return properties.reduce(into: [String: String]()) { dict, pair in
            dict[pair.key.rawValue] = convertPropertyValueToString(pair.value)
        }
    }
}
