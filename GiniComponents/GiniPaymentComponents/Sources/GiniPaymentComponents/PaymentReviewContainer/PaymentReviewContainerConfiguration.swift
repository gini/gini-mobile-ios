//
//  File.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

public struct PaymentReviewContainerConfiguration {
    let errorLabelTextColor: UIColor
    let errorLabelFont: UIFont
    let lockIcon: UIImage

    public init(errorLabelTextColor: UIColor,
                errorLabelFont: UIFont,
                lockIcon: UIImage) {
        self.errorLabelTextColor = errorLabelTextColor
        self.errorLabelFont = errorLabelFont
        self.lockIcon = lockIcon
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
                payInvoiceLabelText: String) {
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
    }
}