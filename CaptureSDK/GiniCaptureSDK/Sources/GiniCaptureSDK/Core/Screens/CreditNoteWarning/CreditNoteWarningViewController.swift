//
//  CreditNoteWarningViewController.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

private struct CreditNoteContentViewModel: InfoBottomSheetViewModel {
    var image: UIImage? = UIImageNamedPreferred(named: "infoMessageIcon")

    var imageTintColor: UIColor? = .yellow

    var title: String = "creditNoteWarningTitle"

    var description: String = "creditNoteWarningDescription"

}

/**
 A specialized bottom sheet that informs the user a document
 has been marked as a credit note, with Cancel and Proceed actions.
*/
public final class CreditNoteWarningViewController: InfoBottomSheetViewController {

    public init(onCancel: @escaping () -> Void,
                onProceed: @escaping () -> Void) {
        let contentViewModel = CreditNoteContentViewModel()
        let primaryButton = InfoBottomSheetButtonsViewModel.Button(title: "cancelButton",
                                                                   action: onCancel)

        let secondaryButton = InfoBottomSheetButtonsViewModel.Button(title: "proceedButton",
                                                                     action: onProceed)

        let buttonsViewModel = InfoBottomSheetButtonsViewModel(primaryButton, secondaryButton)

        super.init(viewModel: contentViewModel, buttonsViewModel: buttonsViewModel, buttonOrder: [.secondary, .primary])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CreditNoteWarningViewController {

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
