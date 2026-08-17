//
//  PaymentHintState.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

/**
 The state of the payment-hint bottom sheet presented over the Analysis screen
 when the SDK detects a not-yet-due invoice.

 Distinct CTAs per state are expressed via associated values instead of a common
 tuple with optional closures — the compiler enforces that only the CTAs the
 state actually needs are supplied by the caller.
 */
public enum PaymentHintState {

    /**
     Due Date Hint state — the invoice is due comfortably in the future. The
     user chooses between continuing (primary) and cancelling the transfer
     (secondary). Semantics unchanged from the original PP-3261 sheet.

     - Parameters:
       - formattedDueDate: The payment due date rendered for display in the
         sheet title (e.g. `"13.08.2026"`).
       - onProceed: Invoked when the user taps the primary CTA
         (`Proceed Anyway`).
       - onCancel: Invoked when the user taps the secondary CTA
         (`Cancel Transfer`).
     */
    case dueDate(formattedDueDate: String,
                 onProceed: () -> Void,
                 onCancel: () -> Void)

    /**
     Schedule Payment state — the client has opted into the schedule-payment
     feature (`paymentScheduleHintEnabled` on both `GiniBankConfiguration` and
     `ClientConfiguration`). The user chooses between handing off to the
     bank's own scheduled-transfer flow (primary) and continuing with the
     pay-now flow (secondary).

     - Parameters:
       - formattedDueDate: The payment due date rendered for display in the
         sheet title (e.g. `"13.08.2026"`).
       - onSchedule: Invoked when the user taps the primary CTA
         (`Schedule Payment`). Callers typically finish the capture flow by
         invoking `giniCaptureDidRequestSchedulePayment(result:)` on
         `GiniCaptureResultsDelegate`.
       - onProceed: Invoked when the user taps the secondary CTA
         (`Proceed Anyway`). Callers typically continue into the pay-now
         flow, identical to the Due Date Hint state's proceed handler.
     */
    case schedulePayment(formattedDueDate: String,
                         onSchedule: () -> Void,
                         onProceed: () -> Void)
}
