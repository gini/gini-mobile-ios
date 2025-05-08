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
    // Configuration flag
    @GiniCaptureUserDefault("ginicapture.defaults.client.configurations.qrCodeEducationEnabled",
                            defaultValue: nil)
    public static var qrCodeEducationEnabled: Bool?

    // Counts how many times the education message was shown in the invoice photo flow
    @GiniCaptureUserDefault("ginicapture.defaults.invoicephoto.messageDisplayCount",
                            defaultValue: 0)
    static var messageDisplayCount: Int

    @GiniCaptureUserDefault("ginicapture.defaults.onboardingShowed", defaultValue: false)
    public static var onboardingShowed: Bool
}
