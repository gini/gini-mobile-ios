//
//  FraudWarningContent.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

/**
 Content shape for `FraudWarningView` — one case per visual variant.
 Produced by `FraudWarningIBANResolver.resolve(...)` and carried through
 `FraudWarningCoordinator` → `FraudWarningViewModel` to the view.

 Each case carries only the raw values the view needs: no `GiniColorScheme`,
 no SwiftUI types, no closures. The view resolves display strings via
 `NSLocalizedStringPreferredGiniBankFormat` and the per-row country hint
 via `hintCountryCode(for:senderCountry:)`.
 */
internal enum FraudWarningContent: Equatable {

    /**
     QR code IBAN differs from the printed IBAN. No sender information is
     shown. The picker sheet presents both IBANs for the user to pick.
     */
    case qrPrinted(qrIBAN: String, printedIBAN: String)

    /**
     Sender's country differs from the IBAN's country. Sender + the single
     IBAN row are rendered as a two-row list with a hairline between; the
     IBAN row shows an inline red country hint. The picker sheet is not
     shown — Proceed hands off directly with no IBAN choice.
     */
    case country(senderName: String?,
                 senderCountry: String,
                 iban: String)

    /**
     Both signals present. A SenderCard sits above the two IBAN rows; the
     per-row red country hint shows only on rows whose IBAN country prefix
     differs from `senderCountry`. The picker sheet presents both IBANs
     for the user to pick.
     */
    case combined(senderName: String?,
                  senderCountry: String,
                  qrIBAN: String,
                  printedIBAN: String)

    /**
     `true` when the "Proceed anyway" tap should open the IBAN selection
     sheet. `false` for the country-only variant — a single IBAN leaves
     nothing to pick.
     */
    var presentsIBANPicker: Bool {
        switch self {
        case .qrPrinted, .combined: return true
        case .country: return false
        }
    }

    /**
     QR + printed IBAN pair for the picker when `presentsIBANPicker` is
     `true`, else `nil`. Used by `FraudWarningContainer` to build the
     `IBANSelectionSheetViewModel`.
     */
    var pickerIBANs: (qrIBAN: String, printedIBAN: String)? {
        switch self {
        case let .qrPrinted(qrIBAN, printedIBAN),
             let .combined(_, _, qrIBAN, printedIBAN):
            return (qrIBAN, printedIBAN)
        case .country:
            return nil
        }
    }

    /**
     ISO 3166-1 alpha-2 country prefix of `iban` when it differs from
     `senderCountry`, otherwise `nil`. Returns `nil` for IBANs whose first
     two characters are not two letters (defensive — malformed input).
     */
    static func hintCountryCode(for iban: String,
                                senderCountry: String) -> String? {
        let normalized = iban.filter { !$0.isWhitespace }.uppercased()
        guard normalized.count >= 2 else { return nil }
        let prefix = String(normalized.prefix(2))
        guard prefix.allSatisfy({ $0.isLetter }) else { return nil }
        guard prefix != senderCountry.uppercased() else { return nil }
        return prefix
    }
}

/**
 Resolves an ISO 3166-1 alpha-2 country code to a localized country name
 in `locale`, falling back to the raw uppercase code when the system does
 not know the region. Matches the Android `countryDisplayName(code, locale)`
 helper so both platforms share the same fallback behaviour.
 */
internal enum FraudCountryName {

    /**
     Localized country name for `code` in `locale`, or the raw uppercase
     code when the system returns nothing, a blank value, or echoes the
     code itself.
     */
    static func display(code: String,
                        in locale: Locale) -> String {
        let normalized = code.uppercased()
        guard let name = locale.localizedString(forRegionCode: normalized)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty,
              name.caseInsensitiveCompare(normalized) != .orderedSame else {
            return normalized
        }
        return name
    }
}
