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
    /// Current configuration. Replaced on each Dynamic Type change if `configurationRefresher` is set.
    var configuration: PaymentInfoConfiguration
    /**
     Called in `refreshAttributedContent()` to obtain a fresh configuration with up-to-date
     scaled fonts whenever the Dynamic Type size changes. Returns nil when the owner is gone
     (weak-self capture), in which case the last known configuration is kept unchanged.
     UIFont metrics are computed once at init; this closure lets the owner re-supply a freshly
     scaled configuration after a Dynamic Type change.
     */
    private let configurationRefresher: (() -> PaymentInfoConfiguration?)?
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
                clientConfiguration: ClientConfiguration?,
                configurationRefresher: (() -> PaymentInfoConfiguration?)? = nil) {
        self.paymentProviders = paymentProviders
        self.configuration = configuration
        self.configurationRefresher = configurationRefresher
        self.strings = strings
        self.poweredByGiniViewModel = PoweredByGiniViewModel(configuration: poweredByGiniConfiguration, strings: poweredByGiniStrings)
        self.clientConfiguration = clientConfiguration

        payBillsDescriptionLinkAttributes = [.font: configuration.links.font]

        configurePayBillsGiniLink()
        setupQuestions()
    }
    
    private func setupQuestions() {
        questions = zip(strings.faq.questions, strings.faq.answers).map { question, answer in
            let answerAttributedString = answerWithAttributes(answer: answer, font: configuration.answerCell.font)
            return FAQSection(title: question,
                              description: textWithLinks(linkFont: configuration.links.font,
                                                         attributedString: answerAttributedString),
                              isExtended: false)
        }
    }

    private func configurePayBillsGiniLink() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = Constants.payBillsDescriptionLineHeight
        paragraphStyle.paragraphSpacing = Constants.payBillsParagraphSpacing
        payBillsDescriptionAttributedText = NSMutableAttributedString(string: strings.payBillsDescriptionText,
                                                                      attributes: [.paragraphStyle: paragraphStyle,
                                                                                   .font: configuration.payBills.descriptionFont,
                                                                                   .foregroundColor: configuration.payBills.titleColor])
        payBillsDescriptionAttributedText = textWithLinks(linkFont: configuration.links.giniFont,
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

    /**
     Rebuilds all attributed strings when the Dynamic Type size changes.

     Recomputes paragraph styles, link ranges, and font references so that
     `payBillsDescriptionAttributedText` and all FAQ answer descriptions stay consistent
     with the current content size category.
     */
    func refreshAttributedContent() {
        if let fresh = configurationRefresher?() {
            configuration = fresh
        }
        payBillsDescriptionLinkAttributes = [.font: configuration.links.font]
        configurePayBillsGiniLink()
        let openExtendedSections = questions.enumerated().compactMap { $0.element.isExtended ? $0.offset : nil }
        setupQuestions()
        for index in openExtendedSections where index < questions.count {
            questions[index].isExtended = true
        }
    }
    
    private func textWithLinks(linkFont: UIFont, attributedString: NSMutableAttributedString) -> NSMutableAttributedString {
        let attributedString = attributedString
        let giniRange = (attributedString.string as NSString).range(of: strings.giniLink.websiteText)
        attributedString.addLinkToRange(link: strings.giniLink.urlText,
                                        color: configuration.links.color,
                                        range: giniRange,
                                        linkFont: linkFont,
                                        textToRemove: Constants.linkTextToRemove)
        let privacyPolicyRange = (attributedString.string as NSString).range(of: strings.privacyPolicy.text)
        attributedString.addLinkToRange(link: strings.privacyPolicy.urlText,
                                        color: configuration.links.color,
                                        range: privacyPolicyRange,
                                        linkFont: linkFont,
                                        textToRemove: Constants.linkTextToRemove)
        return attributedString
    }

    func infoAnswerCellModel(at index: Int) -> PaymentInfoAnswerTableViewModel {
        PaymentInfoAnswerTableViewModel(answerAttributedText: questions[index].description, 
                                        answerTextColor: configuration.answerCell.textColor,
                                        answerLinkColor: configuration.answerCell.linkColor)
    }

    func infoQuestionHeaderViewModel(at index: Int) -> PaymentInfoQuestionHeaderViewModel {
        PaymentInfoQuestionHeaderViewModel(titleText: questions[index].title,
                                           titleFont: configuration.questionHeader.font,
                                           titleColor: configuration.questionHeader.titleColor,
                                           extendedIcon: questions[index].isExtended ? configuration.questionHeader.minusIcon : configuration.questionHeader.plusIcon,
                                           iconTintColor: configuration.questionHeader.iconTintColor,
                                           isExpanded: questions[index].isExtended,
                                           toggleAccessibilityStrings: .init(expanded: strings.faq.accessibilityExpandedText,
                                                                             collapsed: strings.faq.accessibilityCollapsedText))
    }

    func infoBankCellModel(at index: Int) -> PaymentInfoBankCollectionViewCellModel {
        PaymentInfoBankCollectionViewCellModel(bankImageIconData: paymentProviders[index].iconData,
                                               borderColor: configuration.layout.bankCellBorderColor)
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
