//
//  AnalyticsManager.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
public class AnalyticsManager {
    private static var amplitudeInitialised: Bool = false {
        didSet {
            handleAnalyticsSDKsInit()
        }
    }
    private static var userProperties: [AnalyticsUserProperty: AnalyticsPropertyValue] = [:]
    private static var eventsQueue: [QueuedAnalyticsEvent] = []
    private static var amplitudeSuperPropertiesToTrack: [String: String] = [:]
    private static var superProperties: [AnalyticsSuperProperty: AnalyticsPropertyValue] = [:]

    public static func initializeAnalytics(with configuration: AnalyticsConfiguration) {
        guard configuration.userJourneyAnalyticsEnabled,
              GiniTrackingPermissionManager.shared.trackingAuthorized() else { return }
        // Identify the user with the deviceID
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? ""
        superProperties[.giniClientID] = configuration.clientID
        initializeAmplitude(with: deviceID, apiKey: configuration.amplitudeApiKey)

        AnalyticsManager.track(event: .sdkOpened, screenName: nil)
    }

    /// Cleans up the Analytics manager by resetting its properties and events queue.
    public static func cleanManager() {
        userProperties = [:]
        superProperties = [:]
        eventsQueue = []
    }

    // MARK: Initialization

    private static func initializeAmplitude(with deviceID: String, apiKey: String?) {
        guard let apiKey else { return }
        Amplitude.instance().initializeApiKey(apiKey)
        Amplitude.instance().setServerUrl("https://api.eu.amplitude.com")
        Amplitude.instance().setDeviceId(deviceID)
        Amplitude.instance().initCompletionBlock = {
            self.amplitudeInitialised = true
        }
    }

    private static func handleAnalyticsSDKsInit() {
        guard amplitudeInitialised else { return }
        registerSuperProperties(superProperties)
        trackUserProperties(userProperties)
        trackAccessibilityUserPropertiesAtInitialization()
        processEventsQueue()
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
        let queuedEvent = QueuedAnalyticsEvent(event: event,
                                               screenNameString: screenNameString,
                                               properties: properties)
        eventsQueue.append(queuedEvent)

        // Process the event queue if SDKs are initialized
        if amplitudeInitialised {
            processEventsQueue()
        }
    }

    /// This function logs an event in Amplitude analytics with the specified event properties.
    private static func amplitudeTrackEvent(event: AnalyticsEvent, eventProperties: [String: Any]) {
        // Merges the provided event properties with the super properties because Amplitude does not offer
        // a dedicated method for this purpose.

        // Merge event properties with super properties. In case of key collisions, values from eventProperties will be used.
        let amplitudeProperties = eventProperties.merging(amplitudeSuperPropertiesToTrack) { (_, new) in new }

        // Log the event with Amplitude instance
        Amplitude.instance().logEvent(event.rawValue, withEventProperties: amplitudeProperties)
    }

    /// Processes the events queue by sending each queued event to Mixpanel and Amplitude
    private static func processEventsQueue() {
        while !eventsQueue.isEmpty {
            let queuedEvent = eventsQueue.removeFirst()
            track(event: queuedEvent)
        }
    }

    /// Tracks a queued analytics event
    private static func track(event: QueuedAnalyticsEvent) {
        var eventProperties: [String: String] = [:]

        if let screenName = event.screenNameString {
            eventProperties[AnalyticsPropertyKey.screenName.rawValue] = screenName
        }

        for property in event.properties {
            let propertyValue = property.value.analyticsPropertyValue()
            eventProperties[property.key.rawValue] = convertPropertyValueToString(propertyValue)
        }

        // Track event in Amplitude
        amplitudeTrackEvent(event: event.event, eventProperties: eventProperties)
    }

    public static func trackUserProperties(_ properties: [AnalyticsUserProperty: AnalyticsPropertyValue]) {
        handleProperties(properties,
                         propertyStore: &userProperties,
                         propertiesHandler: { propertiesToTrack in
            Amplitude.instance().setUserProperties(propertiesToTrack)
        })
    }

    public static func registerSuperProperties(_ properties: [AnalyticsSuperProperty: AnalyticsPropertyValue]) {
        handleProperties(properties,
                         propertyStore: &superProperties,
                         propertiesHandler: { propertiesToTrack in
            amplitudeSuperPropertiesToTrack = mapAmplitudeSuperProperties(properties: properties)
        })
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
        var result = "["
        result += original.map { "\"\($0)\"" }.joined(separator: ", ")
        result += "]"
        return result
    }

    private static func convertPropertyValueToString(_ value: AnalyticsPropertyValue) -> String {
        if let value = value as? Bool {
            return boolToString(from: value)
        } else if let value = value as? String {
            return value
        } else if let value = value as? Int {
            return "\(value)"
        } else if let value = value as? [String] {
            return arrayToString(from: value)
        } else {
            return ""
        }
    }

    private static func handleProperties<T: RawRepresentable>(_ properties: [T: AnalyticsPropertyValue],
                                                              propertyStore: inout [T: AnalyticsPropertyValue],
                                                              propertiesHandler: ([String: String]) -> Void)
    where T.RawValue == String {
        if amplitudeInitialised {
            var propertiesToTrack: [String: String] = [:]
            for (property, value) in properties {
                propertiesToTrack[property.rawValue] = convertPropertyValueToString(value)
            }
            propertiesHandler(propertiesToTrack)
        } else {
            for (property, value) in properties {
                propertyStore[property] = value
            }
        }
    }

    private static func mapAmplitudeSuperProperties(properties: [AnalyticsSuperProperty: AnalyticsPropertyValue])
    -> [String: String] {
        return properties
            .map { (key, value) in
                (key.rawValue, convertPropertyValueToString(value))
            }
            .reduce(into: [String: String]()) { (dict, pair) in
                dict[pair.0] = pair.1
            }
    }
}
