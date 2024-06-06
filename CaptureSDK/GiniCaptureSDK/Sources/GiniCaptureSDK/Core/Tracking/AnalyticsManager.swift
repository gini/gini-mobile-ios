//
//  AnalyticsManager.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import Mixpanel

public class AnalyticsManager {
    private static let mixPanelToken = "6262hhdfhdb929321222" // this id is fake we need to replace it
    private static var mixpanelInstance: MixpanelInstance?
    private static var userProperties: [AnalyticsUserProperty: AnalyticsPropertyValue] = [:]
    private static var superProperties: [AnalyticsSuperProperty: AnalyticsPropertyValue] = [:]

    public static func initializeAnalytics() {
        mixpanelInstance = Mixpanel.initialize(token: mixPanelToken,
                                               trackAutomaticEvents: false,
                                               serverURL: "https://api-eu.mixpanel.com")

        // Identify the user with the deviceID
        let deviceID = UIDevice.current.identifierForVendor?.uuidString
        mixpanelInstance?.identify(distinctId: deviceID ?? "")
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
        var eventProperties: [String: String] = [:]

        if let screenName = screenNameString {
            eventProperties[AnalyticsPropertyKey.screenName.rawValue] = screenName
        }

        for property in properties {
            let propertyValue = property.value.analyticsPropertyValue()
            eventProperties[property.key.rawValue] = convertPropertyValueToString(propertyValue)
        }

        mixpanelInstance?.track(event: event.rawValue, properties: eventProperties)
    }

    public static func trackUserProperties(_ properties: [AnalyticsUserProperty: AnalyticsPropertyValue]) {
        if mixpanelInstance != nil {
            var propertiesToTrack: [String: String] = [:]

            for (property, value) in properties {
                propertiesToTrack[property.rawValue] = convertPropertyValueToString(value)
            }

            mixpanelInstance?.people.set(properties: propertiesToTrack)
        } else {
            for (property, value) in properties {
                userProperties[property] = value
            }
        }
    }

    public static func registerSuperProperties(_ properties: [AnalyticsSuperProperty: AnalyticsPropertyValue]) {
        if mixpanelInstance != nil {
            var superProperties: [String: String] = [:]

            for (property, value) in properties {
                superProperties[property.rawValue] = convertPropertyValueToString(value)
            }

            mixpanelInstance?.registerSuperProperties(superProperties)
        } else {
            for (property, value) in properties {
                superProperties[property] = value
            }
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
}
