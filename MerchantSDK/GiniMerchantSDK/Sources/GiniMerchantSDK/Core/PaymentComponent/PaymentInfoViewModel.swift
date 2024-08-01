//
//  PaymentInfoViewModel.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites
import GiniHealthAPILibrary

struct FAQSection {
    let title: String
    var description: NSAttributedString
    var isExtended: Bool
}

final class PaymentInfoViewModel {
    
    var paymentProviders: PaymentProviders
    
    let backgroundColor: UIColor = GiniColor.standard7.uiColor()
    
    let titleText: String = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.payment.info.title.label", 
                                                             comment: "Payment Info title label text")
    
    let payBillsTitleText: String = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.payment.info.pay.bills.title.label", 
                                                                     comment: "Payment Info pay bills title label text")
    let payBillsTitleFont: UIFont
    let payBillsTitleTextColor: UIColor = GiniColor.standard1.uiColor()
    
    private let payBillsDescriptionText: String = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.payment.info.pay.bills.description.label",
                                                                                   comment: "Payment Info pay bills description text")
    var payBillsDescriptionAttributedText: NSMutableAttributedString = NSMutableAttributedString()
    var payBillsDescriptionLinkAttributes: [NSAttributedString.Key: Any]
    private let payBillsDescriptionFont: UIFont
    private let payBillsDescriptionTextColor: UIColor = GiniColor.standard1.uiColor()
    private let giniWebsiteText = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.payment.info.pay.bills.description.clickable.text",
                                                                   comment: "Word range that's clickable in pay bills description")
    private let giniFont: UIFont
    private let giniURLText = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.payment.info.gini.link", 
                                                               comment: "Gini website link url")
    
    let questionsTitleText: String = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.paymentinfo.questions.title.label",
                                                                      comment: "Payment Info questions title label text")
    let questionsTitleFont: UIFont
    let questionsTitleTextColor: UIColor = GiniColor.standard1.uiColor()
    
    private var answersFont: UIFont
    private let answerPrivacyPolicyText = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.payment.info.questions.answer.clickable.text",
                                                                           comment: "Payment info answers clickable privacy policy")
    private let privacyPolicyURLText = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.payment.info.gini.privacypolicy.link",
                                                                        comment: "Gini privacy policy link url")
    private var linksFont: UIFont
    private let linksTextColor: UIColor = GiniColor.accent1.uiColor()
    
    let separatorColor: UIColor = GiniColor.standard5.uiColor()
    
    var questions: [FAQSection] = []
    
    init(paymentProviders: PaymentProviders) {
        self.paymentProviders = paymentProviders
        
        let giniConfiguration = GiniMerchantConfiguration.shared
        
        payBillsTitleFont = giniConfiguration.font(for: .subtitle1)
        payBillsDescriptionFont = giniConfiguration.font(for: .body2)
        questionsTitleFont = giniConfiguration.font(for: .subtitle1)
        giniFont = giniConfiguration.font(for: .button)
        answersFont = giniConfiguration.font(for: .body2)
        linksFont = giniConfiguration.font(for: .linkBold)

        payBillsDescriptionLinkAttributes = [.foregroundColor: linksTextColor]
        
        configurePayBillsGiniLink()
        setupQuestions()
    }
    
    private func setupQuestions() {
        for index in 1 ... Constants.numberOfQuestions {
            let answerAttributedString = answerWithAttributes(answer: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.payment.info.questions.answer.\(index)",
                                                                                                       comment: "Answers description"))
            let questionSection = FAQSection(title: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.payment.info.questions.question.\(index)",
                                                                                          comment: "Questions titles"),
                                                  description: textWithLinks(linkFont: linksFont, 
                                                                             attributedString: answerAttributedString),
                                                  isExtended: false)
            questions.append(questionSection)
        }
    }
    
    private func configurePayBillsGiniLink() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = Constants.payBillsDescriptionLineHeight
        paragraphStyle.paragraphSpacing = Constants.payBillsParagraphSpacing
        payBillsDescriptionAttributedText = NSMutableAttributedString(string: payBillsDescriptionText,
                                                                      attributes: [.paragraphStyle: paragraphStyle,
                                                                                   .font: payBillsDescriptionFont,
                                                                                   .foregroundColor: payBillsTitleTextColor])
        payBillsDescriptionAttributedText = textWithLinks(linkFont: giniFont, 
                                                          attributedString: payBillsDescriptionAttributedText)
    }
    
    private func answerWithAttributes(answer: String) -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = Constants.answersLineHeight
        paragraphStyle.paragraphSpacing = Constants.answersParagraphSpacing
        let answerAttributedText = NSMutableAttributedString(string: answer,
                                                             attributes: [.font: answersFont, .paragraphStyle: paragraphStyle])
        return answerAttributedText
    }
    
    private func textWithLinks(linkFont: UIFont, attributedString: NSMutableAttributedString) -> NSMutableAttributedString {
        let attributedString = attributedString
        let giniRange = (attributedString.string as NSString).range(of: giniWebsiteText)
        attributedString.addLinkToRange(link: giniURLText,
                                        range: giniRange,
                                        linkFont: linkFont,
                                        textToRemove: Constants.linkTextToRemove)
        let privacyPolicyRange = (attributedString.string as NSString).range(of: answerPrivacyPolicyText)
        attributedString.addLinkToRange(link: privacyPolicyURLText,
                                        range: privacyPolicyRange,
                                        linkFont: linkFont,
                                        textToRemove: Constants.linkTextToRemove)
        return attributedString
    }
}

extension PaymentInfoViewModel {
    private enum Constants {
        static let numberOfQuestions = 6
        
        static let payBillsDescriptionLineHeight = 1.32
        static let payBillsParagraphSpacing = 10.0
        
        static let answersLineHeight = 1.32
        static let answersParagraphSpacing = 10.0
        
        static let linkTextToRemove = "[LINK]"
    }
}
