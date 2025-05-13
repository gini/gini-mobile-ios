//
//  GiniCaptureUserDefaultsStorage.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import Foundation
import GiniBankAPILibrary

/**
    This is for internal use only.
    A struct that manages user defaults for Gini Capture configurations.
 */
public struct GiniCaptureUserDefaultsStorage {
    @GiniCaptureUserDefault("ginicapture.defaults.onboardingShowed", defaultValue: false)
    public static var onboardingShowed: Bool

    // Configuration flag for the QR code education message
    @GiniCaptureUserDefault("ginicapture.defaults.clientConfigurations.qrCodeEducationEnabled",
                            defaultValue: nil)
    public static var qrCodeEducationEnabled: Bool?

    // Counts how many times the education message was shown in the invoice photo flow
    @GiniCaptureUserDefault("ginicapture.defaults.captureInvoice.educationMessageDisplayCount",
                            defaultValue: 0)
    static var captureInvoiceEducationMessageDisplayCount: Int
    
    // Counts how many times the education message was shown in the QR code flow
    @GiniCaptureUserDefault("ginicapture.defaults.qrCode.educationMessageDisplayCount",
                            defaultValue: 0)
    static var qrCodeEducationMessageDisplayCount: Int
}
