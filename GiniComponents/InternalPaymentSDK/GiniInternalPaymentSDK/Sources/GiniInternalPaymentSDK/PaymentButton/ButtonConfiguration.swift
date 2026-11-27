//
//  ButtonConfiguration.swift
//  GiniInternalPaymentSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniUtilites

/**
 Backward-compatible re-export. `ButtonConfiguration` moved to GiniUtilites
 so one canonical button-config type is shared by CaptureSDK / BankSDK /
 InternalPaymentSDK / HealthSDK consumers. The field set is identical
 across all consumers; GiniUtilites' version adds `titleFont: UIFont?`
 (optional, defaults to `nil`) so payment-button call sites that pass a
 titleFont keep working.
 */
public typealias ButtonConfiguration = GiniUtilites.ButtonConfiguration
