//
//  EditLineItemAccessibilityIdentifiers.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

/**
 Stable accessibility identifiers applied to the Return Assistant "Edit article"
 sheet's text fields for UI automation. Values are duplicated in the
 `GiniBankSDKExampleUITests` target as `EditLineItemAccessibilityIdentifiers` —
 keep both sides in sync.
 */
struct EditLineItemAccessibilityIdentifiers {
    static let nameTextField = "editLineItem.nameTextField"
    static let priceTextField = "editLineItem.priceTextField"
    static let quantityTextField = "editLineItem.quantityTextField"
}
