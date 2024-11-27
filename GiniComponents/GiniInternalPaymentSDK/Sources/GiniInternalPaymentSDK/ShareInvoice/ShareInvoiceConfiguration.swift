//
//  ShareInvoiceSingleAppConfiguration.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

public struct ShareInvoiceConfiguration {
    public let titleFont: UIFont
    public let titleAccentColor: UIColor
    public let descriptionFont: UIFont
    public let descriptionTextColor: UIColor
    public let descriptionAccentColor: UIColor
    public let paymentInfoBorderColor: UIColor
    public let titlePaymentInfoTextColor: UIColor
    public let titlePaymentInfoFont: UIFont
    public let subtitlePaymentInfoTextColor: UIColor
    public let subtitlePaymentInfoFont: UIFont

    public init(titleFont: UIFont,
                titleAccentColor: UIColor,
                descriptionFont: UIFont,
                descriptionTextColor: UIColor,
                descriptionAccentColor: UIColor,
                paymentInfoBorderColor: UIColor,
                titlePaymentInfoTextColor: UIColor,
                subtitlePaymentInfoTextColor: UIColor,
                titlepaymentInfoFont: UIFont,
                subtitlePaymentInfoFont: UIFont) {
        self.titleFont = titleFont
        self.titleAccentColor = titleAccentColor
        self.descriptionFont = descriptionFont
        self.descriptionTextColor = descriptionTextColor
        self.descriptionAccentColor = descriptionAccentColor
        self.paymentInfoBorderColor = paymentInfoBorderColor
        self.titlePaymentInfoTextColor = titlePaymentInfoTextColor
        self.subtitlePaymentInfoTextColor = subtitlePaymentInfoTextColor
        self.titlePaymentInfoFont = titlepaymentInfoFont
        self.subtitlePaymentInfoFont = subtitlePaymentInfoFont
    }
}

public struct ShareInvoiceStrings {
    let continueLabelText: String
    let titleTextPattern: String
    let descriptionTextPattern: String
    let recipientLabelText: String
    let amountLabelText: String
    let ibanLabelText: String
    let purposeLabelText: String

    public init(continueLabelText: String,
                titleTextPattern: String,
                descriptionTextPattern: String,
                recipientLabelText: String,
                amountLabelText: String,
                ibanLabelText: String,
                purposeLabelText: String) {
        self.continueLabelText = continueLabelText
        self.titleTextPattern = titleTextPattern
        self.descriptionTextPattern = descriptionTextPattern
        self.recipientLabelText = recipientLabelText
        self.amountLabelText = amountLabelText
        self.ibanLabelText = ibanLabelText
        self.purposeLabelText = purposeLabelText
    }
}
