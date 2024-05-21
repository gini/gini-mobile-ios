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

    case flashActive = "flash_active"
    case qrCodeValid = "qr_code_valid"
    case numberOfPagesScanned = "number_of_pages_scanned"
    case ibanDetectionLayerVisible = "iban_detection_layer_visible"

    case errorMessage = "error_message"
    case documentType = "document_type"
}
