//
//  MismatchHostingController.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//
//  Spike PP-3938 — UIKit bridge for the SwiftUI MismatchContainer.
//  Presented modally by GiniBankNetworkingScreenApiCoordinator after
//  analysis finishes, before the result is delivered to the host app.
//

import UIKit
import SwiftUI

final class MismatchHostingController: UIHostingController<MismatchContainer> {

    init(qrIBAN: String,
         printedIBAN: String,
         onCancel: @escaping () -> Void,
         onContinue: @escaping (IBANPickerSheet.IBANChoice) -> Void) {
        super.init(rootView: MismatchContainer(
            qrIBAN: qrIBAN,
            printedIBAN: printedIBAN,
            onCancel: onCancel,
            onContinue: onContinue
        ))
        modalPresentationStyle = .fullScreen
        isModalInPresentation = true
    }

    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
