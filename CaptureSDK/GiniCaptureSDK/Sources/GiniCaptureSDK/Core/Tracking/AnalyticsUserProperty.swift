//
//  AnalyticsUserProperty.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

public enum AnalyticsUserProperty: String {
    case entryPoint = "entry_point"
    case giniClientID = "gini_client_id"
    case isVoiceOverRunning = "is_voice_over_running"
    case isGuidedAccessEnabled = "is_guided_access_enabled"
    case isBoldTextEnabled = "is_bold_text_enabled"
    case isGrayscaleEnabled = "is_grayscale_enabled"
    case isSpeakSelectionEnabled = "is_speak_selection_enabled"
    case isSpeakScreenEnabled = "is_speak_screen_enabled"
    case isAssistiveTouchRunning = "is_assistive_touch_running"
    case returnReasonsEnabled = "return_reasons_enabled"
    case returnAssistantEnabled = "return_assistant_enabled"
}
