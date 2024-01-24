//
//  PaymentComponentViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import UIKit

public protocol PaymentComponentViewModelProtocol: AnyObject {
    func didTapOnMoreInformations()
    func didTapOnBankPicker()
    func didTapOnPayInvoice()
}

final class PaymentComponentViewModel {
    
    var giniConfiguration: GiniHealthConfiguration
    
    let backgroundColor: UIColor = UIColor.from(giniColor: GiniColor(lightModeColor: .clear, 
                                                                     darkModeColor: .black))
    
    // More information part
    let moreInformationAccentColor: UIColor = GiniColor(sameColor: UIColor.GiniColors.dark2).uiColor()
    let moreInformationLabelText = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.moreInformation.label", comment: "")
    let moreInformationActionablePartText = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.moreInformation.underlined.part", comment: "")
    var moreInformationLabelFont: UIFont
    var moreInformationLabelLinkFont: UIFont
    let moreInformationIconName = "info.circle"
    
    // Select bank label
    let selectBankLabelText = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.selectBank.label", comment: "")
    let selectBankLabelFont: UIFont
    let selectBankAccentColor: UIColor = GiniColor(sameColor: UIColor.GiniColors.dark1).uiColor()
    
    // Select bank picker
    let selectBankPickerViewBackgroundColor: UIColor = GiniColor(sameColor: UIColor.GiniColors.dark6).uiColor()
    let selectBankPickerViewBorderColor: UIColor = GiniColor(sameColor: UIColor.GiniColors.dark5).uiColor()
    var bankImageIconName: String
    var bankNameLabelText: String
    var bankNameLabelFont: UIFont
    let bankNameLabelAccentColor: UIColor = GiniColor(sameColor: UIColor.GiniColors.dark1).uiColor()
    let chevronDownIconName: String = "iconChevronDown"
    
    // pay invoice view
    let payInvoiceViewBackgroundColor: UIColor
    let payInvoiceLabelText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.payInvoice.label", comment: "")
    let payInvoiceLabelAccentColor: UIColor
    let payInvoiceLabelFont: UIFont
    
    // powered by Gini view
    let poweredByGiniLabelText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.poweredByGini.label", comment: "")
    let poweredByGiniLabelFont: UIFont
    let poweredByGiniLabelAccentColor: UIColor = GiniColor(sameColor: UIColor.GiniColors.dark4).uiColor()
    let giniIconName: String = "giniLogo"
    
    weak var delegate: PaymentComponentViewModelProtocol?
    
    init(giniConfiguration: GiniHealthConfiguration, 
         bankName: String,
         bankIconName: String) {
        self.giniConfiguration = giniConfiguration
        self.moreInformationLabelFont = giniConfiguration.customFont.with(weight: .regular, 
                                                                          size: 13,
                                                                          style: .caption1)
        self.moreInformationLabelLinkFont = giniConfiguration.customFont.with(weight: .bold, 
                                                                              size: 14,
                                                                              style: .linkBold)
        self.selectBankLabelFont = giniConfiguration.customFont.with(weight: .medium, 
                                                                     size: 14,
                                                                     style: .subtitle2)
        self.bankImageIconName = bankIconName
        self.bankNameLabelText = bankName
        self.bankNameLabelFont = giniConfiguration.customFont.with(weight: .medium,
                                                                   size: 16, 
                                                                   style: .input)
        self.payInvoiceViewBackgroundColor = giniConfiguration.payInvoiceBackgroundColor.uiColor()
        self.payInvoiceLabelAccentColor = giniConfiguration.payInvoiceTextColor.uiColor()
        self.payInvoiceLabelFont = giniConfiguration.customFont.with(weight: .bold, size: 16, style: .button)
        self.poweredByGiniLabelFont = giniConfiguration.customFont.with(weight: .regular, size: 12, style: .caption2)
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

