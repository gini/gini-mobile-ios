//
//  AnalyticsScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

public enum AnalyticsScreen: String {
    case none
    case camera
    case review
    case analysis
    case noResults = "no_results"
    case error
    case help
    case onboardingFlatPaper = "onboarding_flat_paper"
    case onboardingLighting = "onboarding_lighting"
    case onboardingMultipage = "onboarding_multiple_pages"
    case onboardingQRcode = "onboarding_qr_code"
    case onboardingCustom = "onboarding_custom_" // e.g: onboarding_custom_1, onboarding_custom_2
    case onboardingDigitalInvoice = "onboarding_digital_invoice"
    case digitalInvoice = "digital_invoice"
    case editDigitalInvoice = "edit_digital_invoice"
    case cameraPermissionView = "camera_permission_view"
    case cameraAccess = "camera_access"
}
