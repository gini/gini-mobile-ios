//
//  AnalyticsScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

public enum GiniAnalyticsScreen: String {
    case camera
    case review
    case reviewZoom = "review_zoom"
    case analysis
    case noResults = "no_results"
    case error
    case help
    case onboardingFlatPaper = "onboarding_flat_paper"
    case onboardingLighting = "onboarding_lighting"
    case onboardingMultipage = "onboarding_multiple_pages"
    case onboardingQRcode = "onboarding_qr_code"
    case onboardingCustom = "onboarding_custom_" // e.g: onboarding_custom_1, onboarding_custom_2
    case onboardingReturnAssistant = "onboarding_return_assistant"
    case returnAssistant = "return_assistant"
    case editReturnAssistant = "edit_return_assistant"
    case cameraPermissionView = "camera_permission_view"
    case cameraAccess = "camera_access"
    case skonto
    case returnAssistantSkonto = "return_assistant_skonto"
    case skontoInvoicePreview = "skonto_invoice_preview"
    case skontoInvoicePreviewError = "skonto_invoice_preview_error"
}
