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

    public static func initializeAnalytics() {
        mixpanelInstance = Mixpanel.initialize(token: mixPanelToken, trackAutomaticEvents: false)

        // Identify the user with the deviceID
        let deviceID = UIDevice.current.identifierForVendor?.uuidString
        mixpanelInstance?.identify(distinctId: deviceID ?? "")
        trackAccessibilityUserPropertiesAtInitialization()
        // TODO: Where to check open_with
        trackUserProperties([.entryPoint: AnalyticsMapper.entryPointAnalytics(from: GiniConfiguration.shared.entryPoint)])
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

        var propertiesDict: [String: AnalyticsPropertyValue] = [:]
        for property in properties {
            propertiesDict[property.key.rawValue] = property.value.analyticsPropertyValue()
        }

        let convertedProperties = convertPropertiesToDict(propertiesDict)
        eventProperties.merge(convertedProperties) { (current, _) in current }

        mixpanelInstance?.track(event: event.rawValue, properties: eventProperties)
    }

    public static func trackUserProperties(_ properties: [AnalyticsUserProperty: AnalyticsPropertyValue]) {
        var propertiesDict: [String: AnalyticsPropertyValue] = [:]
        for (property, value) in properties {
            propertiesDict[property.rawValue] = value
        }

        let convertedProperties = convertPropertiesToDict(propertiesDict)
        mixpanelInstance?.people.set(properties: convertedProperties)
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

    private static func convertPropertiesToDict(_ properties: [String: AnalyticsPropertyValue]) -> [String: String] {
        var propertiesToTrack: [String: String] = [:]

        for (key, value) in properties {
            var propertyValueString = ""

            if let value = value as? Bool {
                propertyValueString = analyticsString(from: value)
            } else if let value = value as? String {
                propertyValueString = value
            } else if let value = value as? Int {
                propertyValueString = "\(value)"
            } else if let value = value as? [String] {
                propertyValueString = arrayToString(from: value)
            }

            propertiesToTrack[key] = propertyValueString
        }

        return propertiesToTrack
    }
}
