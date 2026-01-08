//
//  DocumentMarkedAsPaidViewController.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit
import Combine

private struct DocumentMarkedAsPaidContentViewModel: InfoBottomSheetViewModel {
    var image: UIImage? = UIImageNamedPreferred(named: "infoMessageIcon")
    var imageTintColor: UIColor? = GiniColor(light: .GiniCapture.warning2,
                                             dark: .GiniCapture.warning2).uiColor()
    var title: String = DocumentMarkedAsPaidViewController.Strings.title
    var description: String = DocumentMarkedAsPaidViewController.Strings.description
}

/**
 A specialized bottom sheet that informs the user a document
 has been marked as paid, with Cancel and Proceed actions.
*/
public final class DocumentMarkedAsPaidViewController: InfoBottomSheetViewController {

    public init(onCancel: @escaping () -> Void,
                onProceed: @escaping () -> Void) {
        let contentViewModel = DocumentMarkedAsPaidContentViewModel()
        let primaryButton = InfoBottomSheetButtonsViewModel.Button(title: Strings.cancelButton,
                                                                   action: onCancel)

        let secondaryButton = InfoBottomSheetButtonsViewModel.Button(title: Strings.proceedButton,
                                                                     action: onProceed)

        let buttonsViewModel = InfoBottomSheetButtonsViewModel(primaryButton, secondaryButton)

        super.init(viewModel: contentViewModel, buttonsViewModel: buttonsViewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DocumentMarkedAsPaidViewController {
    struct Strings {
        static let titleKey = "ginicapture.document.paid.warning.title"
        static let titleComment = "Document Marked as Paid"
        static let title = NSLocalizedStringPreferredFormat(titleKey,
                                                            comment: titleComment)

        static let descriptionKey = "ginicapture.document.paid.warning.description"
        static let descriptionComment = "This document states that it has already been paid"
        static let description = NSLocalizedStringPreferredFormat(descriptionKey,
                                                                  comment: descriptionComment)

        static let cancelButtonKey = "ginicapture.document.paid.warning.cancelButtonTitle"
        static let cancelButtonComment = "Cancel transfer"
        static let cancelButton = NSLocalizedStringPreferredFormat(cancelButtonKey,
                                                                   comment: cancelButtonComment)

        static let proceedButtonKey = "ginicapture.document.paid.warning.proceedButtonTitle"
        static let proceedButtonComment = "Proceed anyway"
        static let proceedButton = NSLocalizedStringPreferredFormat(proceedButtonKey,
                                                                    comment: proceedButtonComment)
    }
}

#if DEBUG
import SwiftUI

struct DocumentMarkedAsPaidViewController_Preview: PreviewProvider {
    static var previews: some View {
        GiniViewControllerPreview {
            DocumentMarkedAsPaidViewController(
                onCancel: { print("Cancel tapped") },
                onProceed: { print("Proceed tapped") }
            )
        }
        .edgesIgnoringSafeArea(.all)
    }
}
#endif
