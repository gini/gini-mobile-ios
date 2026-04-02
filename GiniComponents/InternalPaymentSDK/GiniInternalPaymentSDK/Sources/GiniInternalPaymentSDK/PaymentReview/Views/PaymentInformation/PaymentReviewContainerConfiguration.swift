//
//  File.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites

/**
 Configuration for the error label shown in payment review fields.
 */
public struct PaymentReviewErrorLabelConfiguration {
    let textColor: UIColor
    let font: UIFont
    
    public init(textColor: UIColor, font: UIFont) {
        self.textColor = textColor
        self.font = font
    }
}

/**
 Configuration for the bank picker and locked input fields in the payment review container.
 */
public struct PaymentReviewBanksPickerConfiguration {
    let lockIcon: UIImage
    let lockedFields: Bool
    let showBanksPicker: Bool
    let chevronDownIcon: UIImage?
    let chevronDownIconColor: UIColor?
    
    public init(lockIcon: UIImage,
                lockedFields: Bool,
                showBanksPicker: Bool,
                chevronDownIcon: UIImage?,
                chevronDownIconColor: UIColor?) {
        self.lockIcon = lockIcon
        self.lockedFields = lockedFields
        self.showBanksPicker = showBanksPicker
        self.chevronDownIcon = chevronDownIcon
        self.chevronDownIconColor = chevronDownIconColor
    }
}

/**
 Configuration for the info bar shown in the payment review container.
 */
public struct PaymentReviewInfoBarConfiguration {
    let labelTextColor: UIColor
    let labelFont: UIFont
    let backgroundColor: UIColor
    let containerBackgroundColor: UIColor
    
    public init(labelTextColor: UIColor,
                labelFont: UIFont,
                backgroundColor: UIColor,
                containerBackgroundColor: UIColor) {
        self.labelTextColor = labelTextColor
        self.labelFont = labelFont
        self.backgroundColor = backgroundColor
        self.containerBackgroundColor = containerBackgroundColor
    }
}

/**
 Configuration settings for the Payment Review container view.
 */
public struct PaymentReviewContainerConfiguration {
    let errorLabel: PaymentReviewErrorLabelConfiguration
    let banksPicker: PaymentReviewBanksPickerConfiguration
    let infoBar: PaymentReviewInfoBarConfiguration
    let popupAnimationDuration: TimeInterval
    
    public init(errorLabel: PaymentReviewErrorLabelConfiguration,
                banksPicker: PaymentReviewBanksPickerConfiguration,
                infoBar: PaymentReviewInfoBarConfiguration,
                popupAnimationDuration: TimeInterval) {
        self.errorLabel = errorLabel
        self.banksPicker = banksPicker
        self.infoBar = infoBar
        self.popupAnimationDuration = popupAnimationDuration
    }
}

/**
 Error messages used for field validation in the payment review screen.
 */
public struct PaymentReviewFieldErrors {
    let emptyCheck: String
    let ibanCheck: String
    let recipient: String
    let iban: String
    let amount: String
    let purpose: String
    
    public init(emptyCheck: String,
                ibanCheck: String,
                recipient: String,
                iban: String,
                amount: String,
                purpose: String) {
        self.emptyCheck = emptyCheck
        self.ibanCheck = ibanCheck
        self.recipient = recipient
        self.iban = iban
        self.amount = amount
        self.purpose = purpose
    }
}

/**
 Placeholder strings for input fields in the payment review screen.
 */
public struct PaymentReviewFieldPlaceholders {
    let recipient: String
    let iban: String
    let amount: String
    let usage: String
    
    public init(recipient: String,
                iban: String,
                amount: String,
                usage: String) {
        self.recipient = recipient
        self.iban = iban
        self.amount = amount
        self.usage = usage
    }
}

/**
 Accessibility strings for the bank selection and pay invoice button.
 */
public struct PaymentReviewBankSelectionAccessibility {
    let payInvoiceHint: String
    let selectBankText: String
    let selectBankHint: String
    
    public init(payInvoiceHint: String,
                selectBankText: String,
                selectBankHint: String) {
        self.payInvoiceHint = payInvoiceHint
        self.selectBankText = selectBankText
        self.selectBankHint = selectBankHint
    }
}

/**
 Configuration for the primary and secondary buttons in the payment review container.
 */
public struct PaymentReviewContainerButtonsConfiguration {
    let primaryButton: ButtonConfiguration
    let secondaryButton: ButtonConfiguration

    public init(primaryButton: ButtonConfiguration,
                secondaryButton: ButtonConfiguration) {
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
    }
}

/**
 Configuration for the input fields (default, error, and selection styles) in the payment review container.
 */
public struct PaymentReviewContainerInputFieldsConfiguration {
    let defaultStyle: TextFieldConfiguration
    let errorStyle: TextFieldConfiguration
    let selectionStyle: TextFieldConfiguration

    public init(defaultStyle: TextFieldConfiguration,
                errorStyle: TextFieldConfiguration,
                selectionStyle: TextFieldConfiguration) {
        self.defaultStyle = defaultStyle
        self.errorStyle = errorStyle
        self.selectionStyle = selectionStyle
    }
}

/**
 String resources for the Payment Review container view.
 */
public struct PaymentReviewContainerStrings {
    let fieldPlaceholders: PaymentReviewFieldPlaceholders
    let fieldErrors: PaymentReviewFieldErrors
    let bankSelectionAccessibility: PaymentReviewBankSelectionAccessibility
    let payInvoiceLabelText: String
    let infoBarMessage: String
    let keyboardDoneButtonTitle: String
    
    public init(fieldPlaceholders: PaymentReviewFieldPlaceholders,
                fieldErrors: PaymentReviewFieldErrors,
                bankSelectionAccessibility: PaymentReviewBankSelectionAccessibility,
                payInvoiceLabelText: String,
                infoBarMessage: String,
                keyboardDoneButtonTitle: String) {
        self.fieldPlaceholders = fieldPlaceholders
        self.fieldErrors = fieldErrors
        self.bankSelectionAccessibility = bankSelectionAccessibility
        self.payInvoiceLabelText = payInvoiceLabelText
        self.infoBarMessage = infoBarMessage
        self.keyboardDoneButtonTitle = keyboardDoneButtonTitle
    }
}
