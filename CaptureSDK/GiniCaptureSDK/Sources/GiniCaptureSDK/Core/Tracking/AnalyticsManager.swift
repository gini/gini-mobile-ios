//
//  AnalyticsManager.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import Mixpanel
import Amplitude

public class AnalyticsManager {
    private static var mixpanelInstance: MixpanelInstance? {
        didSet {
            handleAnalyticsSDKsInit()
        }
    }
    private static var amplitudeInitialised: Bool = false {
        didSet {
            handleAnalyticsSDKsInit()
        }
    }
    private static var userProperties: [AnalyticsUserProperty: AnalyticsPropertyValue] = [:]
    private static var eventsQueue: [QueuedAnalyticsEvent] = []
    private static var amplitudeSuperPropertiesToTrack: [String: String] = [:]
    public static var superProperties: [AnalyticsSuperProperty: AnalyticsPropertyValue] = [:]

    public static func initializeAnalytics(with configuration: AnalyticsConfiguration) {
        guard configuration.userJourneyAnalyticsEnabled,
              GiniTrackingPermissionManager.shared.trackingAuthorized() else { return }
        // Identify the user with the deviceID
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? ""
        superProperties[.giniClientID] = configuration.clientID
        initializeMixpanel(with: deviceID, token: configuration.mixpanelToken)
        initializeAmplitude(with: deviceID, apiKey: configuration.amplitudeApiKey)
    }

    /// Cleans up the Analytics manager by resetting its properties and events queue.
    public static func cleanManager() {
        userProperties = [:]
        superProperties = [:]
        eventsQueue = []
        mixpanelInstance = nil
    }

    // MARK: Initialization
    private static func initializeMixpanel(with deviceID: String, token: String?) {
        guard let token else { return }
        mixpanelInstance = Mixpanel.initialize(token: token,
                                               trackAutomaticEvents: false,
                                               serverURL: "https://api-eu.mixpanel.com")
        mixpanelInstance?.identify(distinctId: deviceID)
    }

    private static func initializeAmplitude(with deviceID: String, apiKey: String?) {
        guard let apiKey else { return }
        Amplitude.instance().initializeApiKey(apiKey)
        Amplitude.instance().setDeviceId(deviceID)
        Amplitude.instance().initCompletionBlock = {
            self.amplitudeInitialised = true
        }
    }

    private static func handleAnalyticsSDKsInit() {
        guard mixpanelInstance != nil, amplitudeInitialised else { return }
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
        guard let mixpanelInstance, amplitudeInitialised else {
            let queuedEvent = QueuedAnalyticsEvent(event: event,
                                                   screenNameString: screenNameString,
                                                   properties: properties)
            eventsQueue.append(queuedEvent)
            return
        }

        var eventProperties: [String: String] = [:]

        if let screenName = screenNameString {
            eventProperties[AnalyticsPropertyKey.screenName.rawValue] = screenName
        }

        for property in properties {
            let propertyValue = property.value.analyticsPropertyValue()
            eventProperties[property.key.rawValue] = convertPropertyValueToString(propertyValue)
        }

        // Track event in Mixpanel
        mixpanelInstance.track(event: event.rawValue, properties: eventProperties)

        // Track event in Ampltitude
        ampltitudeTackEvent(event: event, eventProperties: eventProperties)
    }

    /// This function logs an event in Amplitude analytics with the specified event properties.
    private static func ampltitudeTackEvent(event: AnalyticsEvent, eventProperties: [String: Any]) {
        // Merges the provided event properties with the super properties because Amplitude does not offer 
        // a dedicated method for this purpose.

        // Merge event properties with super properties. In case of key collisions, values from eventProperties will be used.
        let amplitudeProperties = eventProperties.merging(amplitudeSuperPropertiesToTrack) { (_, new) in new }

        // Log the event with Amplitude instance
        Amplitude.instance().logEvent(event.rawValue, withEventProperties: amplitudeProperties)
    }

    private static func processEventsQueue() {
        while !eventsQueue.isEmpty {
            let queuedEvent = eventsQueue.removeFirst()
            track(event: queuedEvent.event,
                  screenNameString: queuedEvent.screenNameString,
                  properties: queuedEvent.properties)
        }
    }

    public static func trackUserProperties(_ properties: [AnalyticsUserProperty: AnalyticsPropertyValue]) {
        handleProperties(properties,
                         propertyStore: &userProperties,
                         propertiesHandler: { propertiesToTrack in
            mixpanelInstance?.people.set(properties: propertiesToTrack)
            Amplitude.instance().setUserProperties(propertiesToTrack)
        })
    }

    public static func registerSuperProperties(_ properties: [AnalyticsSuperProperty: AnalyticsPropertyValue]) {
        handleProperties(properties,
                         propertyStore: &superProperties,
                         propertiesHandler: { propertiesToTrack in
            mixpanelInstance?.registerSuperProperties(propertiesToTrack)
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
        if mixpanelInstance != nil, amplitudeInitialised {
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
