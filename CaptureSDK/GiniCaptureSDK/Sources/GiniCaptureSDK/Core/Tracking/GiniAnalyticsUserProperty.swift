//
//  GiniAnalyticsUserProperty.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

public enum GiniAnalyticsUserProperty: String {
    case voiceOverEnabled = "voice_over_enabled"
    case guidedAccessEnabled = "guided_access_enabled"
    case boldTextEnabled = "bold_text_enabled"
    case grayscaleEnabled = "grayscale_enabled"
    case speakSelectionEnabled = "speak_selection_enabled"
    case speakScreenEnabled = "speak_screen_enabled"
    case assistiveTouchEnabled = "assistive_touch_enabled"
    case returnReasonsEnabled = "return_reasons_enabled"
    case returnAssistantEnabled = "return_assistant_enabled"
    case bankSDKVersion = "bank_sdk_version"
    case captureSDKVersion = "capture_sdk_version"
    case instantPaymentEnabled = "instant_payment_enabled"
}
