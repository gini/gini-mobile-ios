//
//  CreditNoteWarningViewController.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

private struct CreditNoteContentViewModel: InfoBottomSheetViewModel {
    var image: UIImage? = CreditNoteWarningViewController.Images.errorIcon
    var imageTintColor: UIColor? = CreditNoteWarningViewController.Colors.errorTintColor
    var title: String = CreditNoteWarningViewController.Strings.title
    var description: String = CreditNoteWarningViewController.Strings.description
    var imageBackgroundColor: UIColor? = CreditNoteWarningViewController.Colors.imageBGColor
}

/**
 A specialized bottom sheet that informs the user a document
 has been marked as a credit note, with Cancel and Proceed actions.
*/
public final class CreditNoteWarningViewController: InfoBottomSheetViewController {

    public init(onCancel: @escaping () -> Void,
                onProceed: @escaping () -> Void) {
        let contentViewModel = CreditNoteContentViewModel()
        let primaryButton = InfoBottomSheetButtonsViewModel.Button(title: Strings.cancelButton,
                                                                   action: onCancel)

        let secondaryButton = InfoBottomSheetButtonsViewModel.Button(title: Strings.proceedButton,
                                                                     action: onProceed)

        let buttonsViewModel = InfoBottomSheetButtonsViewModel(primaryButton, secondaryButton)

        super.init(viewModel: contentViewModel, buttonsViewModel: buttonsViewModel, buttonOrder: [.secondary, .primary])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CreditNoteWarningViewController {
    struct Strings {
        static let titleKey = "ginicapture.creditNote.warning.title"
        static let titleComment = "Credit Note Detected"
        static let title = NSLocalizedStringPreferredFormat(titleKey,
                                                            comment: titleComment)

        static let descriptionKey = "ginicapture.creditNote.warning.description"
        static let descriptionComment = "This document is marked as a credit note"
        static let description = NSLocalizedStringPreferredFormat(descriptionKey,
                                                                  comment: descriptionComment)

        static let cancelButtonKey = "ginicapture.creditNote.warning.cancelButtonTitle"
        static let cancelButtonComment = "Cancel"
        static let cancelButton = NSLocalizedStringPreferredFormat(cancelButtonKey,
                                                                   comment: cancelButtonComment)

        static let proceedButtonKey = "ginicapture.creditNote.warning.proceedButtonTitle"
        static let proceedButtonComment = "Proceed"
        static let proceedButton = NSLocalizedStringPreferredFormat(proceedButtonKey,
                                                                    comment: proceedButtonComment)
    }

    // MARK: - Images
    struct Images {
        static var errorIcon: UIImage? { UIImageNamedPreferred(named: "hintErrorIcon") }
    }

    // MARK: - Colors
    struct Colors {
        static var errorTintColor: UIColor {
            GiniColor(light: .GiniCapture.warning2, dark: .GiniCapture.warning2).uiColor()
        }

        static var imageBGColor: UIColor {
            GiniColor(light: .GiniCapture.error5, dark: .GiniCapture.error5).uiColor()
        }
    }
}

#if DEBUG
import SwiftUI

struct CreditNoteWarningViewController_Preview: PreviewProvider {
    static var previews: some View {
        GiniViewControllerPreview {
            CreditNoteWarningViewController(
                onCancel: { print("Cancel tapped") },
                onProceed: { print("Proceed tapped") }
            )
        }
        .edgesIgnoringSafeArea(.all)
    }
}
#endif
