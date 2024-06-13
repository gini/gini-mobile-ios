//
//  AnalyticsManager.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import Mixpanel
import Amplitude

public class AnalyticsManager {
    private static var mixpanelInstance: MixpanelInstance?
    private static var userProperties: [AnalyticsUserProperty: AnalyticsPropertyValue] = [:]
    private static var superProperties: [AnalyticsSuperProperty: AnalyticsPropertyValue] = [:]
    private static var eventsQueue: [QueuedAnalyticsEvent] = []

    public static func initializeAnalytics(with configuration: AnalyticsConfiguration) {
        guard configuration.userJourneyAnalyticsEnabled,
              GiniTrackingPermissionManager.shared.trackingAuthorized() else { return }
        // Identify the user with the deviceID
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? ""
        initializeMixpanel(with: deviceID, token: configuration.mixpanelToken)
        initializeAmplitude(with: deviceID, apiKey: configuration.amplitudeApiKey)
        superProperties[.giniClientID] = configuration.clientID
        registerSuperProperties(superProperties)
        trackUserProperties(userProperties)
        trackAccessibilityUserPropertiesAtInitialization()
        AnalyticsManager.track(event: .sdkOpened, screenName: nil)
        processEventsQueue()
    }

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
        guard let mixpanelInstance else {
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

        mixpanelInstance.track(event: event.rawValue, properties: eventProperties)
        Amplitude.instance().logEvent(event.rawValue, withEventProperties: eventProperties)
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
                         mixpanelInstanceMethod: { mixpanelInstance, propertiesToTrack in
            mixpanelInstance.people.set(properties: propertiesToTrack)
        })
    }

    public static func registerSuperProperties(_ properties: [AnalyticsSuperProperty: AnalyticsPropertyValue]) {
        handleProperties(properties,
                         propertyStore: &superProperties,
                         mixpanelInstanceMethod: { mixpanelInstance, propertiesToTrack in
            mixpanelInstance.registerSuperProperties(propertiesToTrack)
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

    private static func handleProperties<T: RawRepresentable>(
        _ properties: [T: AnalyticsPropertyValue],
        propertyStore: inout [T: AnalyticsPropertyValue],
        mixpanelInstanceMethod: (MixpanelInstance, [String: String]) -> Void
    ) where T.RawValue == String {
        if let mixpanelInstance = mixpanelInstance {
            var propertiesToTrack: [String: String] = [:]
            for (property, value) in properties {
                propertiesToTrack[property.rawValue] = convertPropertyValueToString(value)
            }
            mixpanelInstanceMethod(mixpanelInstance, propertiesToTrack)
        } else {
            for (property, value) in properties {
                propertyStore[property] = value
            }
        }
    }
}
