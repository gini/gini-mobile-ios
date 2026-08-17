//
//  PaymentHintBottomSheetViewController.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit

private struct DueDateContent: InfoBottomSheetViewModel {
    var image: UIImage? = UIImageNamedPreferred(named: "infoMessageIcon")
    var imageTintColor: UIColor? = GiniColor(light: .GiniCapture.warning2,
                                             dark: .GiniCapture.warning2).uiColor()
    let title: String
    var description: String = PaymentHintBottomSheetViewController.Strings.dueDateDescription
}

private struct ScheduleContent: InfoBottomSheetViewModel {
    var image: UIImage? = UIImageNamedPreferred(named: "infoMessageIcon")
    var imageTintColor: UIColor? = GiniColor(light: .GiniCapture.warning2,
                                             dark: .GiniCapture.warning2).uiColor()
    let title: String
    var description: String = PaymentHintBottomSheetViewController.Strings.scheduleDescription
}

/**
 A specialized bottom sheet that informs the user their invoice is due
 comfortably in the future and offers state-specific CTAs.

 Two mutually exclusive states are supported (see `PaymentHintState`):
 - `.dueDate` — primary `Proceed Anyway`, secondary `Cancel Transfer`.
 - `.schedulePayment` — primary `Schedule Payment`, secondary
   `Proceed Anyway`.

 Present it over the Analysis screen when
 `Date.isDueSoon(within: paymentDueHintThresholdDays)` returns `true` for
 the extracted due date. The state is selected by the coordinator based on
 `paymentScheduleHintEnabled` on both `GiniBankConfiguration` and
 `ClientConfiguration`.
 */
public final class PaymentHintBottomSheetViewController: InfoBottomSheetViewController {

    /**
     Creates a payment-hint bottom sheet for the given state. The state's
     associated values drive title interpolation, description copy, and both
     CTA closures.
     - Parameter state: The state the sheet should render.
     */
    public init(state: PaymentHintState) {
        let contentViewModel: InfoBottomSheetViewModel
        let buttonsViewModel: InfoBottomSheetButtonsViewModel

        switch state {
        case let .dueDate(formattedDueDate, onProceed, onCancel):
            let title = String(format: Strings.titleFormat, formattedDueDate)
            contentViewModel = DueDateContent(title: title)

            /// Figma: "Proceed Anyway" is the primary CTA for the Due Date state.
            let primary = InfoBottomSheetButtonsViewModel.Button(title: Strings.dueDateProceedButton,
                                                                 action: onProceed)
            let secondary = InfoBottomSheetButtonsViewModel.Button(title: Strings.dueDateCancelButton,
                                                                   action: onCancel)
            buttonsViewModel = InfoBottomSheetButtonsViewModel(primary, secondary)

        case let .schedulePayment(formattedDueDate, onSchedule, onProceed):
            let title = String(format: Strings.titleFormat, formattedDueDate)
            contentViewModel = ScheduleContent(title: title)

            /// Figma: "Schedule Payment" is the primary CTA for the Schedule state.
            let primary = InfoBottomSheetButtonsViewModel.Button(title: Strings.scheduleButton,
                                                                 action: onSchedule)
            let secondary = InfoBottomSheetButtonsViewModel.Button(title: Strings.scheduleProceedButton,
                                                                   action: onProceed)
            buttonsViewModel = InfoBottomSheetButtonsViewModel(primary, secondary)
        }

        super.init(viewModel: contentViewModel, buttonsViewModel: buttonsViewModel)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PaymentHintBottomSheetViewController {
    struct Strings {
        static let titleFormatKey = "ginicapture.payment.hint.title"
        static let titleFormatComment = "Payment hint bottom sheet title format (single %@ placeholder for the formatted date; shared across both states)"
        static let titleFormat = NSLocalizedStringPreferredFormat(titleFormatKey,
                                                                  comment: titleFormatComment)

        static let dueDateDescriptionKey = "ginicapture.payment.hint.duedate.description"
        static let dueDateDescriptionComment = "Payment hint bottom sheet description — Due Date state"
        static let dueDateDescription = NSLocalizedStringPreferredFormat(dueDateDescriptionKey,
                                                                         comment: dueDateDescriptionComment)

        static let dueDateProceedButtonKey = "ginicapture.payment.hint.duedate.proceedButtonTitle"
        static let dueDateProceedButtonComment = "Payment hint bottom sheet primary CTA — Due Date state (proceed with the transfer)"
        static let dueDateProceedButton = NSLocalizedStringPreferredFormat(dueDateProceedButtonKey,
                                                                           comment: dueDateProceedButtonComment)

        static let dueDateCancelButtonKey = "ginicapture.payment.hint.duedate.cancelButtonTitle"
        static let dueDateCancelButtonComment = "Payment hint bottom sheet secondary CTA — Due Date state (cancel the transfer)"
        static let dueDateCancelButton = NSLocalizedStringPreferredFormat(dueDateCancelButtonKey,
                                                                          comment: dueDateCancelButtonComment)

        static let scheduleDescriptionKey = "ginicapture.payment.hint.schedule.description"
        static let scheduleDescriptionComment = "Payment hint bottom sheet description — Schedule Payment state"
        static let scheduleDescription = NSLocalizedStringPreferredFormat(scheduleDescriptionKey,
                                                                          comment: scheduleDescriptionComment)

        static let scheduleButtonKey = "ginicapture.payment.hint.schedule.scheduleButtonTitle"
        static let scheduleButtonComment = "Payment hint bottom sheet primary CTA — Schedule Payment state"
        static let scheduleButton = NSLocalizedStringPreferredFormat(scheduleButtonKey,
                                                                     comment: scheduleButtonComment)

        static let scheduleProceedButtonKey = "ginicapture.payment.hint.schedule.proceedButtonTitle"
        static let scheduleProceedButtonComment = "Payment hint bottom sheet secondary CTA — Schedule Payment state (proceed with the pay-now flow)"
        static let scheduleProceedButton = NSLocalizedStringPreferredFormat(scheduleProceedButtonKey,
                                                                            comment: scheduleProceedButtonComment)
    }
}

#if DEBUG
import SwiftUI

struct PaymentHintBottomSheetViewController_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            GiniViewControllerPreview {
                PaymentHintBottomSheetViewController(
                    state: .dueDate(formattedDueDate: "13.08.2026",
                                    onProceed: { print("Proceed tapped") },
                                    onCancel: { print("Cancel tapped") })
                )
            }
            .edgesIgnoringSafeArea(.all)
            .previewDisplayName("Due Date")

            GiniViewControllerPreview {
                PaymentHintBottomSheetViewController(
                    state: .schedulePayment(formattedDueDate: "13.08.2026",
                                            onSchedule: { print("Schedule tapped") },
                                            onProceed: { print("Proceed tapped") })
                )
            }
            .edgesIgnoringSafeArea(.all)
            .previewDisplayName("Schedule Payment")
        }
    }
}
#endif
