//
//  EditLineItemAccessibilityIdentifiers.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

/**
 Accessibility identifiers exposed by the Return Assistant "Edit article" sheet
 (`EditLineItemView` components in `GiniBankSDK`). Values must stay byte-identical
 to the SDK's `EditLineItemAccessibilityIdentifiers` struct
 (`BankSDK/GiniBankSDK/Sources/GiniBankSDK/Core/ReturnAssistant/EditLineItem/EditLineItemAccessibilityIdentifiers.swift`)
 — duplication is intentional because the UITest target cannot import the SDK.
 */
struct EditLineItemAccessibilityIdentifiers {

    static let nameTextField = "editLineItem.nameTextField"
    static let priceTextField = "editLineItem.priceTextField"
    static let quantityTextField = "editLineItem.quantityTextField"
}
