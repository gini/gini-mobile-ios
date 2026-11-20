//
//  FraudWarningViewModel.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

/**
 ViewModel for the fraud warning screen.

 Carries user intent (tap Cancel / tap Proceed) up to the owning Coordinator
 via a weak delegate, plus the display data for the two inline IBAN rows and
 the "How do I protect myself?" expandable. Imports no UIKit — binding to
 SwiftUI happens through `@ObservedObject` at the view layer. The VM is
 intentionally "dumb": it does not track whether a resolution is already in
 flight, because the single-terminal-callback guarantee for the SDK's results
 delegate is enforced one layer above this type.
 */
@MainActor
final class FraudWarningViewModel: ObservableObject {

    /** IBAN read from the payment QR code. Rendered in the top informational row. */
    let qrIBAN: String

    /** IBAN printed on the document. Rendered in the second informational row. */
    let printedIBAN: String

    /** External binding target for the "How do I protect myself?" expandable. */
    @Published var isExpandedProtectMyself: Bool = false

    /**
     IBAN the user confirmed on the picker sheet, or `nil` until a pick lands.
     Downstream screens (Coordinator / integrator hand-off) read this to decide
     which IBAN flows forward.
     */
    @Published var selectedIBAN: IBANChoice?

    /** Parent that receives tap callbacks. Weak to avoid a retain cycle with the Coordinator. */
    weak var delegate: FraudWarningViewModelDelegate?

    init(qrIBAN: String,
         printedIBAN: String,
         delegate: FraudWarningViewModelDelegate?) {
        self.qrIBAN = qrIBAN
        self.printedIBAN = printedIBAN
        self.delegate = delegate
    }

    func didTapCancel() {
        delegate?.fraudWarningViewModelDidCancel(self)
    }

    func didTapProceed() {
        delegate?.fraudWarningViewModelDidProceed(self)
    }

    /**
     User picked an IBAN on the sheet and tapped Continue. Stores the choice
     and fires the existing Proceed delegate so the Coordinator advances the
     flow with the chosen IBAN available via `selectedIBAN`.
     */
    func didConfirmIBAN(_ choice: IBANChoice) {
        selectedIBAN = choice
        delegate?.fraudWarningViewModelDidProceed(self)
    }
}
