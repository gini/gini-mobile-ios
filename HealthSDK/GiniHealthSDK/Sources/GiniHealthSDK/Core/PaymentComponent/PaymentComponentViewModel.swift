//
//  PaymentComponentViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniHealthAPILibrary

public protocol PaymentComponentViewProtocol: AnyObject {
    func didTapOnMoreInformation(documentID: String?)
    func didTapOnBankPicker(documentID: String?)
    func didTapOnPayInvoice(documentID: String?)
}

extension PaymentComponentViewProtocol {
    public func didTapOnMoreInformation() {
        didTapOnMoreInformation(documentID: nil)
    }
    public func didTapOnBankPicker() {
        didTapOnBankPicker(documentID: nil)
    }
    public func didTapOnPayInvoice() {
        didTapOnPayInvoice(documentID: nil)
    }
}

final class PaymentComponentViewModel {
    var giniHealthConfiguration = GiniHealthConfiguration.shared

    let backgroundColor: UIColor = UIColor.from(giniColor: GiniColor(lightModeColor: .clear, 
                                                                     darkModeColor: .clear))

    // More information part
    let moreInformationAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark2, 
                                                        darkModeColor: UIColor.GiniHealthColors.light2).uiColor()
    let moreInformationLabelTextColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark4,
                                                        darkModeColor: UIColor.GiniHealthColors.light4).uiColor()
    let moreInformationLabelText = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.moreInformation.label", 
                                                                    comment: "Text for more information label")
    let moreInformationActionablePartText = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.moreInformation.underlined.part",
                                                                             comment: "Text for more information actionable part from the label")
    var moreInformationLabelFont: UIFont
    var moreInformationLabelLinkFont: UIFont
    let moreInformationIconName = "info.circle"
    
    // Select bank label
    let selectYourBankLabelText = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.selectYourBank.label", 
                                                                   comment: "Text for the select your bank label that's above the payment provider picker")
    let selectYourBankLabelFont: UIFont
    let selectYourBankAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark1,
                                                       darkModeColor: UIColor.GiniHealthColors.light1).uiColor()
    
    // Bank image icon
    private var bankImageIconData: Data?
    var bankImageIcon: UIImage {
        if let bankImageIconData {
            return UIImage(data: bankImageIconData) ?? UIImage()
        }
        return UIImage()
    }

    // Bank name label
    private var bankName: String?
    var bankNameLabelText: String {
        if let bankName, !bankName.isEmpty {
            return isPaymentProviderInstalled ? bankName : placeholderBankNameText
        }
        return placeholderBankNameText
    }
    let notInstalledBankTextColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark4,
                                                       darkModeColor: UIColor.GiniHealthColors.light4).uiColor()
    private let placeholderBankNameText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.selectBank.label",
                                                                                   comment: "Placeholder text used when there isn't a payment provider app installed")
    
    let chevronDownIconName: String = "iconChevronDown"
    let chevronDownIconColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.light7,
                                                  darkModeColor: UIColor.GiniHealthColors.light1).uiColor()
    
    // Payment provider colors
    var paymentProviderColors: ProviderColors?

    // Pay invoice label
    let payInvoiceLabelText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.payInvoice.label", 
                                                                       comment: "Title label used for the pay invoice button")

    // Payment provider installation status
    var isPaymentProviderInstalled: Bool {
        if let paymentProviderScheme, let url = URL(string: paymentProviderScheme), UIApplication.shared.canOpenURL(url) {
            return true
        }
        return false
    }
    private var paymentProviderScheme: String?

    weak var delegate: PaymentComponentViewProtocol?
    
    init(paymentProvider: PaymentProvider?) {
        let defaultRegularFont: UIFont = UIFont.systemFont(ofSize: 13, weight: .regular)
        let defaultBoldFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .bold)
        let defaultMediumFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        self.moreInformationLabelFont = giniHealthConfiguration.textStyleFonts[.caption1] ?? defaultRegularFont
        self.moreInformationLabelLinkFont = giniHealthConfiguration.textStyleFonts[.linkBold] ?? defaultBoldFont
        self.selectYourBankLabelFont = giniHealthConfiguration.textStyleFonts[.subtitle2] ?? defaultMediumFont
        
        self.bankImageIconData = paymentProvider?.iconData
        self.bankName = paymentProvider?.name
        self.paymentProviderColors = paymentProvider?.colors
        self.paymentProviderScheme = paymentProvider?.appSchemeIOS
    }
    
    func tapOnMoreInformation() {
        delegate?.didTapOnMoreInformation()
    }
    
    func tapOnBankPicker() {
        delegate?.didTapOnBankPicker()
    }
    
    func tapOnPayInvoiceView() {
        delegate?.didTapOnPayInvoice()
    }
}
