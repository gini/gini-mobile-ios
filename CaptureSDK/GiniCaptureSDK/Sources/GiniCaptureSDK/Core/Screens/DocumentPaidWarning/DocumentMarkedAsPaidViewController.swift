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
        static let title = NSLocalizedStringPreferredFormat("ginicapture.document.paid.warning.title",
                                                            comment: "Document Marked as Paid")
        static let description = NSLocalizedStringPreferredFormat("ginicapture.document.paid.warning.description",
                                                                  comment: "This document states that it has already been paid")
        static let cancelButton = NSLocalizedStringPreferredFormat("ginicapture.document.paid.warning.cancelButtonTitle",
                                                                   comment: "Cancel transfer")
        static let proceedButton = NSLocalizedStringPreferredFormat("ginicapture.document.paid.warning.proceedButtonTitle",
                                                                    comment: "Proceed anyway")
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
