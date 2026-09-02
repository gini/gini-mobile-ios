//
//  PaymentHintScreenAccessibilityIdentifiers.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

/**
 Accessibility identifiers exposed by
 `PaymentHintBottomSheetViewController` in `GiniCaptureSDK`. Values must
 stay byte-identical to the SDK's
 `PaymentHintBottomSheetViewController.AccessibilityIdentifiers` struct
 (`CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Core/Screens/PaymentHint/PaymentHintBottomSheetViewController.swift`)
 — duplication is intentional because the UITest target cannot import
 the SDK.
 */
struct PaymentHintScreenAccessibilityIdentifiers {
    struct DueDate {
        static let container = "paymentHint.dueDate.container"
        static let title = "paymentHint.dueDate.title"
        static let description = "paymentHint.dueDate.description"
        static let proceedButton = "paymentHint.dueDate.proceedButton"
        static let cancelButton = "paymentHint.dueDate.cancelButton"
    }

    struct Schedule {
        static let container = "paymentHint.schedule.container"
        static let title = "paymentHint.schedule.title"
        static let description = "paymentHint.schedule.description"
        static let scheduleButton = "paymentHint.schedule.scheduleButton"
        static let proceedButton = "paymentHint.schedule.proceedButton"
    }
}
