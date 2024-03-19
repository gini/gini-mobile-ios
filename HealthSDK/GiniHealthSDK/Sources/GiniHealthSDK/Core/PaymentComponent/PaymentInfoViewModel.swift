//
//  PaymentInfoViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniHealthAPILibrary

struct FAQSection {
    let title: String
    var description: NSAttributedString
    var isExtended: Bool
}

final class PaymentInfoViewModel {
    
    var paymentProviders: PaymentProviders
    
    let backgroundColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark7,
                                             darkModeColor: UIColor.GiniHealthColors.light7).uiColor()
    
    let titleText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.paymentinfo.title.label", 
                                                             comment: "Payment Info title label text")
    
    let payBillsTitleText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.paymentinfo.payBills.title.label", 
                                                                     comment: "Payment Info pay bills title label text")
    let payBillsTitleFont: UIFont
    let payBillsTitleTextColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark1,
                                                    darkModeColor: UIColor.GiniHealthColors.light1).uiColor()
    
    private let payBillsDescriptionText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.paymentinfo.payBills.description.label",
                                                                                   comment: "Payment Info pay bills description text")
    var payBillsDescriptionAttributedText: NSMutableAttributedString = NSMutableAttributedString()
    var payBillsDescriptionLinkAttributes: [NSAttributedString.Key: Any]
    private let payBillsDescriptionFont: UIFont
    private let payBillsDescriptionTextColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark1,
                                                                  darkModeColor: UIColor.GiniHealthColors.light1).uiColor()
    private let giniWebsiteText = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.paymentinfo.payBills.description.clickable.text",
                                                                   comment: "Word range that's clickable in pay bills description")
    private let giniFont: UIFont
    private let giniURLText = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.paymentinfo.gini.link", 
                                                               comment: "Gini website link url")
    
    let questionsTitleText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.paymentinfo.questions.title.label",
                                                                      comment: "Payment Info questions title label text")
    let questionsTitleFont: UIFont
    let questionsTitleTextColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark1,
                                                     darkModeColor: UIColor.GiniHealthColors.light1).uiColor()
    
    private var answersFont: UIFont
    private let answerPrivacyPolicyText = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.paymentinfo.questions.answer.clickable.text",
                                                                           comment: "Payment info answers clickable privacy policy")
    private let privacyPolicyURLText = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.paymentinfo.gini.privacypolicy.link",
                                                                        comment: "Gini privacy policy link url")
    private var linksFont: UIFont
    private let linksTextColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.accent1,
                                                       darkModeColor: UIColor.GiniHealthColors.accent1).uiColor()
    
    let separatorColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark5,
                                            darkModeColor: UIColor.GiniHealthColors.light5).uiColor()
    
    var questions: [FAQSection] = []
    
    init(paymentProviders: PaymentProviders) {
        self.paymentProviders = paymentProviders
            .filter({ $0.appStoreUrlIOS != nil || $0.appStoreUrlIOS?.canOpenURLString() ?? false })
        
        let giniHealthConfiguration = GiniHealthConfiguration.shared
        
        let defaultRegularFont: UIFont = UIFont.systemFont(ofSize: 13, weight: .regular)
        let defaultBoldFont: UIFont = UIFont.systemFont(ofSize: 13, weight: .bold)
        
        payBillsTitleFont = giniHealthConfiguration.textStyleFonts[.subtitle1] ?? defaultBoldFont
        payBillsDescriptionFont = giniHealthConfiguration.textStyleFonts[.body2] ?? defaultRegularFont
        questionsTitleFont = giniHealthConfiguration.textStyleFonts[.subtitle1] ?? defaultBoldFont
        giniFont = giniHealthConfiguration.textStyleFonts[.button] ?? defaultBoldFont
        answersFont = giniHealthConfiguration.textStyleFonts[.body2] ?? defaultRegularFont
        linksFont = giniHealthConfiguration.textStyleFonts[.linkBold] ?? defaultBoldFont
        
        payBillsDescriptionLinkAttributes = [.foregroundColor: linksTextColor]
        
        configurePayBillsGiniLink()
        setupQuestions()
    }
    
    private func setupQuestions() {
        for index in 1 ... Constants.numberOfQuestions {
            let answerAttributedString = answerWithAttributes(answer: NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.paymentinfo.questions.answer.\(index)",
                                                                                                       comment: "Answers description"))
            let questionSection = FAQSection(title: NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.paymentinfo.questions.question.\(index)",
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
