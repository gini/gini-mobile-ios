//
//  IBANSelectionSheetViewModel.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import GiniUtilites
import UIKit

/**
 Immutable configuration for `IBANSelectionSheet`. Carries pre-localized
 strings, the IBAN values to pick from, the host SDK's `GiniColorScheme`,
 and font bundles. The sheet performs no `NSLocalizedString` lookup, no
 `UIColor` resolution, and no `UIFont` math of its own.
 */
struct IBANSelectionSheetViewModel {

    /**
     Fonts used by the sheet's non-row text and its CTA. Each is optional;
     `nil` falls back to a SwiftUI system font that respects Dynamic Type.
     Non-`nil` values bridge to SwiftUI via `Font(giniFont:)`.
     */
    struct FontConfig {
        let title: UIFont?
        let validationError: UIFont?
        let footerHint: UIFont?
        let continueCTA: UIFont?

        init(title: UIFont? = nil,
             validationError: UIFont? = nil,
             footerHint: UIFont? = nil,
             continueCTA: UIFont? = nil) {
            self.title = title
            self.validationError = validationError
            self.footerHint = footerHint
            self.continueCTA = continueCTA
        }
    }

    let title: String
    let qrRowTitle: String
    let printedRowTitle: String
    let footerHint: String
    let continueCTA: String
    let validationErrorMessage: String

    /**
     VoiceOver hint read after the "Continue" button label when no row is
     selected. Held separately from `validationErrorMessage` so callers can
     localize the two strings independently.
     */
    let continueHintWhenNoSelection: String

    /**
     VoiceOver rotor action label offered on every IBAN row — on activation
     the row's IBAN is announced character by character so a blind user can
     detect a single-character substitution on a fraud-mismatch sheet.
     */
    let spellOutIBANActionName: String

    let qrIBAN: String

    /**
     Printed IBAN candidates in document order. Caller is responsible for
     dedupe (case-insensitive, whitespace-insensitive) against `qrIBAN` and
     across itself. Non-empty.
     */
    let printedIBANs: [String]

    let giniColorScheme: GiniColorScheme
    let rowFonts: GiniOptionRow.FontConfiguration
    let sheetFonts: FontConfig

    init(title: String,
         qrRowTitle: String,
         printedRowTitle: String,
         footerHint: String,
         continueCTA: String,
         validationErrorMessage: String,
         continueHintWhenNoSelection: String,
         spellOutIBANActionName: String,
         qrIBAN: String,
         printedIBANs: [String],
         giniColorScheme: GiniColorScheme,
         rowFonts: GiniOptionRow.FontConfiguration = .init(),
         sheetFonts: FontConfig = .init()) {
        self.title = title
        self.qrRowTitle = qrRowTitle
        self.printedRowTitle = printedRowTitle
        self.footerHint = footerHint
        self.continueCTA = continueCTA
        self.validationErrorMessage = validationErrorMessage
        self.continueHintWhenNoSelection = continueHintWhenNoSelection
        self.spellOutIBANActionName = spellOutIBANActionName
        self.qrIBAN = qrIBAN
        self.printedIBANs = printedIBANs
        self.giniColorScheme = giniColorScheme
        self.rowFonts = rowFonts
        self.sheetFonts = sheetFonts
    }
}
