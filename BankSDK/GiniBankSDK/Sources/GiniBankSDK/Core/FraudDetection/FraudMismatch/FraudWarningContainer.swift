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
                         onProceed: handleProceedTap)
            .giniBottomSheet(isPresented: $isShowingPicker,
                             onDismiss: resetPickerSelection) {
                pickerSheet
            }
    }

    @ViewBuilder
    private var pickerSheet: some View {
        if let ibans = viewModel.content.pickerIBANs {
            let pickerViewModel = Self.makePickerViewModel(qrIBAN: ibans.qrIBAN,
                                                           printedIBAN: ibans.printedIBAN)
            IBANSelectionSheet(viewModel: pickerViewModel,
                               selection: $pickerSelection,
                               onContinue: handleContinue)
        }
    }

    /**
     On Proceed: open the IBAN selection sheet when the current content has
     an IBAN pair to pick from (`.qrPrinted` or `.combined`); otherwise fire
     Proceed directly with no selection (`.country` has a single IBAN, so
     there is nothing to choose).
     */
    private func handleProceedTap() {
        if viewModel.content.shouldPresentIBANPicker {
            isShowingPicker = true
        } else {
            viewModel.didTapProceed()
        }
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
     tokens and the `ginibank.fraud.iban.selection.*` localized strings.
     `static` so the view does not need a stored property — the config is
     a value type and cheap to recompute on each body evaluation.
     */
    private static func makePickerViewModel(qrIBAN: String,
                                            printedIBAN: String) -> IBANSelectionSheetViewModel {
        IBANSelectionSheetViewModel(title: localized("ginibank.fraud.iban.selection.title"),
                                    qrRowTitle: localized("ginibank.fraud.iban.selection.row.qr.label"),
                                    printedRowTitle: localized("ginibank.fraud.iban.selection.row.printed.label"),
                                    footerHint: localized("ginibank.fraud.iban.selection.footer.hint"),
                                    continueCTA: localized("ginibank.fraud.iban.selection.cta.continue"),
                                    validationErrorMessage: localized("ginibank.fraud.iban.selection.validation.select.iban"),
                                    continueHintWhenNoSelection: localized("ginibank.fraud.iban.selection.validation.select.iban"),
                                    spellOutIBANActionName: localized("ginibank.fraud.iban.selection.a11y.action.spell.out.iban"),
                                    qrIBAN: qrIBAN,
                                    printedIBANs: [printedIBAN],
                                    giniColorScheme: UIColor.giniBankColorScheme(),
                                    rowFonts: rowFonts,
                                    sheetFonts: sheetFonts)
    }

    /** Looks up a localized string in the Bank SDK bundle with host-app override support. */
    private static func localized(_ key: String) -> String {
        NSLocalizedStringPreferredGiniBankFormat(key, comment: "")
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
