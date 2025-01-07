//
//  GiniAnalyticsProperties.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

public struct GiniAnalyticsProperty {
    public let key: GiniAnalyticsPropertyKey
    public var value: GiniAnalyticsPropertyValue

    public init(key: GiniAnalyticsPropertyKey, value: GiniAnalyticsPropertyValue) {
        self.key = key
        self.value = value
    }
}

public protocol GiniAnalyticsPropertyValue {
    func analyticsPropertyValue() -> Self
}

extension String: GiniAnalyticsPropertyValue {
    public func analyticsPropertyValue() -> String {
        return self
    }
}

extension Int: GiniAnalyticsPropertyValue {
    public func analyticsPropertyValue() -> Int {
        return self
    }
}

extension Bool: GiniAnalyticsPropertyValue {
    public func analyticsPropertyValue() -> Bool {
        return self
    }
}

extension Array: GiniAnalyticsPropertyValue where Element == String {
    public func analyticsPropertyValue() -> [String] {
        return self
    }
}

public enum GiniAnalyticsPropertyKey: String {
    case screenName = "screen"

    case flashActive = "flash_active"
    case qrCodeValid = "qr_code_valid"
    case numberOfPagesScanned = "number_of_pages_scanned"
    case ibanDetectionLayerVisible = "iban_detection_layer_visible"

    case errorMessage = "error_message"
    case documentType = "document_type"
    case errorCode = "error_code"
    case errorType = "error_type"

    case hasCustomItems = "has_custom_items"
    case helpItems = "help_items"
    case itemTapped = "item_tapped"
    case customOnboardingTitle = "custom_onboarding_title"

    case itemsChanged = "items_changed"
    case switchActive = "switch_active"
    case permissionStatus = "permission_status"
    case status
}
