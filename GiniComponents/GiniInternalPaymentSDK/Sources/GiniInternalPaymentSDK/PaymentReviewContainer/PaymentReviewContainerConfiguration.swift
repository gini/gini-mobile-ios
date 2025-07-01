//
//  File.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

/// Configuration settings for the Payment Review container view.
public struct PaymentReviewContainerConfiguration {
    let errorLabelTextColor: UIColor
    let errorLabelFont: UIFont
    let lockIcon: UIImage
    let lockedFields: Bool
    let showBanksPicker: Bool
    let chevronDownIcon: UIImage?
    let chevronDownIconColor: UIColor?

    /**
     Initializes a new configuration for the Payment Review container view.
     
     - Parameters:
       - errorLabelTextColor: The color of the error label text.
       - errorLabelFont: The font used for the error label.
       - lockIcon: The icon displayed to indicate locked fields.
       - lockedFields: A flag indicating whether specific fields are locked for editing.
       - showBanksPicker: A flag indicating whether the bank picker should be shown.
       - chevronDownIcon: The icon for the chevron pointing downward, used in the UI.
       - chevronDownIconColor: The color of the chevron down icon.
     */
    public init(errorLabelTextColor: UIColor,
                errorLabelFont: UIFont,
                lockIcon: UIImage,
                lockedFields: Bool,
                showBanksPicker: Bool,
                chevronDownIcon: UIImage?,
                chevronDownIconColor: UIColor?) {
        self.errorLabelTextColor = errorLabelTextColor
        self.errorLabelFont = errorLabelFont
        self.lockIcon = lockIcon
        self.lockedFields = lockedFields
        self.showBanksPicker = showBanksPicker
        self.chevronDownIcon = chevronDownIcon
        self.chevronDownIconColor = chevronDownIconColor
    }
}

public struct PaymentReviewContainerStrings {
    let emptyCheckErrorMessage: String
    let ibanCheckErrorMessage: String
    let recipientFieldPlaceholder: String
    let ibanFieldPlaceholder: String
    let amountFieldPlaceholder: String
    let usageFieldPlaceholder: String
    let recipientErrorMessage: String
    let ibanErrorMessage: String
    let amountErrorMessage: String
    let purposeErrorMessage: String
    let payInvoiceLabelText: String
    let payInvoiceAccessibilityHint: String
    let selectBankAccessibilityText: String

    public init(emptyCheckErrorMessage: String,
                ibanCheckErrorMessage: String,
                recipientFieldPlaceholder: String,
                ibanFieldPlaceholder: String,
                amountFieldPlaceholder: String,
                usageFieldPlaceholder: String,
                recipientErrorMessage: String,
                ibanErrorMessage: String,
                amountErrorMessage: String,
                purposeErrorMessage: String,
                payInvoiceLabelText: String,
                payInvoiceAccessibilityHint: String,
                selectBankAccessibilityText: String) {
        self.emptyCheckErrorMessage = emptyCheckErrorMessage
        self.ibanCheckErrorMessage = ibanCheckErrorMessage
        self.recipientFieldPlaceholder = recipientFieldPlaceholder
        self.ibanFieldPlaceholder = ibanFieldPlaceholder
        self.amountFieldPlaceholder = amountFieldPlaceholder
        self.usageFieldPlaceholder = usageFieldPlaceholder
        self.recipientErrorMessage = recipientErrorMessage
        self.ibanErrorMessage = ibanErrorMessage
        self.amountErrorMessage = amountErrorMessage
        self.purposeErrorMessage = purposeErrorMessage
        self.payInvoiceLabelText = payInvoiceLabelText
        self.payInvoiceAccessibilityHint = payInvoiceAccessibilityHint
        self.selectBankAccessibilityText = selectBankAccessibilityText
    }
}
