//
//  PaymentComponentViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniHealthAPILibrary

public protocol PaymentComponentViewModelProtocol: AnyObject {
    func didTapOnMoreInformations()
    func didTapOnBankPicker()
    func didTapOnPayInvoice()
}

final class PaymentComponentViewModel {
    private var giniHealth: GiniHealth

    let backgroundColor: UIColor = UIColor.from(giniColor: GiniColor(lightModeColor: .clear, 
                                                                     darkModeColor: .clear))
    
    // More information part
    let moreInformationAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniColors.dark2, 
                                                        darkModeColor: UIColor.GiniColors.light4).uiColor()
    let moreInformationLabelText = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.moreInformation.label", comment: "")
    let moreInformationActionablePartText = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.moreInformation.underlined.part", comment: "")
    var moreInformationLabelFont: UIFont
    var moreInformationLabelLinkFont: UIFont
    let moreInformationIconName = "info.circle"
    
    // Select bank label
    let selectYourBankLabelText = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.selectYourBank.label", comment: "")
    let selectYourBankLabelFont: UIFont
    let selectYourBankAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniColors.dark1, 
                                                   darkModeColor: UIColor.GiniColors.light1).uiColor()
    
    // Select bank picker
    let selectBankPickerViewBackgroundColor: UIColor = GiniColor(lightModeColor: UIColor.GiniColors.dark6, 
                                                                 darkModeColor: UIColor.GiniColors.light6).uiColor()
    let selectBankPickerViewBorderColor: UIColor = GiniColor(lightModeColor: UIColor.GiniColors.dark5,
                                                             darkModeColor: UIColor.GiniColors.light5).uiColor()
    private var bankImageIconData: Data?
    var bankImageIcon: UIImage {
        if let bankImageIconData {
            return UIImage(data: bankImageIconData) ?? UIImage()
        }
        return UIImage()
    }

    private var bankName: String?
    var bankNameLabelText: String {
        if let bankName, !bankName.isEmpty {
            return isPaymentProviderInstalled ? bankName : placeholderBankNameText
        }
        return placeholderBankNameText
    }
    var bankNameLabelFont: UIFont
    let bankNameLabelAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniColors.dark1, 
                                                      darkModeColor: UIColor.GiniColors.light1).uiColor()
    private let placeholderBankNameText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.selectBank.label", comment: "")
    let chevronDownIconName: String = "iconChevronDown"
    
    // pay invoice view background color
    var payInvoiceViewBackgroundColor: UIColor {
        if let payInvoiceViewBackgroundColorString, let backgroundHexColor = payInvoiceViewBackgroundColorString.toColor() {
            return isPaymentProviderInstalled ? backgroundHexColor : defaultPayInvoiceViewBackgroundColor.withAlphaComponent(0.4)
        }
        return defaultPayInvoiceViewBackgroundColor.withAlphaComponent(0.4)
    }
    private let payInvoiceViewBackgroundColorString: String?
    private let defaultPayInvoiceViewBackgroundColor: UIColor = UIColor.GiniColors.accent1

    // pay invoice view text color
    let payInvoiceLabelText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.payInvoice.label", comment: "")
    var payInvoiceLabelAccentColor: UIColor {
        if let payInvoiceLabelAccentColorString, let textHexColor = payInvoiceLabelAccentColorString.toColor() {
            return textHexColor
        }
        return defaultpayInvoiceLabelAccentColorString
    }
    private let payInvoiceLabelAccentColorString: String?
    private let defaultpayInvoiceLabelAccentColorString: UIColor = UIColor.GiniColors.dark7

    // pay invoice view font
    let payInvoiceLabelFont: UIFont

    var isPaymentProviderInstalled: Bool {
        if let paymentProviderScheme, let url = URL(string: paymentProviderScheme), UIApplication.shared.canOpenURL(url) {
            return true
        }
        return false
    }
    private var paymentProviderScheme: String?

    weak var delegate: PaymentComponentViewModelProtocol?
    
    init(paymentProvider: PaymentProvider?,
         giniHealth: GiniHealth) {
        self.giniHealth = giniHealth
        self.moreInformationLabelFont = GiniHealthConfiguration.shared.customFont.with(weight: .regular,
                                                                                       size: 13,
                                                                                       style: .caption1)
        self.moreInformationLabelLinkFont = GiniHealthConfiguration.shared.customFont.with(weight: .bold,
                                                                                           size: 14,
                                                                                           style: .linkBold)
        self.selectYourBankLabelFont = GiniHealthConfiguration.shared.customFont.with(weight: .medium,
                                                                                      size: 14,
                                                                                      style: .subtitle2)
        self.bankNameLabelFont = GiniHealthConfiguration.shared.customFont.with(weight: .medium,
                                                                                size: 16,
                                                                                style: .input)
        self.payInvoiceLabelFont = GiniHealthConfiguration.shared.customFont.with(weight: .bold,
                                                                                  size: 16,
                                                                                  style: .button)
        self.bankImageIconData = paymentProvider?.iconData
        self.bankName = paymentProvider?.name
        self.payInvoiceViewBackgroundColorString = paymentProvider?.colors.background
        self.payInvoiceLabelAccentColorString = paymentProvider?.colors.text
        self.paymentProviderScheme = paymentProvider?.appSchemeIOS
    }
    
    func tapOnMoreInformation() {
        delegate?.didTapOnMoreInformations()
    }
    
    func tapOnBankPicker() {
        delegate?.didTapOnBankPicker()
    }
    
    func tapOnPayInvoiceView() {
        delegate?.didTapOnPayInvoice()
    }
}

