//
//  FraudWarningContainer.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI
import UIKit
import GiniUtilites

/**
 Composition root for the fraud warning screen. Observes
 `FraudWarningViewModel` and drives the IBAN selection sheet when the user
 taps Proceed. Hosted by `FraudWarningCoordinator.start()`.
 */
struct FraudWarningContainer: View {

    @ObservedObject var viewModel: FraudWarningViewModel

    @State private var isShowingPicker: Bool = false
    @State private var pickerSelection: IBANChoice?

    var body: some View {
        FraudWarningView(viewModel: viewModel,
                         onCancel: viewModel.didTapCancel,
                         onProceed: showPicker)
            .giniBottomSheet(isPresented: $isShowingPicker,
                             onDismiss: resetPickerSelection) {
                pickerSheet
            }
    }

    private var pickerSheet: some View {
        IBANSelectionSheet(viewModel: Self.makePickerViewModel(qrIBAN: viewModel.qrIBAN,
                                                               printedIBAN: viewModel.printedIBAN),
                           selection: $pickerSelection,
                           onContinue: handleContinue)
    }

    private func showPicker() {
        isShowingPicker = true
    }

    private func resetPickerSelection() {
        pickerSelection = nil
    }

    private func handleContinue(_ choice: IBANChoice) {
        isShowingPicker = false
        pickerSelection = nil
        viewModel.didConfirmIBAN(choice)
    }

    /**
     Builds the `IBANSelectionSheetViewModel` from Bank SDK design-system
     tokens. `static` so the view does not need a stored property — the
     config is a value type and cheap to recompute on each body evaluation.
     Strings are hardcoded English scaffolds; `LocalizableStringResource`
     wiring lands with the final visual pass.
     */
    private static func makePickerViewModel(qrIBAN: String,
                                            printedIBAN: String) -> IBANSelectionSheetViewModel {
        IBANSelectionSheetViewModel(title: "To continue, select one of the IBANs",
                                    qrRowTitle: "In the QR code",
                                    printedRowTitle: "Printed on the document",
                                    footerHint: "You can still check the IBAN on the next screen.",
                                    continueCTA: "Continue",
                                    validationErrorMessage: "Select an IBAN to continue",
                                    continueHintWhenNoSelection: "Select an IBAN to continue",
                                    spellOutIBANActionName: "Spell out IBAN",
                                    qrIBAN: qrIBAN,
                                    printedIBANs: [printedIBAN],
                                    giniColorScheme: UIColor.giniBankColorScheme(),
                                    rowFonts: rowFonts,
                                    sheetFonts: sheetFonts)
    }

    private static var rowFonts: GiniOptionRow.FontConfiguration {
        GiniOptionRow.FontConfiguration(title: font(.caption1),
                                        content: font(.body),
                                        footer: font(.caption2))
    }

    private static var sheetFonts: IBANSelectionSheetViewModel.FontConfig {
        IBANSelectionSheetViewModel.FontConfig(title: font(.title3),
                                               validationError: font(.footnote),
                                               footerHint: font(.footnote),
                                               continueCTA: font(.body))
    }

    /** Resolves a Bank configuration font with a system fallback for the given text style. */
    private static func font(_ style: UIFont.TextStyle) -> UIFont {
        GiniBankConfiguration.shared.textStyleFonts[style] ?? UIFont.preferredFont(forTextStyle: style)
    }
}
