//
//  ExtractionViewData.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import GiniBankAPILibrary

/**
 View-ready representation of a single extraction row.
 */
struct ExtractionViewData {
    /**
     Display title — mapped to a human-readable label for cross-border payments,
     or the raw extraction name for SEPA payments.
     */
    let title: String

    /**
     The extracted value, updated when the user edits the field.
     */
    var value: String

    /**
     Indicates whether the field is editable by the user.
     All fields are editable for cross-border payments; for SEPA, only fields present in the editable fields map are editable.
     */
    let isEditable: Bool

    /**
     The original extraction key name (e.g. `"iban"`, `"amountToPay"`).
     Used by the coordinator to look up values when sending the transfer summary.
     */
    let name: String?
}
