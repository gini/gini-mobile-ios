//
//  PaymentInfoConfiguration.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

public struct PaymentInfoConfiguration {
    let giniFont: UIFont
    let answersFont: UIFont
    let answerCellTextColor: UIColor
    let answerCellLinkColor: UIColor
    let questionsTitleFont: UIFont
    let questionsTitleColor: UIColor
    let questionHeaderFont: UIFont
    let questionHeaderTitleColor: UIColor
    let questionHeaderMinusIcon: UIImage
    let questionHeaderPlusIcon: UIImage
    let bankCellBorderColor: UIColor
    let payBillsTitleFont: UIFont
    let payBillsTitleColor: UIColor
    let payBillsDescriptionFont: UIFont
    let linksFont: UIFont
    let linksColor: UIColor
    let separatorColor: UIColor
    let backgroundColor: UIColor
    let questionHeaderIconTintColor: UIColor

    public init(giniFont: UIFont,
                answersFont: UIFont,
                answerCellTextColor: UIColor,
                answerCellLinkColor: UIColor,
                questionsTitleFont: UIFont,
                questionsTitleColor: UIColor,
                questionHeaderFont: UIFont,
                questionHeaderTitleColor: UIColor,
                questionHeaderMinusIcon: UIImage,
                questionHeaderPlusIcon: UIImage,
                bankCellBorderColor: UIColor,
                payBillsTitleFont: UIFont,
                payBillsTitleColor: UIColor,
                payBillsDescriptionFont: UIFont,
                linksFont: UIFont,
                linksColor: UIColor,
                separatorColor: UIColor,
                backgroundColor: UIColor,
                questionHeaderIconTintColor: UIColor) {
        self.giniFont = giniFont
        self.answersFont = answersFont
        self.answerCellTextColor = answerCellTextColor
        self.answerCellLinkColor = answerCellLinkColor
        self.questionsTitleFont = questionsTitleFont
        self.questionsTitleColor = questionsTitleColor
        self.questionHeaderFont = questionHeaderFont
        self.questionHeaderTitleColor = questionHeaderTitleColor
        self.questionHeaderMinusIcon = questionHeaderMinusIcon
        self.questionHeaderPlusIcon = questionHeaderPlusIcon
        self.bankCellBorderColor = bankCellBorderColor
        self.payBillsTitleFont = payBillsTitleFont
        self.payBillsTitleColor = payBillsTitleColor
        self.payBillsDescriptionFont = payBillsDescriptionFont
        self.linksFont = linksFont
        self.linksColor = linksColor
        self.separatorColor = separatorColor
        self.backgroundColor = backgroundColor
        self.questionHeaderIconTintColor = questionHeaderIconTintColor
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

    public init(titleText: String,
                questions: [String],
                answers: [String]) {
        self.titleText = titleText
        self.questions = questions
        self.answers = answers
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
