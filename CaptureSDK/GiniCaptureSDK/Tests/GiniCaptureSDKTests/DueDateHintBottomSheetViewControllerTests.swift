//
//  DueDateHintBottomSheetViewControllerTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
@testable import GiniCaptureSDK

@Suite("DueDateHintBottomSheetViewController")
struct DueDateHintBottomSheetViewControllerTests {

    // MARK: - Title formatting

    @Test("Title is formatted with the provided due date")
    @MainActor func titleContainsProvidedDate() {
        let sut = DueDateHintBottomSheetViewController(formattedDueDate: "13.08.2026",
                                                       onCancel: {},
                                                       onProceed: {})
        _ = sut.view

        let expected = String(format: DueDateHintBottomSheetViewController.Strings.titleFormat,
                              "13.08.2026")
        #expect(headerLabelText(in: sut) == expected,
                "Header label must contain the formatted due date")
    }

    // MARK: - CTA wiring

    @Test("Primary button invokes onProceed")
    @MainActor func primaryButtonInvokesProceed() {
        var proceedCalled = false
        var cancelCalled = false
        let sut = DueDateHintBottomSheetViewController(formattedDueDate: "13.08.2026",
                                                       onCancel: { cancelCalled = true },
                                                       onProceed: { proceedCalled = true })
        _ = sut.view

        // Bypass sendActions() — UIApplication isn't running in the test host,
        // so the button-target chain wouldn't dispatch. The VC's @objc
        // internal handler is the same target the button is wired to.
        sut.didPressPrimary()

        #expect(proceedCalled, "Tapping the primary button must invoke onProceed")
        #expect(!cancelCalled, "Tapping the primary button must NOT invoke onCancel")
    }

    @Test("Secondary button invokes onCancel")
    @MainActor func secondaryButtonInvokesCancel() {
        var proceedCalled = false
        var cancelCalled = false
        let sut = DueDateHintBottomSheetViewController(formattedDueDate: "13.08.2026",
                                                       onCancel: { cancelCalled = true },
                                                       onProceed: { proceedCalled = true })
        _ = sut.view

        sut.didPressSecondary()

        #expect(cancelCalled, "Tapping the secondary button must invoke onCancel")
        #expect(!proceedCalled, "Tapping the secondary button must NOT invoke onProceed")
    }

    // MARK: - Sheet configuration

    @Test("Sheet does not show a drag indicator")
    @MainActor func sheetHidesDragIndicator() {
        let sut = DueDateHintBottomSheetViewController(formattedDueDate: "13.08.2026",
                                                       onCancel: {},
                                                       onProceed: {})
        #expect(!sut.shouldShowDragIndicator,
                "Due Date Hint sheet must not show a drag indicator — dismissal is CTA-driven only")
    }

    // MARK: - Localization

    @Test("Localized strings resolve to non-empty values")
    @MainActor func localizedStringsResolve() {
        #expect(!DueDateHintBottomSheetViewController.Strings.titleFormat.isEmpty)
        #expect(!DueDateHintBottomSheetViewController.Strings.description.isEmpty)
        #expect(!DueDateHintBottomSheetViewController.Strings.proceedButton.isEmpty)
        #expect(!DueDateHintBottomSheetViewController.Strings.cancelButton.isEmpty)
        // Guard against typo drift on the format string.
        #expect(DueDateHintBottomSheetViewController.Strings.titleFormat.contains("%@"),
                "Title format must include a single %@ placeholder for the date")
    }

    // MARK: - Helpers

    @MainActor private func headerLabelText(in vc: UIViewController) -> String? {
        allLabels(in: vc.view)
            .compactMap(\.text)
            .first { $0.contains("13.08.2026") }
    }

    @MainActor private func allLabels(in view: UIView) -> [UILabel] {
        var result = view.subviews.compactMap { $0 as? UILabel }
        result += view.subviews.flatMap { allLabels(in: $0) }
        return result
    }
}
