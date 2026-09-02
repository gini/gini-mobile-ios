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
public struct PaymentHintScreenAccessibilityIdentifiers {
    private init() {}

    public struct DueDate {
        private init() {}
        public static let container = "paymentHint.dueDate.container"
        public static let title = "paymentHint.dueDate.title"
        public static let description = "paymentHint.dueDate.description"
        public static let proceedButton = "paymentHint.dueDate.proceedButton"
        public static let cancelButton = "paymentHint.dueDate.cancelButton"
    }

    public struct Schedule {
        private init() {}
        public static let container = "paymentHint.schedule.container"
        public static let title = "paymentHint.schedule.title"
        public static let description = "paymentHint.schedule.description"
        public static let scheduleButton = "paymentHint.schedule.scheduleButton"
        public static let proceedButton = "paymentHint.schedule.proceedButton"
    }
}
