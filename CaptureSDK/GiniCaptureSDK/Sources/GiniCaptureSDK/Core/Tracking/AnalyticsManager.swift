//
//  AnalyticsManager.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import Mixpanel

class AnalyticsManager {
    private static let mixPanelToken = "fec4cd2a3fdf4ca9d7e3f377ef7f6746"
    static var mixpanelInstance: MixpanelInstance?

    static var adjustProperties: [AnalyticsProperty]?

    static func initializeAnalytics() {
        mixpanelInstance = Mixpanel.initialize(token: mixPanelToken, trackAutomaticEvents: false)

        // Identify the user with the deviceID
        let deviceID = UIDevice.current.identifierForVendor?.uuidString
        mixpanelInstance?.identify(distinctId: deviceID ?? "")
    }

    static func trackScreenShown(screenName: AnalyticsScreen,
                                 properties: [AnalyticsProperty] = []) {
        track(event: AnalyticsEvent.screenShown,
              screenName: screenName,
              properties: properties)
    }

    static func track(event: AnalyticsEvent,
                      screenName: AnalyticsScreen? = nil,
                      properties: [AnalyticsProperty] = []) {
        var eventProperties: [String: String] = [:]

        if let screenName = screenName {
            eventProperties[AnalyticsPropertyKey.screenName.rawValue] = screenName.rawValue
        }

        for property in properties {
            let propertyValue = property.value.analyticsPropertyValue()
            if let propertyValue = propertyValue as? Bool {
                eventProperties[property.key.rawValue] = analyticsString(from: propertyValue)
            }

            if let propertyValue = propertyValue as? String {
                eventProperties[property.key.rawValue] = propertyValue
            }

            if let propertyValue = propertyValue as? Int {
                eventProperties[property.key.rawValue] = "\(propertyValue)"
            }
        }

        mixpanelInstance?.track(event: event.rawValue, properties: eventProperties)
    }

    private static func analyticsString(from original: Bool) -> String {
        guard original else { return "no" }

        return "yes"
    }
}
