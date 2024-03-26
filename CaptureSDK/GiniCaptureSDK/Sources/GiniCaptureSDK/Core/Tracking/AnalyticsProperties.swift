//
//  AnalyticsProperties.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
struct AnalyticsProperty {
    let key: AnalyticsPropertyKey
    var value: AnalyticsPropertyValue
}

protocol AnalyticsPropertyValue {
    func analyticsPropertyValue() -> Self
}

extension String: AnalyticsPropertyValue {
    func analyticsPropertyValue() -> String {
        return self
    }
}

extension Int: AnalyticsPropertyValue {
    func analyticsPropertyValue() -> Int {
        return self
    }
}

extension UInt: AnalyticsPropertyValue {
    func analyticsPropertyValue() -> UInt {
        return self
    }
}

extension Bool: AnalyticsPropertyValue {
    func analyticsPropertyValue() -> Bool {
        return self
    }
}

extension Double: AnalyticsPropertyValue {
    func analyticsPropertyValue() -> Double {
        return self
    }
}

enum AnalyticsPropertyKey: String {
    case screenName = "screen_name"
}
