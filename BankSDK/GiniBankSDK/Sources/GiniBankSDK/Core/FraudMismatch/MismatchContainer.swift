//
//  MismatchContainer.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//
//  Spike PP-3938 — composition root for the mismatch flow.
//  Owns the `showPicker` state and uses `.bottomSheet` (iOS 16+ native,
//  iOS 15 UIKit bridge) to layer the IBAN picker on top of MismatchView.
//  Hosted by MismatchHostingController and presented modally from the
//  SDK's screen API coordinator.
//

import SwiftUI

struct MismatchContainer: View {

    let qrIBAN: String
    let printedIBAN: String

    var onCancel: () -> Void = {}
    var onContinue: (IBANPickerSheet.IBANChoice) -> Void = { _ in }

    @State private var showPicker = false

    var body: some View {
        MismatchView(
            qrIBAN: qrIBAN,
            printedIBAN: printedIBAN,
            onCancel: onCancel,
            onProceedAnyway: { showPicker = true }
        )
        .bottomSheet(isPresented: $showPicker) {
            IBANPickerSheet(
                qrIBAN: qrIBAN,
                printedIBAN: printedIBAN,
                onContinue: forwardAndDismiss
            )
        }
    }

    private func forwardAndDismiss(_ choice: IBANPickerSheet.IBANChoice) {
        showPicker = false
        DispatchQueue.main.async {
            onContinue(choice)
        }
    }
}

#if DEBUG
struct MismatchContainer_Previews: PreviewProvider {
    static var previews: some View {
        MismatchContainer(
            qrIBAN: "PL12 1000 0111 0100 1000",
            printedIBAN: "DE89 3704 0044 0532 0130 00"
        )
    }
}
#endif
