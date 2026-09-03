//
//  PaymentHintBottomSheetViewControllerTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
@testable import GiniCaptureSDK

// MARK: - Due Date state

@Suite("PaymentHintBottomSheetViewController — .dueDate state")
struct PaymentHintDueDateStateTests {

    @Test("Title is formatted with the provided due date")
    @MainActor func titleContainsProvidedDate() {
        let sut = PaymentHintBottomSheetViewController(
            state: .dueDate(formattedDueDate: "13.08.2026",
                            onProceed: {},
                            onCancel: {})
        )
        _ = sut.view

        let expected = String(format: PaymentHintBottomSheetViewController.Strings.titleFormat,
                              "13.08.2026")
        #expect(headerLabelText(in: sut) == expected,
                "Header label must contain the formatted due date")
    }

    @Test("Primary button invokes onProceed")
    @MainActor func primaryButtonInvokesProceed() {
        var proceedCalled = false
        var cancelCalled = false
        let sut = PaymentHintBottomSheetViewController(
            state: .dueDate(formattedDueDate: "13.08.2026",
                            onProceed: { proceedCalled = true },
                            onCancel: { cancelCalled = true })
        )
        _ = sut.view

        /// Bypass sendActions() — UIApplication isn't running in the test host,
        /// so the button-target chain wouldn't dispatch. The VC's @objc
        /// internal handler is the same target the button is wired to.
        sut.didPressPrimary()

        #expect(proceedCalled, "Tapping the primary button must invoke onProceed")
        #expect(!cancelCalled, "Tapping the primary button must NOT invoke onCancel")
    }

    @Test("Secondary button invokes onCancel")
    @MainActor func secondaryButtonInvokesCancel() {
        var proceedCalled = false
        var cancelCalled = false
        let sut = PaymentHintBottomSheetViewController(
            state: .dueDate(formattedDueDate: "13.08.2026",
                            onProceed: { proceedCalled = true },
                            onCancel: { cancelCalled = true })
        )
        _ = sut.view

        sut.didPressSecondary()

        #expect(cancelCalled, "Tapping the secondary button must invoke onCancel")
        #expect(!proceedCalled, "Tapping the secondary button must NOT invoke onProceed")
    }

    @Test("Sheet does not show a drag indicator")
    @MainActor func sheetHidesDragIndicator() {
        let sut = PaymentHintBottomSheetViewController(
            state: .dueDate(formattedDueDate: "13.08.2026",
                            onProceed: {},
                            onCancel: {})
        )
        #expect(!sut.shouldShowDragIndicator,
                "Payment Hint sheet must not show a drag indicator — dismissal is CTA-driven only")
    }

    @Test("Container view carries the Due Date accessibility identifier")
    @MainActor func containerCarriesDueDateAccessibilityIdentifier() {
        let sut = PaymentHintBottomSheetViewController(state: .dueDate(formattedDueDate: "13.08.2026",
                                                                       onProceed: {},
                                                                       onCancel: {}))
        _ = sut.view
        #expect(sut.view.accessibilityIdentifier == PaymentHintBottomSheetViewController.AccessibilityIdentifiers.DueDate.container,
                "Container view must carry the .dueDate container identifier")
    }

    @Test("Title, description, primary and secondary carry Due Date identifiers")
    @MainActor func labelsAndButtonsCarryDueDateAccessibilityIdentifiers() {
        let sut = PaymentHintBottomSheetViewController(state: .dueDate(formattedDueDate: "13.08.2026",
                                                                       onProceed: {},
                                                                       onCancel: {}))
        _ = sut.view

        let titleIDs = allLabels(in: sut.view).compactMap(\.accessibilityIdentifier)
        let buttonIDs = allButtons(in: sut.view).compactMap(\.accessibilityIdentifier)
        #expect(titleIDs.contains(PaymentHintBottomSheetViewController.AccessibilityIdentifiers.DueDate.title),
                "Title label must carry paymentHint.dueDate.title")
        #expect(titleIDs.contains(PaymentHintBottomSheetViewController.AccessibilityIdentifiers.DueDate.description),
                "Description label must carry paymentHint.dueDate.description")
        #expect(buttonIDs.contains(PaymentHintBottomSheetViewController.AccessibilityIdentifiers.DueDate.proceedButton),
                "Primary button must carry paymentHint.dueDate.proceedButton")
        #expect(buttonIDs.contains(PaymentHintBottomSheetViewController.AccessibilityIdentifiers.DueDate.cancelButton),
                "Secondary button must carry paymentHint.dueDate.cancelButton")
    }
}

// MARK: - Schedule Payment state

@Suite("PaymentHintBottomSheetViewController — .schedulePayment state")
struct PaymentHintScheduleStateTests {

    @Test("Title reuses the same format as the due-date state")
    @MainActor func titleReusesSharedFormat() {
        let sut = PaymentHintBottomSheetViewController(
            state: .schedulePayment(formattedDueDate: "13.08.2026",
                                    onSchedule: {},
                                    onProceed: {})
        )
        _ = sut.view

        let expected = String(format: PaymentHintBottomSheetViewController.Strings.titleFormat,
                              "13.08.2026")
        #expect(headerLabelText(in: sut) == expected,
                "Header label must reuse the shared title format")
    }

    @Test("Description equals the schedule-specific localized string")
    @MainActor func descriptionUsesScheduleCopy() {
        let sut = PaymentHintBottomSheetViewController(
            state: .schedulePayment(formattedDueDate: "13.08.2026",
                                    onSchedule: {},
                                    onProceed: {})
        )
        _ = sut.view

        let expected = PaymentHintBottomSheetViewController.Strings.scheduleDescription
        #expect(descriptionLabelText(in: sut) == expected,
                "Description must equal the schedule-specific localized string")
    }

    @Test("Primary button label is the localized Schedule Payment title")
    @MainActor func primaryButtonLabelIsScheduleTitle() {
        let sut = PaymentHintBottomSheetViewController(
            state: .schedulePayment(formattedDueDate: "13.08.2026",
                                    onSchedule: {},
                                    onProceed: {})
        )
        _ = sut.view

        #expect(buttonTitle(at: 0, in: sut) == PaymentHintBottomSheetViewController.Strings.scheduleButton,
                "Primary button title must be the localized Schedule Payment title")
    }

    @Test("Secondary button label is the localized Proceed Anyway title")
    @MainActor func secondaryButtonLabelIsProceedAnyway() {
        let sut = PaymentHintBottomSheetViewController(
            state: .schedulePayment(formattedDueDate: "13.08.2026",
                                    onSchedule: {},
                                    onProceed: {})
        )
        _ = sut.view

        #expect(buttonTitle(at: 1, in: sut) == PaymentHintBottomSheetViewController.Strings.scheduleProceedButton,
                "Secondary button title must be the localized Proceed Anyway title")
    }

    @Test("Primary button invokes onSchedule")
    @MainActor func primaryButtonInvokesSchedule() {
        var scheduleCalled = false
        var proceedCalled = false
        let sut = PaymentHintBottomSheetViewController(
            state: .schedulePayment(formattedDueDate: "13.08.2026",
                                    onSchedule: { scheduleCalled = true },
                                    onProceed: { proceedCalled = true })
        )
        _ = sut.view

        sut.didPressPrimary()

        #expect(scheduleCalled, "Tapping the primary button must invoke onSchedule")
        #expect(!proceedCalled, "Tapping the primary button must NOT invoke onProceed")
    }

    @Test("Secondary button invokes onProceed")
    @MainActor func secondaryButtonInvokesProceed() {
        var scheduleCalled = false
        var proceedCalled = false
        let sut = PaymentHintBottomSheetViewController(
            state: .schedulePayment(formattedDueDate: "13.08.2026",
                                    onSchedule: { scheduleCalled = true },
                                    onProceed: { proceedCalled = true })
        )
        _ = sut.view

        sut.didPressSecondary()

        #expect(proceedCalled, "Tapping the secondary button must invoke onProceed")
        #expect(!scheduleCalled, "Tapping the secondary button must NOT invoke onSchedule")
    }

    @Test("Sheet does not show a drag indicator")
    @MainActor func sheetHidesDragIndicator() {
        let sut = PaymentHintBottomSheetViewController(
            state: .schedulePayment(formattedDueDate: "13.08.2026",
                                    onSchedule: {},
                                    onProceed: {})
        )
        #expect(!sut.shouldShowDragIndicator,
                "Payment Hint sheet must not show a drag indicator — dismissal is CTA-driven only")
    }

    @Test("Container view carries the Schedule accessibility identifier")
    @MainActor func containerCarriesScheduleAccessibilityIdentifier() {
        let sut = PaymentHintBottomSheetViewController(state: .schedulePayment(formattedDueDate: "13.08.2026",
                                                                               onSchedule: {},
                                                                               onProceed: {}))
        _ = sut.view
        #expect(sut.view.accessibilityIdentifier == PaymentHintBottomSheetViewController.AccessibilityIdentifiers.Schedule.container,
                "Container view must carry the .schedulePayment container identifier")
    }

    @Test("Title, description, primary and secondary carry Schedule identifiers")
    @MainActor func labelsAndButtonsCarryScheduleAccessibilityIdentifiers() {
        let sut = PaymentHintBottomSheetViewController(state: .schedulePayment(formattedDueDate: "13.08.2026",
                                                                               onSchedule: {},
                                                                               onProceed: {}))
        _ = sut.view

        let titleIDs = allLabels(in: sut.view).compactMap(\.accessibilityIdentifier)
        let buttonIDs = allButtons(in: sut.view).compactMap(\.accessibilityIdentifier)
        #expect(titleIDs.contains(PaymentHintBottomSheetViewController.AccessibilityIdentifiers.Schedule.title),
                "Title label must carry paymentHint.schedule.title")
        #expect(titleIDs.contains(PaymentHintBottomSheetViewController.AccessibilityIdentifiers.Schedule.description),
                "Description label must carry paymentHint.schedule.description")
        #expect(buttonIDs.contains(PaymentHintBottomSheetViewController.AccessibilityIdentifiers.Schedule.scheduleButton),
                "Primary button must carry paymentHint.schedule.scheduleButton")
        #expect(buttonIDs.contains(PaymentHintBottomSheetViewController.AccessibilityIdentifiers.Schedule.proceedButton),
                "Secondary button must carry paymentHint.schedule.proceedButton")
    }
}

// MARK: - Shared helpers

@MainActor private func headerLabelText(in vc: UIViewController) -> String? {
    allLabels(in: vc.view)
        .compactMap(\.text)
        .first { $0.contains("13.08.2026") }
}

@MainActor private func descriptionLabelText(in vc: UIViewController) -> String? {
    allLabels(in: vc.view)
        .compactMap(\.text)
        .first { !$0.contains("13.08.2026") && !$0.isEmpty }
}

@MainActor private func buttonTitle(at index: Int,
                                    in vc: UIViewController) -> String? {
    let buttons = allButtons(in: vc.view)
    guard buttons.indices.contains(index) else { return nil }
    return buttons[index].titleLabel?.text ?? buttons[index].title(for: .normal)
}

@MainActor private func allLabels(in view: UIView) -> [UILabel] {
    var result = view.subviews.compactMap { $0 as? UILabel }
    result += view.subviews.flatMap { allLabels(in: $0) }
    return result
}

@MainActor private func allButtons(in view: UIView) -> [UIButton] {
    var result = view.subviews.compactMap { $0 as? UIButton }
    result += view.subviews.flatMap { allButtons(in: $0) }
    return result
}
