//
//  PaymentInfoViewModel.swift
//  GiniMerchantSDK
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

public final class PaymentInfoViewModel {
    let configuration: PaymentInfoConfiguration
    let strings: PaymentInfoStrings
    var paymentProviders: GiniHealthAPILibrary.PaymentProviders
    let poweredByGiniViewModel: PoweredByGiniViewModel

    var payBillsDescriptionAttributedText: NSMutableAttributedString = NSMutableAttributedString()
    var payBillsDescriptionLinkAttributes: [NSAttributedString.Key: Any]
    var questions: [FAQSection] = []

    var clientConfiguration: ClientConfiguration?
    var shouldShowBrandedView: Bool {
        clientConfiguration?.ingredientBrandType == .fullVisible
    }
    
    var accessibilityBankListText: String {
        let bankNames = paymentProviders.map { $0.name }.joined(separator: ", ")
        
        return String(format: strings.supportedBanksText, bankNames)
    }

    public init(paymentProviders: GiniHealthAPILibrary.PaymentProviders,
                configuration: PaymentInfoConfiguration,
                strings: PaymentInfoStrings,
                poweredByGiniConfiguration: PoweredByGiniConfiguration,
                poweredByGiniStrings: PoweredByGiniStrings,
                clientConfiguration: ClientConfiguration?) {
        self.paymentProviders = paymentProviders
        self.configuration = configuration
        self.strings = strings
        self.poweredByGiniViewModel = PoweredByGiniViewModel(configuration: poweredByGiniConfiguration, strings: poweredByGiniStrings)
        self.clientConfiguration = clientConfiguration

        payBillsDescriptionLinkAttributes = [.font: configuration.linksFont]

        configurePayBillsGiniLink()
        setupQuestions()
    }
    
    private func setupQuestions() {
        setupQuestions(answersFont: nil, linksFont: nil)
    }

    private func setupQuestions(answersFont: UIFont?, linksFont: UIFont?) {
        let resolvedAnswersFont = answersFont ?? configuration.answersFont
        let resolvedLinksFont = linksFont ?? configuration.linksFont
        questions = zip(strings.questions, strings.answers).map { question, answer in
            let answerAttributedString = answerWithAttributes(answer: answer, font: resolvedAnswersFont)
            return FAQSection(title: question,
                              description: textWithLinks(linkFont: resolvedLinksFont, attributedString: answerAttributedString),
                              isExtended: false)
        }
    }

    private func configurePayBillsGiniLink() {
        configurePayBillsGiniLink(descriptionFont: nil, giniFont: nil)
    }

    private func configurePayBillsGiniLink(descriptionFont: UIFont?, giniFont: UIFont?) {
        let resolvedDescriptionFont = descriptionFont ?? configuration.payBillsDescriptionFont
        let resolvedGiniFont = giniFont ?? configuration.giniFont
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = Constants.payBillsDescriptionLineHeight
        paragraphStyle.paragraphSpacing = Constants.payBillsParagraphSpacing
        payBillsDescriptionAttributedText = NSMutableAttributedString(string: strings.payBillsDescriptionText,
                                                                      attributes: [.paragraphStyle: paragraphStyle,
                                                                                   .font: resolvedDescriptionFont,
                                                                                   .foregroundColor: configuration.payBillsTitleColor])
        payBillsDescriptionAttributedText = textWithLinks(linkFont: resolvedGiniFont,
                                                          attributedString: payBillsDescriptionAttributedText)
    }

    private func answerWithAttributes(answer: String, font: UIFont) -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = Constants.answersLineHeight
        paragraphStyle.paragraphSpacing = Constants.answersParagraphSpacing
        let answerAttributedText = NSMutableAttributedString(string: answer,
                                                             attributes: [.font: font, .paragraphStyle: paragraphStyle])
        return answerAttributedText
    }

    private func answerWithAttributes(answer: String) -> NSMutableAttributedString {
        answerWithAttributes(answer: answer, font: configuration.answersFont)
    }

    /**
     Rebuilds all attributed strings using freshly-scaled fonts for the current Dynamic Type size.

     Call this when the user's preferred content size category changes at runtime so that
     `payBillsDescriptionAttributedText` and all FAQ answer descriptions reflect the new font size.
     */
    func refreshAttributedContent() {
        let dynamicFont = configuration.dynamicFont
        let descriptionFont = dynamicFont?(.body2)
        let freshGiniFont = dynamicFont?(.button)
        let answersFont = dynamicFont?(.body2)
        let linksFont = dynamicFont?(.linkBold)
        payBillsDescriptionLinkAttributes = [.font: linksFont ?? configuration.linksFont]
        configurePayBillsGiniLink(descriptionFont: descriptionFont, giniFont: freshGiniFont)
        let openExtendedSections = questions.enumerated().compactMap { $0.element.isExtended ? $0.offset : nil }
        setupQuestions(answersFont: answersFont, linksFont: linksFont)
        for index in openExtendedSections where index < questions.count {
            questions[index].isExtended = true
        }
    }
    
    private func textWithLinks(linkFont: UIFont, attributedString: NSMutableAttributedString) -> NSMutableAttributedString {
        let attributedString = attributedString
        let giniRange = (attributedString.string as NSString).range(of: strings.giniWebsiteText)
        attributedString.addLinkToRange(link: strings.giniURLText,
                                        color: configuration.linksColor,
                                        range: giniRange,
                                        linkFont: linkFont,
                                        textToRemove: Constants.linkTextToRemove)
        let privacyPolicyRange = (attributedString.string as NSString).range(of: strings.answerPrivacyPolicyText)
        attributedString.addLinkToRange(link: strings.privacyPolicyURLText,
                                        color: configuration.linksColor,
                                        range: privacyPolicyRange,
                                        linkFont: linkFont,
                                        textToRemove: Constants.linkTextToRemove)
        return attributedString
    }

    func infoAnswerCellModel(at index: Int) -> PaymentInfoAnswerTableViewModel {
        PaymentInfoAnswerTableViewModel(answerAttributedText: questions[index].description, 
                                        answerTextColor: configuration.answerCellTextColor,
                                        answerLinkColor: configuration.answerCellLinkColor)
    }

    func infoQuestionHeaderViewModel(at index: Int) -> PaymentInfoQuestionHeaderViewModel {
        PaymentInfoQuestionHeaderViewModel(titleText: questions[index].title, 
                                           titleFont: configuration.questionHeaderFont,
                                           titleColor: configuration.questionHeaderTitleColor,
                                           extendedIcon: questions[index].isExtended ? configuration.questionHeaderMinusIcon : configuration.questionHeaderPlusIcon,
                                           iconTintColor: configuration.questionHeaderIconTintColor)
    }

    func infoBankCellModel(at index: Int) -> PaymentInfoBankCollectionViewCellModel {
        PaymentInfoBankCollectionViewCellModel(bankImageIconData: paymentProviders[index].iconData,
                                               borderColor: configuration.bankCellBorderColor)
    }
}

extension PaymentInfoViewModel {
    private enum Constants {
        static let payBillsDescriptionLineHeight = 1.32
        static let payBillsParagraphSpacing = 10.0
        
        static let answersLineHeight = 1.32
        static let answersParagraphSpacing = 10.0
        
        static let linkTextToRemove = "[LINK]"
    }
}
