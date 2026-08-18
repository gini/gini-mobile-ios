//
//  PaymentHintState.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

/**
 The state of the payment-hint bottom sheet presented over the Analysis screen
 when the SDK detects a not-yet-due invoice.
 */
public enum PaymentHintState {

    /**
     Due Date Hint state — invoice is due in the future. Primary = proceed,
     secondary = cancel.
     */
    case dueDate(formattedDueDate: String,
                 onProceed: () -> Void,
                 onCancel: () -> Void)

    /**
     Schedule Payment state — client opted into `paymentScheduleHintEnabled`.
     Primary = hand off to the bank's scheduled-transfer flow, secondary =
     continue with the pay-now flow.
     */
    case schedulePayment(formattedDueDate: String,
                         onSchedule: () -> Void,
                         onProceed: () -> Void)
}
