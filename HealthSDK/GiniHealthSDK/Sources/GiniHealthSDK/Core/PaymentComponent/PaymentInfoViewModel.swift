//
//  PaymentInfoViewModel q.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniHealthAPILibrary

public protocol PaymentInfoViewProtocol: AnyObject {
    func didTapOnCloseOnInfoView()
}

struct QuestionSection {
    let title: String
    let description: String
    var isExtended: Bool
}

final class PaymentInfoViewModel {
    
    weak var viewDelegate: PaymentInfoViewProtocol?
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
    var payBillsDescriptionAttributedText: NSMutableAttributedString?
    let payBillsDescriptionFont: UIFont
    let payBillsDescriptionTextColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark1,
                                                          darkModeColor: UIColor.GiniHealthColors.light1).uiColor()
    let giniWebsiteText = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.paymentinfo.payBills.description.clickable.text",
                                                           comment: "Word range that's clickable in pay bills description")
    private let giniFont: UIFont
    private let giniURLText = Constants.giniURL
    
    let questionsTitleText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.paymentinfo.questions.title.label",
                                                                      comment: "Payment Info questions title label text")
    let questionsTitleFont: UIFont
    let questionsTitleTextColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark1,
                                                     darkModeColor: UIColor.GiniHealthColors.light1).uiColor()
    
    let separatorColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark5,
                                            darkModeColor: UIColor.GiniHealthColors.light5).uiColor()
    
    var questions: [QuestionSection] = []
    
    init(paymentProviders: PaymentProviders) {
        self.paymentProviders = paymentProviders
        
        let giniHealthConfiguration = GiniHealthConfiguration.shared
        
        let defaultRegularFont: UIFont = giniHealthConfiguration.customFont.regular
        let defaultBoldFont: UIFont = giniHealthConfiguration.customFont.bold
        
        payBillsTitleFont = giniHealthConfiguration.textStyleFonts[.subtitle1] ?? defaultBoldFont
        payBillsDescriptionFont = giniHealthConfiguration.textStyleFonts[.body2] ?? defaultRegularFont
        questionsTitleFont = giniHealthConfiguration.textStyleFonts[.subtitle1] ?? defaultBoldFont
        giniFont = giniHealthConfiguration.textStyleFonts[.button] ?? defaultBoldFont
        
        setupQuestions()
        self.configureClickableTexts()
    }
    
    func didTapOnClose() {
        viewDelegate?.didTapOnCloseOnInfoView()
    }
    
    private func setupQuestions() {
        for index in 1 ... 5 {
            let questionSection = QuestionSection(title: NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.paymentinfo.questions.question.\(index)",
                                                                                          comment: "Questions titles"),
                                                  description: NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.paymentinfo.questions.answer.\(index)",
                                                                                                comment: "Answers subtitles"),
                                                  isExtended: false)
            questions.append(questionSection)
        }
    }
    
    private func configureClickableTexts() {
        configurePayBillsGiniLink()
    }
    
    private func configurePayBillsGiniLink() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = Constants.payBillsDescriptionLineHeight
        paragraphStyle.paragraphSpacing = Constants.payBillsParagraphSpacing
        self.payBillsDescriptionAttributedText = NSMutableAttributedString(string: payBillsDescriptionText,
                                                                           attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        let giniRange = (payBillsDescriptionText as NSString).range(of: giniWebsiteText)
        if let giniUrl = URL(string: giniURLText) {
            let attributes: [NSAttributedString.Key: Any] = [
                .link: giniUrl,
                .foregroundColor: GiniColor(lightModeColor: UIColor.GiniHealthColors.accent1,
                                            darkModeColor: UIColor.GiniHealthColors.accent1).uiColor(),
                .font: giniFont
            ]
            payBillsDescriptionAttributedText?.addAttributes(attributes, range: giniRange)
        }
    }
    
    func tapOnGiniWebsite() {
        openLink(urlString: giniURLText)
    }
    
    private func openLink(urlString: String) {
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

extension PaymentInfoViewModel {
    private enum Constants {
        static let payBillsDescriptionLineHeight = 1.32
        static let payBillsParagraphSpacing = 10.0
        
        static let giniURL = "https://gini.net/"
    }
}
