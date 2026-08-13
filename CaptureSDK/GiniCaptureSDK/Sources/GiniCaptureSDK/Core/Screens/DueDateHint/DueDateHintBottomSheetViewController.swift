//
//  DueDateHintBottomSheetViewController.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit

private struct DueDateHintContentViewModel: InfoBottomSheetViewModel {
    var image: UIImage? = UIImageNamedPreferred(named: "infoMessageIcon")
    var imageTintColor: UIColor? = GiniColor(light: .GiniCapture.warning2,
                                             dark: .GiniCapture.warning2).uiColor()
    let title: String
    var description: String = DueDateHintBottomSheetViewController.Strings.description
}

/**
 A specialized bottom sheet that informs the user that their invoice is due
 comfortably in the future and offers Cancel and Proceed actions.

 Present it over the Analysis screen when
 `Date.isDueSoon(within: paymentDueHintThresholdDays)` returns `true` for
 the extracted due date — i.e. the due date is at least
 `paymentDueHintThresholdDays - 1` days away (inclusive-days boundary).
 */
public final class DueDateHintBottomSheetViewController: InfoBottomSheetViewController {

    /**
     Creates a due-date-hint bottom sheet with the given formatted date and CTAs.
     - Parameters:
       - formattedDueDate: The payment due date rendered for display in the sheet
         title (e.g. `"13.08.2026"`). Interpolated into the localized title format.
       - onCancel: Invoked when the user taps the secondary CTA (`Cancel Transfer`).
         Callers typically dismiss the SDK flow and return to the host app.
       - onProceed: Invoked when the user taps the primary CTA (`Proceed Anyway`).
         Callers typically continue to the extraction-results screen.
     */
    public init(formattedDueDate: String,
                onCancel: @escaping () -> Void,
                onProceed: @escaping () -> Void) {
        let title = String(format: Strings.titleFormat, formattedDueDate)
        let contentViewModel = DueDateHintContentViewModel(title: title)

        /// Figma: "Proceed Anyway" is the primary CTA for Due Date.
        let primaryButton = InfoBottomSheetButtonsViewModel.Button(title: Strings.proceedButton,
                                                                   action: onProceed)

        let secondaryButton = InfoBottomSheetButtonsViewModel.Button(title: Strings.cancelButton,
                                                                     action: onCancel)

        let buttonsViewModel = InfoBottomSheetButtonsViewModel(primaryButton, secondaryButton)

        super.init(viewModel: contentViewModel, buttonsViewModel: buttonsViewModel)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DueDateHintBottomSheetViewController {
    struct Strings {
        static let titleFormatKey = "ginicapture.payment.duedate.hint.title.format"
        static let titleFormatComment = "Due date hint bottom sheet title format (single %@ placeholder for the formatted date)"
        static let titleFormat = NSLocalizedStringPreferredFormat(titleFormatKey,
                                                                  comment: titleFormatComment)

        static let descriptionKey = "ginicapture.payment.duedate.hint.description"
        static let descriptionComment = "Due date hint bottom sheet description"
        static let description = NSLocalizedStringPreferredFormat(descriptionKey,
                                                                  comment: descriptionComment)

        static let proceedButtonKey = "ginicapture.payment.duedate.hint.proceedButtonTitle"
        static let proceedButtonComment = "Due date hint bottom sheet primary CTA — proceed with the transfer"
        static let proceedButton = NSLocalizedStringPreferredFormat(proceedButtonKey,
                                                                    comment: proceedButtonComment)

        static let cancelButtonKey = "ginicapture.payment.duedate.hint.cancelButtonTitle"
        static let cancelButtonComment = "Due date hint bottom sheet secondary CTA — cancel the transfer"
        static let cancelButton = NSLocalizedStringPreferredFormat(cancelButtonKey,
                                                                   comment: cancelButtonComment)
    }
}

#if DEBUG
import SwiftUI

struct DueDateHintBottomSheetViewController_Preview: PreviewProvider {
    static var previews: some View {
        GiniViewControllerPreview {
            DueDateHintBottomSheetViewController(
                formattedDueDate: "13.08.2026",
                onCancel: { print("Cancel tapped") },
                onProceed: { print("Proceed tapped") }
            )
        }
        .edgesIgnoringSafeArea(.all)
    }
}
#endif
