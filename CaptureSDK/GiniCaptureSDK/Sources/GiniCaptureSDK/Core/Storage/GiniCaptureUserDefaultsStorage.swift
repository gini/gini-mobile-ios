//
//  GiniCaptureUserDefaultsStorage.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import Foundation
import GiniUtilites
/**
 This is for internal use only.
 A struct that manages user defaults for Gini Capture configurations.
 */
public struct GiniCaptureUserDefaultsStorage {
    @GiniUserDefault("ginicapture.defaults.onboardingShowed", defaultValue: false)
    public static var onboardingShowed: Bool
    
    // Configuration flag for the QR code education message
    @GiniUserDefault("ginicapture.defaults.clientConfigurations.qrCodeEducationEnabled",
                     defaultValue: nil)
    public static var qrCodeEducationEnabled: Bool?
    
    // Configuration flag for the E-Invoice flow
    @GiniUserDefault("ginicapture.defaults.clientConfigurations.eInvoiceEnabled",
                     defaultValue: nil)
    public static var eInvoiceEnabled: Bool?
    
    // Counts how many times the education message was shown in the invoice photo flow
    @GiniUserDefault("ginicapture.defaults.captureInvoice.educationMessageDisplayCount",
                     defaultValue: 0)
    static var captureInvoiceEducationMessageDisplayCount: Int
    
    // Counts how many times the education message was shown in the QR code flow
    @GiniUserDefault("ginicapture.defaults.qrCode.educationMessageDisplayCount",
                     defaultValue: 0)
    static var qrCodeEducationMessageDisplayCount: Int
}
