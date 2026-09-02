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
    var imageBackgroundColor: UIColor? = PaymentHintBottomSheetViewController.Colors.imageBGColor

    var containerAccessibilityID: String? = PaymentHintBottomSheetViewController.AccessibilityIdentifiers.DueDate.container
    var titleAccessibilityID: String? = PaymentHintBottomSheetViewController.AccessibilityIdentifiers.DueDate.title
    var descriptionAccessibilityID: String? = PaymentHintBottomSheetViewController.AccessibilityIdentifiers.DueDate.description
    var primaryButtonAccessibilityID: String? = PaymentHintBottomSheetViewController.AccessibilityIdentifiers.DueDate.proceedButton
    var secondaryButtonAccessibilityID: String? = PaymentHintBottomSheetViewController.AccessibilityIdentifiers.DueDate.cancelButton
}

private struct ScheduleContent: InfoBottomSheetViewModel {
    var image: UIImage? = UIImageNamedPreferred(named: "infoMessageIcon")
    var imageTintColor: UIColor? = GiniColor(light: .GiniCapture.warning2,
                                             dark: .GiniCapture.warning2).uiColor()
    let title: String
    var description: String = PaymentHintBottomSheetViewController.Strings.scheduleDescription
    var imageBackgroundColor: UIColor? = PaymentHintBottomSheetViewController.Colors.imageBGColor

    var containerAccessibilityID: String? = PaymentHintBottomSheetViewController.AccessibilityIdentifiers.Schedule.container
    var titleAccessibilityID: String? = PaymentHintBottomSheetViewController.AccessibilityIdentifiers.Schedule.title
    var descriptionAccessibilityID: String? = PaymentHintBottomSheetViewController.AccessibilityIdentifiers.Schedule.description
    var primaryButtonAccessibilityID: String? = PaymentHintBottomSheetViewController.AccessibilityIdentifiers.Schedule.scheduleButton
    var secondaryButtonAccessibilityID: String? = PaymentHintBottomSheetViewController.AccessibilityIdentifiers.Schedule.proceedButton
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
        let (contentViewModel, buttonsViewModel) = Self.makeViewModels(for: state)
        super.init(viewModel: contentViewModel, buttonsViewModel: buttonsViewModel)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func makeViewModels(for state: PaymentHintState) -> (InfoBottomSheetViewModel, InfoBottomSheetButtonsViewModel) {
        switch state {
        case let .dueDate(formattedDueDate, onProceed, onCancel):
            return makeDueDateViewModels(formattedDueDate: formattedDueDate,
                                         onProceed: onProceed,
                                         onCancel: onCancel)
        case let .schedulePayment(formattedDueDate, onSchedule, onProceed):
            return makeScheduleViewModels(formattedDueDate: formattedDueDate,
                                          onSchedule: onSchedule,
                                          onProceed: onProceed)
        }
    }

    private static func makeDueDateViewModels(formattedDueDate: String,
                                              onProceed: @escaping () -> Void,
                                              onCancel: @escaping () -> Void) -> (InfoBottomSheetViewModel, InfoBottomSheetButtonsViewModel) {
        let title = String(format: Strings.titleFormat, formattedDueDate)
        let content = DueDateContent(title: title)
        let primary = InfoBottomSheetButtonsViewModel.Button(title: Strings.dueDateProceedButton,
                                                             action: onProceed)
        let secondary = InfoBottomSheetButtonsViewModel.Button(title: Strings.dueDateCancelButton,
                                                               action: onCancel)
        return (content, InfoBottomSheetButtonsViewModel(primary, secondary))
    }

    private static func makeScheduleViewModels(formattedDueDate: String,
                                               onSchedule: @escaping () -> Void,
                                               onProceed: @escaping () -> Void) -> (InfoBottomSheetViewModel, InfoBottomSheetButtonsViewModel) {
        let title = String(format: Strings.titleFormat, formattedDueDate)
        let content = ScheduleContent(title: title)
        let primary = InfoBottomSheetButtonsViewModel.Button(title: Strings.scheduleButton,
                                                             action: onSchedule)
        let secondary = InfoBottomSheetButtonsViewModel.Button(title: Strings.scheduleProceedButton,
                                                               action: onProceed)
        return (content, InfoBottomSheetButtonsViewModel(primary, secondary))
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

    // MARK: - Colors
    struct Colors {
        static var imageBGColor: UIColor {
            GiniColor(light: .GiniCapture.warning5, dark: .GiniCapture.warning5).uiColor()
        }
    }

    // MARK: - Accessibility Identifiers
    /**
     Stable, state-scoped accessibility identifiers applied to the sheet
     for UI-automation. Values are duplicated in the
     `GiniBankSDKExampleUITests` target as
     `PaymentHintScreenAccessibilityIdentifiers` — keep both sides in sync.
     */
    struct AccessibilityIdentifiers {
        private init() {
            // Namespace-only; instantiation is disabled.
        }

        struct DueDate {
            private init() {
                // Namespace-only; instantiation is disabled.
            }
            static let container = "paymentHint.dueDate.container"
            static let title = "paymentHint.dueDate.title"
            static let description = "paymentHint.dueDate.description"
            static let proceedButton = "paymentHint.dueDate.proceedButton"
            static let cancelButton = "paymentHint.dueDate.cancelButton"
        }

        struct Schedule {
            private init() {
                // Namespace-only; instantiation is disabled.
            }
            static let container = "paymentHint.schedule.container"
            static let title = "paymentHint.schedule.title"
            static let description = "paymentHint.schedule.description"
            static let scheduleButton = "paymentHint.schedule.scheduleButton"
            static let proceedButton = "paymentHint.schedule.proceedButton"
        }
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
