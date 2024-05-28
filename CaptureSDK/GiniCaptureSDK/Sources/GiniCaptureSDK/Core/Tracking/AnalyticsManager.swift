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
    public static var userProperties: [AnalyticsUserProperty: AnalyticsPropertyValue] = [:]
    
    public static func initializeAnalytics() {
        mixpanelInstance = Mixpanel.initialize(token: mixPanelToken, trackAutomaticEvents: false)

        // Identify the user with the deviceID
        let deviceID = UIDevice.current.identifierForVendor?.uuidString
        mixpanelInstance?.identify(distinctId: deviceID ?? "")
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

    public static func track(event: AnalyticsEvent,
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
        var propertiesToTrack: [String: String] = [:]

        for (property, value) in properties {
            propertiesToTrack[property.rawValue] = convertPropertyValueToString(value)
        }

        mixpanelInstance?.people.set(properties: propertiesToTrack)
    }

    private static func trackAccessibilityUserPropertiesAtInitialization() {
        let accessibilityProperties: [AnalyticsUserProperty: AnalyticsPropertyValue] = [
            .isVoiceOverRunning: UIAccessibility.isVoiceOverRunning,
            .isGuidedAccessEnabled: UIAccessibility.isGuidedAccessEnabled,
            .isBoldTextEnabled: UIAccessibility.isBoldTextEnabled,
            .isGrayscaleEnabled: UIAccessibility.isGrayscaleEnabled,
            .isSpeakSelectionEnabled: UIAccessibility.isSpeakSelectionEnabled,
            .isSpeakScreenEnabled: UIAccessibility.isSpeakScreenEnabled,
            .isAssistiveTouchRunning: UIAccessibility.isAssistiveTouchRunning
        ]

        trackUserProperties(accessibilityProperties)
    }

    // MARK: - Helper methods
    private static func analyticsString(from original: Bool) -> String {
        guard original else { return "no" }

        return "yes"
    }

    private static func arrayToString(from original: [String]) -> String {
        var result = "["
        result += original.joined(separator: ", ")
        result += "]"
        return result
    }

    private static func convertPropertyValueToString(_ value: AnalyticsPropertyValue) -> String {
        if let value = value as? Bool {
            return analyticsString(from: value)
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
