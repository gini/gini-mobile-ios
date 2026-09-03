//
//  PaymentInfoConfiguration.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

public struct PaymentInfoAnswerCellConfiguration {
    let font: UIFont
    let textColor: UIColor
    let linkColor: UIColor

    public init(font: UIFont,
                textColor: UIColor,
                linkColor: UIColor) {
        self.font = font
        self.textColor = textColor
        self.linkColor = linkColor
    }
}

public struct PaymentInfoQuestionHeaderConfiguration {
    let font: UIFont
    let titleColor: UIColor
    let minusIcon: UIImage
    let plusIcon: UIImage
    let iconTintColor: UIColor

    public init(font: UIFont,
                titleColor: UIColor,
                minusIcon: UIImage,
                plusIcon: UIImage,
                iconTintColor: UIColor) {
        self.font = font
        self.titleColor = titleColor
        self.minusIcon = minusIcon
        self.plusIcon = plusIcon
        self.iconTintColor = iconTintColor
    }
}

public struct PaymentInfoQuestionsTitleConfiguration {
    let font: UIFont
    let color: UIColor

    public init(font: UIFont,
                color: UIColor) {
        self.font = font
        self.color = color
    }
}

public struct PaymentInfoPayBillsConfiguration {
    let titleFont: UIFont
    let titleColor: UIColor
    let descriptionFont: UIFont

    public init(titleFont: UIFont,
                titleColor: UIColor,
                descriptionFont: UIFont) {
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.descriptionFont = descriptionFont
    }
}

public struct PaymentInfoLinkConfiguration {
    let giniFont: UIFont
    let font: UIFont
    let color: UIColor

    public init(giniFont: UIFont,
                font: UIFont,
                color: UIColor) {
        self.giniFont = giniFont
        self.font = font
        self.color = color
    }
}

public struct PaymentInfoLayoutConfiguration {
    let bankCellBorderColor: UIColor
    let separatorColor: UIColor
    let backgroundColor: UIColor

    public init(bankCellBorderColor: UIColor,
                separatorColor: UIColor,
                backgroundColor: UIColor) {
        self.bankCellBorderColor = bankCellBorderColor
        self.separatorColor = separatorColor
        self.backgroundColor = backgroundColor
    }
}

public struct PaymentInfoConfiguration {
    let answerCell: PaymentInfoAnswerCellConfiguration
    let questionHeader: PaymentInfoQuestionHeaderConfiguration
    let questionsTitle: PaymentInfoQuestionsTitleConfiguration
    let payBills: PaymentInfoPayBillsConfiguration
    let links: PaymentInfoLinkConfiguration
    let layout: PaymentInfoLayoutConfiguration

    public init(answerCell: PaymentInfoAnswerCellConfiguration,
                questionHeader: PaymentInfoQuestionHeaderConfiguration,
                questionsTitle: PaymentInfoQuestionsTitleConfiguration,
                payBills: PaymentInfoPayBillsConfiguration,
                links: PaymentInfoLinkConfiguration,
                layout: PaymentInfoLayoutConfiguration) {
        self.answerCell = answerCell
        self.questionHeader = questionHeader
        self.questionsTitle = questionsTitle
        self.payBills = payBills
        self.links = links
        self.layout = layout
    }
}

public struct PaymentInfoGiniLinkStrings {
    let websiteText: String
    let urlText: String

    public init(websiteText: String,
                urlText: String) {
        self.websiteText = websiteText
        self.urlText = urlText
    }
}

public struct PaymentInfoPrivacyPolicyStrings {
    let text: String
    let urlText: String

    public init(text: String,
                urlText: String) {
        self.text = text
        self.urlText = urlText
    }
}

public struct PaymentInfoFAQStrings {
    let titleText: String
    let questions: [String]
    let answers: [String]
    let accessibilityExpandedText: String
    let accessibilityCollapsedText: String

    public init(titleText: String,
                questions: [String],
                answers: [String],
                accessibilityExpandedText: String,
                accessibilityCollapsedText: String) {
        self.titleText = titleText
        self.questions = questions
        self.answers = answers
        self.accessibilityExpandedText = accessibilityExpandedText
        self.accessibilityCollapsedText = accessibilityCollapsedText
    }
}

public struct PaymentInfoStrings {
    let giniLink: PaymentInfoGiniLinkStrings
    let supportedBanksText: String
    let titleText: String
    let payBillsTitleText: String
    let payBillsDescriptionText: String
    let privacyPolicy: PaymentInfoPrivacyPolicyStrings
    let faq: PaymentInfoFAQStrings

    public init(giniLink: PaymentInfoGiniLinkStrings,
                supportedBanksText: String,
                titleText: String,
                payBillsTitleText: String,
                payBillsDescriptionText: String,
                privacyPolicy: PaymentInfoPrivacyPolicyStrings,
                faq: PaymentInfoFAQStrings) {
        self.giniLink = giniLink
        self.supportedBanksText = supportedBanksText
        self.titleText = titleText
        self.payBillsTitleText = payBillsTitleText
        self.payBillsDescriptionText = payBillsDescriptionText
        self.privacyPolicy = privacyPolicy
        self.faq = faq
    }
}
