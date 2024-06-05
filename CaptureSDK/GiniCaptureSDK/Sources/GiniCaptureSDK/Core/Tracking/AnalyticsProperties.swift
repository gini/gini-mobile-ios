//
//  AnalyticsProperties.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

public struct AnalyticsProperty {
    public let key: AnalyticsPropertyKey
    public var value: AnalyticsPropertyValue

    public init(key: AnalyticsPropertyKey, value: AnalyticsPropertyValue) {
        self.key = key
        self.value = value
    }
}

public protocol AnalyticsPropertyValue {
    func analyticsPropertyValue() -> Self
}

extension String: AnalyticsPropertyValue {
    public func analyticsPropertyValue() -> String {
        return self
    }
}

extension Int: AnalyticsPropertyValue {
    public func analyticsPropertyValue() -> Int {
        return self
    }
}

extension Bool: AnalyticsPropertyValue {
    public func analyticsPropertyValue() -> Bool {
        return self
    }
}

extension Array: AnalyticsPropertyValue where Element == String {
    public func analyticsPropertyValue() -> [String] {
        return self
    }
}

public enum AnalyticsPropertyKey: String {
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
    case documentId = "document_id"

    case itemsChanged = "items_changed"
    case switchActive = "switch_active"
    case permissionStatus = "permission_status"
}
