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
                backgroundColor: UIColor) {
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
    }
}

public struct PaymentInfoStrings {
    let giniWebsiteText : String
    let giniURLText: String

    let questionsTitleText: String
    let answerPrivacyPolicyText: String
    let privacyPolicyURLText: String
    let titleText: String
    let payBillsTitleText: String
    let payBillsDescriptionText: String

    let answers: [String]
    let questions: [String]

    public init(giniWebsiteText: String,
                giniURLText: String,
                questionsTitleText: String,
                answerPrivacyPolicyText: String,
                privacyPolicyURLText: String,
                titleText: String,
                payBillsTitleText: String,
                payBillsDescriptionText: String,
                answers: [String],
                questions: [String]) {
        self.answers = answers
        self.questions = questions
        self.giniURLText = giniURLText
        self.giniWebsiteText = giniWebsiteText
        self.titleText = titleText
        self.payBillsTitleText = payBillsTitleText
        self.payBillsDescriptionText = payBillsDescriptionText
        self.answerPrivacyPolicyText = answerPrivacyPolicyText
        self.privacyPolicyURLText = privacyPolicyURLText
        self.questionsTitleText = questionsTitleText
    }
}
