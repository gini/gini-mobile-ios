//
//  FraudWarningViewModel.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

/**
 ViewModel for the fraud warning screen.

 Carries user intent (tap Cancel / tap Proceed / confirm IBAN) up to the
 owning Coordinator via a weak delegate, plus the `FraudWarningContent`
 that drives the three view variants (QR-vs-printed, country-only,
 combined). Imports no UIKit — binding to SwiftUI happens through
 `@ObservedObject` at the view layer. The VM is intentionally "dumb": it
 does not track whether a resolution is already in flight, because the
 single-terminal-callback guarantee for the SDK's results delegate is
 enforced one layer above this type.
 */
@MainActor
final class FraudWarningViewModel: ObservableObject {

    /** Shape of the fraud warning — selects which view variant renders. */
    let content: FraudWarningContent

    /** External binding target for the "How do I protect myself?" expandable. */
    @Published var isExpandedProtectMyself: Bool = false

    /**
     IBAN the user confirmed on the picker sheet, or `nil` until a pick lands.
     Downstream screens (Coordinator / integrator hand-off) read this to decide
     which IBAN flows forward.
     */
    var selectedIBAN: IBANChoice?

    /** Parent that receives tap callbacks. Weak to avoid a retain cycle with the Coordinator. */
    weak var delegate: FraudWarningViewModelDelegate?

    init(content: FraudWarningContent,
         delegate: FraudWarningViewModelDelegate?) {
        self.content = content
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

    // MARK: - Derived display strings

    /** Localized title key for the current `content` variant. */
    var titleKey: String {
        switch content {
        case .qrPrinted: return "ginibank.fraud.warning.title.qr.printed"
        case .country:   return "ginibank.fraud.warning.title.country"
        case .combined:  return "ginibank.fraud.warning.title.combined"
        }
    }

    /** Localized body/subtitle key for the current `content` variant. */
    var bodyKey: String {
        switch content {
        case .qrPrinted: return "ginibank.fraud.warning.body.qr.printed"
        case .country:   return "ginibank.fraud.warning.body.country"
        case .combined:  return "ginibank.fraud.warning.body.combined"
        }
    }

    /**
     Sender-card value shown next to the "Sender" label. Returns
     `"Name · Country"` when both are available, the localized country
     name alone when the name is missing/empty.
     */
    func senderContent(senderName: String?, senderCountry: String) -> String {
        let country = FraudCountryName.displayCountry(code: senderCountry,
                                                      in: Self.countryNameLocale)
        guard let name = senderName, !name.isEmpty else { return country }
        return String(format: Self.localized("ginibank.fraud.warning.sender.with.country"),
                      name, country)
    }

    /**
     Red hint line shown below an IBAN row ("From Poland, not the sender's
     country"). Returns `nil` when the IBAN's country matches the sender's.
     */
    func countryHint(for iban: String, senderCountry: String) -> String? {
        guard let code = FraudWarningContent.hintCountryCode(for: iban,
                                                             senderCountry: senderCountry) else {
            return nil
        }
        let name = FraudCountryName.displayCountry(code: code, in: Self.countryNameLocale)
        return String(format: Self.localized("ginibank.fraud.warning.row.country.hint"), name)
    }

    // MARK: - Localization helpers

    private static func localized(_ key: String) -> String {
        NSLocalizedStringPreferredGiniBankFormat(key, comment: "")
    }

    private static var countryNameLocale: Locale {
        Locale(identifier: localized("ginibank.fraud.country.name.locale"))
    }
}
